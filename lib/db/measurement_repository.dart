// Zugriff auf die Messungen. Dedup ueber (userSlot, deviceSequence) - die
// Messungsnummer des Geraets, siehe app_database.dart.
import 'package:drift/drift.dart';

import '../protocol/readout.dart';
import 'app_database.dart';

class MeasurementRepository {
  MeasurementRepository(this._db);

  final AppDatabase _db;

  /// Importiert einen Voll-Readout. Bereits vorhandene Messungen (gleicher
  /// Slot, gleiche Messungsnummer) werden uebersprungen. Liefert die Zahl
  /// der neu angelegten Datensaetze.
  Future<int> importAll(List<SlotRecord> records) {
    return _db.transaction(() async {
      final now = DateTime.now();
      var inserted = 0;
      for (final slotRecord in records) {
        final r = slotRecord.record;
        final companion = MeasurementsCompanion.insert(
          userSlot: slotRecord.userSlot,
          deviceSequence: r.sequence,
          systolic: r.systolic,
          diastolic: r.diastolic,
          pulse: r.pulse,
          measuredAt: r.timestamp,
          movement: r.movementFlag,
          arrhythmia: r.arrhythmiaFlag,
          rawBytes: slotRecord.rawBytes,
          importedAt: now,
        );
        // insertOrIgnore laesst den UNIQUE-Konflikt still fallen; ob wirklich
        // eingefuegt wurde, entscheidet die Existenzpruefung davor - so ist
        // der Rueckgabewert eindeutig, statt an der Deutung der rowid zu
        // haengen.
        final exists = await _exists(slotRecord.userSlot, r.sequence);
        if (exists) continue;
        await _db
            .into(_db.measurements)
            .insert(companion, mode: InsertMode.insertOrIgnore);
        inserted++;
      }
      return inserted;
    });
  }

  Future<bool> _exists(int userSlot, int deviceSequence) async {
    final query = _db.select(_db.measurements)
      ..where(
        (m) =>
            m.userSlot.equals(userSlot) &
            m.deviceSequence.equals(deviceSequence),
      );
    return await query.getSingleOrNull() != null;
  }

  /// Hoechste bekannte Messungsnummer eines Slots, oder null, wenn dort
  /// noch nichts gespeichert ist.
  ///
  /// Gegenstueck zu der Nummer, die das Geraet im Advertising mitsendet
  /// (docs/protocol/hem-6232t.md §2.1). Liegt die dortige Nummer hoeher,
  /// gibt es neue Messungen zu holen.
  ///
  /// Null statt 0: Ein Slot ohne Messungen ist etwas anderes als ein Slot,
  /// dessen hoechste Nummer 0 ist, und ein Ersatzwert wuerde einen Sync
  /// ausloesen, der nichts findet.
  Future<int?> highestSequenceFor(int userSlot) async {
    final sequence = _db.measurements.deviceSequence;
    final query = _db.selectOnly(_db.measurements)
      ..addColumns([sequence.max()])
      ..where(_db.measurements.userSlot.equals(userSlot));
    final row = await query.getSingleOrNull();
    return row?.read(sequence.max());
  }

  /// Die Aufnahmegrenze eines Speicherplatzes, oder null.
  ///
  /// Beim Koppeln entscheidet der Nutzer, was von dem, was schon auf dem
  /// Gerät liegt, übernommen wird. Alles **unterhalb** dieser Messungsnummer
  /// wird nie angezeigt und nie nach Health Connect übertragen.
  ///
  /// **Eine Grenze statt vieler Markierungen**, und **die Messungsnummer
  /// statt eines Datums**: Die Nummer zählt am Gerät monoton weiter, auch
  /// nach „alle Daten löschen" (docs/protocol/hem-6232t.md §8.3), während die
  /// Geräteuhr nachweislich falsch geht. Eine Grenze ist damit stabil,
  /// umkehrbar und überlebt einen erneuten Voll-Readout.
  ///
  /// Gelesen wird sie hier und nicht im Steuerungsteil, damit sie niemand
  /// vergessen kann: Jede Abfrage, die Messungen **zum Anzeigen oder
  /// Übertragen** liefert, filtert sie mit.
  Future<int?> intakeFloor(int userSlot) async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(intakeFloorKey(userSlot))))
        .getSingleOrNull();
    return row == null ? null : int.parse(row.value);
  }

  /// Der Einstellungsschlüssel der Aufnahmegrenze eines Speicherplatzes.
  static String intakeFloorKey(int userSlot) => 'intake_floor_$userSlot';

  /// Setzt die Aufnahmegrenze. Null hebt sie auf — dann ist wieder alles
  /// sichtbar, was auf dem Gerät steht.
  Future<void> setIntakeFloor(int userSlot, int? sequence) async {
    if (sequence == null) {
      await (_db.delete(_db.appSettings)
            ..where((s) => s.key.equals(intakeFloorKey(userSlot))))
          .go();
      return;
    }
    await _db
        .into(_db.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            key: intakeFloorKey(userSlot),
            value: '$sequence',
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Die kleinste Messungsnummer, die ab einem Zeitpunkt gemessen wurde.
  ///
  /// So wird aus der Wahl „ab diesem Datum" **einmal** eine Grenze in
  /// Messungsnummern. Danach hängt sie nicht mehr an Zeitstempeln, die das
  /// Gerät falsch schreibt. Null heißt: Es gibt keine Messung ab dann — die
  /// Grenze liegt dann über allem Bekannten.
  Future<int?> firstSequenceFrom(int userSlot, DateTime ab) async {
    final sequence = _db.measurements.deviceSequence;
    final query = _db.selectOnly(_db.measurements)
      ..addColumns([sequence.min()])
      ..where(
        _db.measurements.userSlot.equals(userSlot) &
            _db.measurements.measuredAt.isBiggerOrEqualValue(ab),
      );
    final row = await query.getSingleOrNull();
    return row?.read(sequence.min());
  }

  /// Alle Messungen eines Slots, aelteste zuerst.
  Future<List<Measurement>> allForSlot(int userSlot) async {
    final floor = await intakeFloor(userSlot);
    final query = _db.select(_db.measurements)
      ..where(
        (m) => floor == null
            ? m.userSlot.equals(userSlot)
            : m.userSlot.equals(userSlot) &
                  m.deviceSequence.isBiggerOrEqualValue(floor),
      )
      ..orderBy([
        // Nach Datum, wie am Geraet abgelesen. Der Gerätezähler dient dem
        // Dedup und der Uhr-Prüfung, nicht der Anzeige-Reihenfolge; bei
        // gleichem Zeitstempel entscheidet er dennoch, damit die Reihenfolge
        // eindeutig bleibt.
        (m) => OrderingTerm.asc(m.measuredAt),
        (m) => OrderingTerm.asc(m.deviceSequence),
      ]);
    return query.get();
  }

  /// Noch nicht nach Health Connect exportierte Messungen eines Slots.
  Future<List<Measurement>> pendingExport(int userSlot) async {
    final floor = await intakeFloor(userSlot);
    final query = _db.select(_db.measurements)
      ..where(
        (m) => floor == null
            ? m.userSlot.equals(userSlot) & m.exportedAt.isNull()
            : m.userSlot.equals(userSlot) & m.exportedAt.isNull() &
                  m.deviceSequence.isBiggerOrEqualValue(floor),
      )
      ..orderBy([
        // Nach Datum, wie am Geraet abgelesen. Der Gerätezähler dient dem
        // Dedup und der Uhr-Prüfung, nicht der Anzeige-Reihenfolge; bei
        // gleichem Zeitstempel entscheidet er dennoch, damit die Reihenfolge
        // eindeutig bleibt.
        (m) => OrderingTerm.asc(m.measuredAt),
        (m) => OrderingTerm.asc(m.deviceSequence),
      ]);
    return query.get();
  }

  /// Bereits nach Health Connect exportierte Messungen eines Slots.
  Future<List<Measurement>> exported(int userSlot) async {
    final floor = await intakeFloor(userSlot);
    final query = _db.select(_db.measurements)
      ..where(
        (m) => floor == null
            ? m.userSlot.equals(userSlot) & m.exportedAt.isNotNull()
            : m.userSlot.equals(userSlot) & m.exportedAt.isNotNull() &
                  m.deviceSequence.isBiggerOrEqualValue(floor),
      )
      ..orderBy([
        // Nach Datum, wie am Geraet abgelesen. Der Gerätezähler dient dem
        // Dedup und der Uhr-Prüfung, nicht der Anzeige-Reihenfolge; bei
        // gleichem Zeitstempel entscheidet er dennoch, damit die Reihenfolge
        // eindeutig bleibt.
        (m) => OrderingTerm.asc(m.measuredAt),
        (m) => OrderingTerm.asc(m.deviceSequence),
      ]);
    return query.get();
  }

  /// Hebt die Export-Markierung auf, z. B. nachdem die Datensaetze aus
  /// Health Connect entfernt wurden.
  Future<void> markUnexported(List<int> ids) {
    return _db.transaction(() async {
      for (final id in ids) {
        await (_db.update(_db.measurements)..where((m) => m.id.equals(id)))
            .write(const MeasurementsCompanion(exportedAt: Value(null)));
      }
    });
  }

  Future<void> markExported(List<int> ids, DateTime at) {
    return _db.transaction(() async {
      for (final id in ids) {
        await (_db.update(_db.measurements)..where((m) => m.id.equals(id)))
            .write(MeasurementsCompanion(exportedAt: Value(at)));
      }
    });
  }
}
