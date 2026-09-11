import '../db/app_database.dart';

typedef MeasurementKey = ({int userSlot, int deviceSequence});

class MeasurementMetadata {
  MeasurementMetadata({required this.note, required Set<int> tagIds})
    : tagIds = Set.unmodifiable(tagIds);
  final String? note;
  final Set<int> tagIds;
}

abstract interface class MetadataStore {
  Future<Map<int, MeasurementMetadata>> readSlot(int userSlot);
  Future<List<MeasurementTag>> tags(int userSlot);
  Future<int> createTag(int userSlot, String name);
  Future<void> renameTag(int tagId, String name);
  Future<void> deleteTag(int tagId);
  Future<void> save(
    MeasurementKey key, {
    required String? note,
    required Set<int> tagIds,
  });
  Future<void> addTags(Set<MeasurementKey> keys, Set<int> tagIds);
}

abstract interface class PhaseStore {
  Future<List<ScopedPhase>> phases(int userSlot);
  Future<int> savePhase({
    int? id,
    required int userSlot,
    required String name,
    required DateTime begin,
    required DateTime? end,
  });
  Future<void> deletePhase(int id);
  Future<Map<int, Set<int>>> selections(int userSlot);
  Future<void> select(MeasurementKey key, Set<int> phaseIds);
  Future<void> useAutomatic(MeasurementKey key);
}
