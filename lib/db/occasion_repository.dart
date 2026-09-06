// Was gespeichert werden muss: nur, wo ein Mensch entschieden hat.
//
// Die Gruppierung zu Messanlässen und die Zuordnung zu Phasen werden
// gerechnet, nicht gespeichert — bei jeder Abfrage neu, aus den Rohmessungen.
// Persistent ist allein, was daraus nicht folgt: eine Entscheidung des
// Nutzers über einen Grenzfall, und die Phasen, die er benannt hat.
//
// Der Grund ist derselbe wie überall in diesem Projekt: Was rechenbar ist,
// wird gerechnet. Gespeicherte Ableitungen veralten still, sobald sich die
// Regel ändert.
import 'package:drift/drift.dart';

import 'app_database.dart';

/// Woher der Beginn einer Phase stammt.
///
/// Die Geräteuhr scheidet als Anker aus — sie geht nachweislich falsch. Bleibt
/// die App-Zeit beim Anlegen oder ein Datum, das der Nutzer selbst setzt.
enum PhaseAnchor {
  /// Beim Anlegen der Phase, aus der Uhr des Telefons.
  jetzt,

  /// Rückwirkend gesetzt und vom Nutzer bestätigt.
  bestaetigt,
}

const String _join = 'join';
const String _split = 'split';

/// Zugriff auf die Entscheidungen des Nutzers und seine Phasen.
class OccasionRepository {
  OccasionRepository(this._db);

  final AppDatabase _db;

  // ── Messanlässe ───────────────────────────────────────────────────────

  /// Messungen, die der Nutzer an ihren Vorgänger angeschlossen hat.
  Future<Set<int>> confirmedJoins(int userSlot) =>
      _decisions(userSlot, _join);

  /// Messungen, die der Nutzer von ihrem Vorgänger getrennt hat.
  Future<Set<int>> confirmedSplits(int userSlot) =>
      _decisions(userSlot, _split);

  Future<Set<int>> _decisions(int userSlot, String art) async {
    _requireSlot(userSlot);
    final rows = await (_db.select(_db.occasionDecisions)
          ..where((d) => d.userSlot.equals(userSlot) & d.decision.equals(art)))
        .get();
    return {for (final r in rows) r.deviceSequence};
  }

  /// Diese Messung gehört zum selben Anlass wie ihr Vorgänger.
  Future<void> confirmJoin({
    required int userSlot,
    required int deviceSequence,
  }) =>
      _decide(userSlot, deviceSequence, _join);

  /// Diese Messung beginnt einen neuen Anlass.
  Future<void> confirmSplit({
    required int userSlot,
    required int deviceSequence,
  }) =>
      _decide(userSlot, deviceSequence, _split);

  /// Die spätere Entscheidung ersetzt die frühere — es gibt je Messung
  /// genau eine, sonst wäre der Zustand widersprüchlich.
  Future<void> _decide(int userSlot, int deviceSequence, String art) async {
    _requireSlot(userSlot);
    final eintrag = OccasionDecisionsCompanion.insert(
      userSlot: userSlot,
      deviceSequence: deviceSequence,
      decision: art,
      decidedAt: DateTime.now(),
    );
    // Der Konflikt muss auf (userSlot, deviceSequence) aufgelöst werden, nicht
    // auf der laufenden Kennung: Es gibt je Messung genau eine Entscheidung,
    // und die spätere ersetzt die frühere.
    await _db.into(_db.occasionDecisions).insert(
          eintrag,
          onConflict: DoUpdate(
            (_) => eintrag,
            target: [
              _db.occasionDecisions.userSlot,
              _db.occasionDecisions.deviceSequence,
            ],
          ),
        );
  }

  /// Nimmt eine Entscheidung zurück; danach gilt wieder der Vorschlag.
  Future<void> clearDecision({
    required int userSlot,
    required int deviceSequence,
  }) async {
    _requireSlot(userSlot);
    await (_db.delete(_db.occasionDecisions)
          ..where((d) =>
              d.userSlot.equals(userSlot) &
              d.deviceSequence.equals(deviceSequence)))
        .go();
  }

  // ── Phasen ────────────────────────────────────────────────────────────

  /// Alle Phasen, die zuletzt begonnene zuerst.
  Future<List<Phase>> phases() {
    final query = _db.select(_db.phases)
      ..orderBy([(p) => OrderingTerm.desc(p.beginsAt)]);
    return query.get();
  }

  /// Legt eine Phase an und liefert ihre Kennung.
  ///
  /// Bei [PhaseAnchor.jetzt] erzeugt das Repository den Beginn selbst — dann
  /// darf [begin] nicht gesetzt sein. Sonst könnte jeder Aufrufer ein
  /// beliebiges Datum als „jetzt" ausgeben, und die Herkunftsangabe wäre eine
  /// Lüge, die dauerhaft in der Datenbank steht.
  ///
  /// Bei [PhaseAnchor.bestaetigt] ist [begin] Pflicht: Ein bestätigtes Datum
  /// ohne Datum gibt es nicht.
  Future<int> startPhase({
    required String name,
    required PhaseAnchor anchor,
    DateTime? begin,
  }) async {
    final sauber = name.trim();
    if (sauber.isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'eine Phase ohne Namen ist kein Lebensabschnitt, sondern ein '
            'Kalenderfilter — und den gibt es schon',
      );
    }

    final DateTime beginn;
    switch (anchor) {
      case PhaseAnchor.jetzt:
        if (begin != null) {
          throw ArgumentError.value(
            begin,
            'begin',
            'bei PhaseAnchor.jetzt setzt das Repository den Zeitpunkt selbst — '
                'ein übergebener Wert würde die Herkunftsangabe verfälschen',
          );
        }
        beginn = DateTime.now();
      case PhaseAnchor.bestaetigt:
        if (begin == null) {
          throw ArgumentError.notNull('begin');
        }
        beginn = begin;
    }

    return _db.into(_db.phases).insert(
          PhasesCompanion.insert(
            name: sauber,
            beginsAt: beginn,
            anchor: anchor.name,
            createdAt: DateTime.now(),
          ),
        );
  }

  /// Beendet eine laufende Phase.
  ///
  /// Wirft, wenn es die Phase nicht gibt oder das Ende vor dem Beginn liegt.
  /// Ein stilles Nichts wäre von einem erfolgreichen Beenden nicht zu
  /// unterscheiden.
  Future<void> endPhase(int id, {required DateTime at}) async {
    final phase = await (_db.select(_db.phases)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    if (phase == null) {
      throw StateError('Phase $id gibt es nicht.');
    }
    if (phase.endsAt != null) {
      // Ein zweiter Aufruf — etwa durch einen Doppeltipp — würde sonst eine
      // aufgezeichnete Phasengrenze stillschweigend verschieben.
      throw StateError(
        'Phase $id ist bereits am ${phase.endsAt} beendet worden.',
      );
    }
    if (at.isBefore(phase.beginsAt)) {
      throw ArgumentError.value(
        at,
        'at',
        'liegt vor dem Beginn der Phase (${phase.beginsAt})',
      );
    }
    await (_db.update(_db.phases)..where((p) => p.id.equals(id)))
        .write(PhasesCompanion(endsAt: Value(at)));
  }

  /// Löscht eine Phase. Die Messungen bleiben unberührt — sie gehörten ihr
  /// nie, sie fielen nur in ihren Zeitraum.
  Future<void> deletePhase(int id) async {
    await (_db.delete(_db.phases)..where((p) => p.id.equals(id))).go();
  }

  static void _requireSlot(int userSlot) {
    if (userSlot != 1 && userSlot != 2) {
      throw ArgumentError.value(userSlot, 'userSlot', 'muss 1 oder 2 sein');
    }
  }
}
