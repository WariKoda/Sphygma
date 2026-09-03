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

  /// Alle Messungen eines Slots, aelteste zuerst.
  Future<List<Measurement>> allForSlot(int userSlot) {
    final query = _db.select(_db.measurements)
      ..where((m) => m.userSlot.equals(userSlot))
      ..orderBy([(m) => OrderingTerm.asc(m.deviceSequence)]);
    return query.get();
  }

  /// Noch nicht nach Health Connect exportierte Messungen eines Slots.
  Future<List<Measurement>> pendingExport(int userSlot) {
    final query = _db.select(_db.measurements)
      ..where((m) => m.userSlot.equals(userSlot) & m.exportedAt.isNull())
      ..orderBy([(m) => OrderingTerm.asc(m.deviceSequence)]);
    return query.get();
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
