import 'package:drift/drift.dart';

import '../stats/measurement_metadata.dart';
import 'app_database.dart';

void validateMetadataSlot(int slot) {
  if (slot != 1 && slot != 2) {
    throw ArgumentError.value(slot, 'slot', 'muss 1 oder 2 sein');
  }
}

Future<void> requireMetadataMeasurement(
  AppDatabase db,
  MeasurementKey key,
) async {
  validateMetadataSlot(key.userSlot);
  final row =
      await (db.select(db.measurements)..where(
            (m) =>
                m.userSlot.equals(key.userSlot) &
                m.deviceSequence.equals(key.deviceSequence),
          ))
          .getSingleOrNull();
  if (row == null) throw StateError('Die Messung ist nicht mehr vorhanden.');
}
