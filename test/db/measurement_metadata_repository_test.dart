import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_metadata_repository.dart';

Future<void> seedMetadataMeasurements(AppDatabase db) async {
  for (final slot in [1, 2]) {
    for (final sequence in [10, 11]) {
      await db
          .into(db.measurements)
          .insert(
            MeasurementsCompanion.insert(
              userSlot: slot,
              deviceSequence: sequence,
              systolic: 123,
              diastolic: 82,
              pulse: 65,
              measuredAt: DateTime(2026, 9, 11, 8),
              movement: false,
              arrhythmia: false,
              rawBytes: Uint8List.fromList([slot, sequence]),
              importedAt: DateTime(2026, 9, 11, 9),
            ),
          );
    }
  }
}

void main() {
  late AppDatabase db;
  late MeasurementMetadataRepository repo;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = MeasurementMetadataRepository(db);
    await seedMetadataMeasurements(db);
  });
  tearDown(() => db.close());
  const key = (userSlot: 1, deviceSequence: 10);

  test('Tags werden pro Slot normalisiert wiederverwendet', () async {
    final a = await repo.createTag(1, ' Sport ');
    expect(await repo.createTag(1, 'SPORT'), a);
    expect(await repo.createTag(2, 'Sport'), isNot(a));
    expect((await repo.tags(1)).single.name, 'Sport');
  });

  test(
    'Speichern ersetzt, Batch vereinigt; Umbenennen erhält Zuordnungen',
    () async {
      final a = await repo.createTag(1, 'Sport');
      final b = await repo.createTag(1, 'Ruhe');
      await repo.save(key, note: 'nach Sport', tagIds: {a});
      await repo.addTags({key, (userSlot: 1, deviceSequence: 11)}, {b});
      await repo.renameTag(a, 'Bewegung');
      expect((await repo.readSlot(1))[10]!.tagIds, {a, b});
      expect((await repo.readSlot(1))[10]!.note, 'nach Sport');
      expect((await repo.readSlot(1))[11]!.tagIds, {b});
      await repo.save(key, note: '', tagIds: {b});
      expect((await repo.readSlot(1))[10]!.note, isNull);
      expect((await repo.readSlot(1))[10]!.tagIds, {b});
      await repo.deleteTag(b);
      expect(await repo.readSlot(1), isEmpty);
      expect(await db.select(db.measurements).get(), hasLength(4));
    },
  );

  test('ungültiger Batch und fremde IDs verändern nichts', () async {
    final a = await repo.createTag(1, 'A');
    final foreign = await repo.createTag(2, 'B');
    await repo.save(key, note: 'bleibt', tagIds: {a});
    await expectLater(
      repo.save(key, note: 'verloren', tagIds: {foreign}),
      throwsArgumentError,
    );
    await expectLater(
      repo.addTags({key, (userSlot: 1, deviceSequence: 999)}, {a}),
      throwsStateError,
    );
    await expectLater(
      repo.addTags({key, (userSlot: 2, deviceSequence: 10)}, {a}),
      throwsArgumentError,
    );
    expect((await repo.readSlot(1))[10]!.note, 'bleibt');
    expect((await repo.readSlot(1))[10]!.tagIds, {a});
    expect(await repo.readSlot(2), isEmpty);
  });

  test(
    'Längen, unbekannte IDs, Slots und Namenskollision werden abgewiesen',
    () async {
      final a = await repo.createTag(1, 'A');
      final b = await repo.createTag(1, 'B');
      await expectLater(repo.renameTag(b, ' a '), throwsArgumentError);
      await expectLater(repo.createTag(1, '   '), throwsArgumentError);
      await expectLater(repo.createTag(1, 'x' * 41), throwsArgumentError);
      await expectLater(repo.createTag(0, 'A'), throwsArgumentError);
      await expectLater(repo.readSlot(3), throwsArgumentError);
      await expectLater(repo.deleteTag(999), throwsStateError);
      await expectLater(
        repo.save(key, note: 'x' * 4001, tagIds: {a}),
        throwsArgumentError,
      );
      expect(await repo.readSlot(1), isEmpty);
    },
  );

  test('Metadaten überleben das Wiederöffnen einer echten Datei', () async {
    final dir = await Directory.systemTemp.createTemp('sphygma-tags-');
    final file = File('${dir.path}/db');
    final first = AppDatabase(NativeDatabase(file));
    await seedMetadataMeasurements(first);
    final store = MeasurementMetadataRepository(first);
    final tag = await store.createTag(1, 'Ruhe');
    await store.save(key, note: 'dauerhaft', tagIds: {tag});
    await first.close();
    final second = AppDatabase(NativeDatabase(file));
    try {
      final data = await MeasurementMetadataRepository(second).readSlot(1);
      expect(data[10]!.note, 'dauerhaft');
      expect(data[10]!.tagIds, {tag});
    } finally {
      await second.close();
      await dir.delete(recursive: true);
    }
  });
}
