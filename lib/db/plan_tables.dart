import 'package:drift/drift.dart';

@DataClassName('MeasurementPlan')
@TableIndex.sql(
  'CREATE UNIQUE INDEX one_open_plan_per_slot ON measurement_plans (user_slot) WHERE ended_at IS NULL',
)
class MeasurementPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userSlot => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  @override
  List<String> get customConstraints => ['CHECK(user_slot IN (1,2))'];
}

@DataClassName('PlanRevision')
class PlanRevisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(MeasurementPlans, #id)();
  DateTimeColumn get effectiveAt => dateTime()();
  BoolColumn get enabled => boolean()();
}

@DataClassName('PlanTime')
class PlanTimes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get revisionId => integer().references(PlanRevisions, #id)();
  IntColumn get minuteOfDay => integer()();
  @override
  List<Set<Column>> get uniqueKeys => [
    {revisionId, minuteOfDay},
  ];
  @override
  List<String> get customConstraints => [
    'CHECK(minute_of_day BETWEEN 0 AND 1439)',
  ];
}

@DataClassName('PlanOccurrence')
class PlanOccurrences extends Table {
  TextColumn get occurrenceKey => text()();
  IntColumn get revisionId => integer().references(PlanRevisions, #id)();
  DateTimeColumn get dueAt => dateTime().nullable()();
  TextColumn get localDate => text()();
  IntColumn get minuteOfDay => integer()();
  TextColumn get zoneId => text().nullable()();
  BoolColumn get timeAmbiguous => boolean()();
  @override
  Set<Column> get primaryKey => {occurrenceKey};
  @override
  List<String> get customConstraints => [
    'CHECK(minute_of_day BETWEEN 0 AND 1439)',
    'CHECK((due_at IS NOT NULL AND zone_id IS NOT NULL) OR '
        '(due_at IS NULL AND zone_id IS NULL AND time_ambiguous = 1))',
  ];
}

@DataClassName('PlanAssignmentOverride')
class PlanAssignmentOverrides extends Table {
  IntColumn get userSlot => integer()();
  IntColumn get deviceSequence => integer()();
  TextColumn get occurrenceKey =>
      text().nullable().references(PlanOccurrences, #occurrenceKey)();
  DateTimeColumn get decidedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {userSlot, deviceSequence};
  @override
  List<Set<Column>> get uniqueKeys => [
    {occurrenceKey},
  ];
}

@DataClassName('ReminderSyncState')
class ReminderSync extends Table {
  IntColumn get id => integer()();
  IntColumn get desiredGeneration => integer()();
  IntColumn get appliedGeneration => integer().nullable()();
  TextColumn get lastError => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK(id=1)',
    'CHECK(desired_generation>=0)',
  ];
}

@DataClassName('PlanTimeChange')
class PlanTimeChanges extends Table {
  TextColumn get eventId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get oldZoneId => text().nullable()();
  TextColumn get newZoneId => text()();
  @override
  Set<Column> get primaryKey => {eventId};
}
