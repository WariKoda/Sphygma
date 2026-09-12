import 'package:drift/drift.dart';

/// Vom Nutzer bestaetigte Entscheidungen ueber Messanlaesse.
///
/// Historische Tabelle der entfernten Messanlass-Oberfläche. Die Daten bleiben
/// für verlustfreie Upgrades erhalten, werden aber nicht mehr ausgewertet.
@DataClassName('OccasionDecision')
class OccasionDecisions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 1 oder 2, wie am Geraet beschriftet. Der Zaehler laeuft je Platz.
  IntColumn get userSlot => integer()();

  /// Die Messung, ueber deren Anschluss an ihren Vorgaenger entschieden wurde.
  IntColumn get deviceSequence => integer()();

  /// 'join' oder 'split' — angeschlossen oder getrennt.
  TextColumn get decision => text()();

  DateTimeColumn get decidedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {userSlot, deviceSequence},
  ];
}

/// Ein benannter Lebensabschnitt, gegen den Messungen verglichen werden.
///
/// Nur das Konzept „Phase" nutzt sie; die Tabelle bleibt leer, solange
/// niemand eine anlegt. Ein Kalenderfilter sagt nicht, warum sich etwas
/// geaendert hat — ein Name schon.
@DataClassName('Phase')
class Phases extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Frei vergeben: „Ramipril 5 mg", „Urlaub", „nach der Umstellung".
  TextColumn get name => text()();

  DateTimeColumn get beginsAt => dateTime()();

  /// Null, solange die Phase laeuft.
  DateTimeColumn get endsAt => dateTime().nullable()();

  /// Woher der Beginn stammt: 'jetzt' (App-Zeit beim Anlegen) oder
  /// 'bestaetigt' (vom Nutzer gesetztes Datum). Die Quelle gehoert dazu,
  /// weil die Geraeteuhr als Anker ausscheidet.
  TextColumn get anchor => text()();

  DateTimeColumn get createdAt => dateTime()();
}

/// Welcher Phase eine Messung angehört, wenn der Zeitraum es nicht klärt.
///
/// Die meisten Messungen brauchen keinen Eintrag: Ihr Zeitstempel liegt
/// eindeutig in einer Phase. Ein Eintrag entsteht nur, wo der Mensch
/// entschieden hat — weil die Geräteuhr falsch ging oder weil er eine
/// Messung ausdrücklich außen vor lassen wollte.
///
/// [phaseId] darf null sein. Das ist kein fehlender Wert, sondern eine
/// Aussage: „gehört zu keiner Phase, und das ist entschieden."
@DataClassName('PhaseAssignment')
class PhaseAssignments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userSlot => integer()();
  IntColumn get deviceSequence => integer()();
  IntColumn get phaseId => integer().nullable().references(Phases, #id)();
  DateTimeColumn get decidedAt => dateTime()();

  /// Eine Messung hat höchstens eine primäre Phase. Ohne diese Grenze ginge
  /// dieselbe Messung in konkurrierende Vergleiche ein.
  @override
  List<Set<Column>> get uniqueKeys => [
    {userSlot, deviceSequence},
  ];
}
