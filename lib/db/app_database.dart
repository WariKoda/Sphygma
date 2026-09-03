// Lokale Persistenz (M4). Die lokale DB ist Source of Truth; Health Connect
// ist eine reine Export-Senke (CLAUDE.md, PLAN.md §4).
import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Eine vom Geraet gelesene Messung.
///
/// Dedup-Schluessel ist (userSlot, deviceSequence) - die laufende
/// Messungsnummer des Geraets, nicht der Zeitstempel, weil die Geraeteuhr
/// nachweislich falsch gehen kann (docs/protocol/hem-6232t.md §6.3, §8.2).
@DataClassName('Measurement')
class Measurements extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 1 oder 2, wie am Geraet beschriftet.
  IntColumn get userSlot => integer()();

  /// Laufende Messungsnummer des Geraets (Record-Bytes 9-11).
  IntColumn get deviceSequence => integer()();

  IntColumn get systolic => integer()();
  IntColumn get diastolic => integer()();
  IntColumn get pulse => integer()();

  /// Zeitstempel laut Geraeteuhr - nur so plausibel wie die Uhr.
  DateTimeColumn get measuredAt => dateTime()();

  BoolColumn get movement => boolean()();
  BoolColumn get arrhythmia => boolean()();

  /// Die 14 Rohbytes des Records, fuer Nachvollziehbarkeit und spaetere
  /// Auswertung der noch ungeklaerten Bytes.
  BlobColumn get rawBytes => blob()();

  DateTimeColumn get importedAt => dateTime()();

  /// Gesetzt, sobald der Datensatz nach Health Connect geschrieben wurde.
  DateTimeColumn get exportedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userSlot, deviceSequence},
      ];
}

/// Schluessel/Wert-Einstellungen der App (z. B. der gewaehlte User-Slot).
@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Measurements, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(appSettings);
          }
        },
      );
}
