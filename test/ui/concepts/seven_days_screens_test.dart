import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/stats/measurement_week.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/concepts/seven_days/earlier_weeks_screen.dart';
import 'package:sphygma/ui/concepts/seven_days/week_detail_screen.dart';
import 'package:sphygma/ui/concepts/seven_days/week_range_screen.dart';
import 'package:sphygma/ui/format.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _rec(int seq, DateTime at, {int sys = 124, int dia = 82}) =>
    SlotRecord(
      userSlot: 1,
      record: BloodPressureRecord(
        systolic: sys,
        diastolic: dia,
        pulse: 78,
        timestamp: at,
        arrhythmiaFlag: false,
        movementFlag: false,
        sequence: seq,
      ),
      rawBytes: Uint8List(14),
    );

/// Alle Testwochen liegen vor der laufenden — so ist keine Messung in der
/// Zukunft, egal wann der Test läuft.
final _juengsterMontag = previousMonday(mondayOf(DateTime.now()));

DateTime _in(DateTime montag, int versatz, int stunde) =>
    DateTime(montag.year, montag.month, montag.day + versatz, stunde);

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;
  var seq = 1;

  Future<void> boot() async {
    await keyStore.save(Uint8List(16));
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    await controller.setUserSlot(1);
  }

  /// Eine volle Woche: sieben Tage, morgens und abends.
  List<SlotRecord> volleWoche(DateTime montag, {int sys = 124}) => [
        for (var tag = 0; tag < 7; tag++) ...[
          _rec(seq++, _in(montag, tag, 7), sys: sys - 3),
          _rec(seq++, _in(montag, tag, 20), sys: sys + 3),
        ],
      ];

  Widget mit(Widget child) => MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.instrument),
          child: child,
        ),
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    keyStore = InMemoryPairingKeyStore();
    seq = 1;
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  group('Frühere Wochen', () {
    testWidgets('listet die Wochen mit ihrer Vollständigkeit', (tester) async {
      await boot();
      final vorige = previousMonday(_juengsterMontag);
      await repository.importAll([
        ...volleWoche(_juengsterMontag),
        _rec(seq++, _in(vorige, 0, 7)),
        _rec(seq++, _in(vorige, 1, 7)),
      ]);
      await controller.refreshForTest();

      await tester.pumpWidget(mit(EarlierWeeksScreen(controller: controller)));

      expect(find.text('14 von 14'), findsOneWidget);
      expect(find.text('2 von 14'), findsOneWidget);
    });

    testWidgets('eine Woche führt in ihr Detail', (tester) async {
      await boot();
      await repository.importAll(volleWoche(_juengsterMontag));
      await controller.refreshForTest();

      await tester.pumpWidget(mit(EarlierWeeksScreen(controller: controller)));
      await tester.tap(find.text('14 von 14'));
      await tester.pumpAndSettle();

      expect(find.text('Vollständig gemessen'), findsOneWidget);
    });
  });

  group('Eine Woche im Detail', () {
    testWidgets('sagt, dass der erste Tag nicht in den Schnitt zählt',
        (tester) async {
      await boot();
      await repository.importAll(volleWoche(_juengsterMontag));
      await controller.refreshForTest();
      final woche = buildWeeks(controller.measurements).single;

      await tester.pumpWidget(mit(
        WeekDetailScreen(controller: controller, week: woche),
      ));

      expect(find.textContaining('Mittel ohne den ersten Tag'), findsOneWidget);
      expect(find.textContaining('Über alle sieben Tage'), findsOneWidget);
    });

    testWidgets('listet alle Messungen der Woche', (tester) async {
      await boot();
      await repository.importAll(volleWoche(_juengsterMontag));
      await controller.refreshForTest();
      final woche = buildWeeks(controller.measurements).single;

      await tester.pumpWidget(mit(
        WeekDetailScreen(controller: controller, week: woche),
      ));

      expect(find.text('ALLE MESSUNGEN DIESER WOCHE'), findsOneWidget);
    });
  });

  group('Wochen auswerten', () {
    testWidgets('nimmt als Vorgabe die zusammenhängende Folge', (tester) async {
      await boot();
      final w2 = previousMonday(_juengsterMontag);
      final w3 = previousMonday(w2);
      // Eine Lücke davor: diese Woche gehört nicht zur Folge.
      final alt = previousMonday(previousMonday(previousMonday(w3)));
      await repository.importAll([
        ...volleWoche(alt, sys: 140),
        ...volleWoche(w3, sys: 130),
        ...volleWoche(w2, sys: 127),
        ...volleWoche(_juengsterMontag, sys: 124),
      ]);
      await controller.refreshForTest();

      await tester.pumpWidget(mit(WeekRangeScreen(controller: controller)));

      // Drei zusammenhängende Wochen, die vierte liegt hinter einer Lücke.
      expect(find.textContaining('Gemeinsames Mittel aus 3 Wochen'),
          findsOneWidget);
    });

    testWidgets('der Trend nennt beide Werte, aus denen er entsteht',
        (tester) async {
      await boot();
      final w2 = previousMonday(_juengsterMontag);
      await repository.importAll([
        ...volleWoche(w2, sys: 130),
        ...volleWoche(_juengsterMontag, sys: 124),
      ]);
      await controller.refreshForTest();

      await tester.pumpWidget(mit(WeekRangeScreen(controller: controller)));

      expect(find.text('Systolisch'), findsOneWidget);
      expect(find.textContaining('mmHg'), findsWidgets);
      expect(find.textContaining('von '), findsWidgets);
    });

    testWidgets('leere Wochen im Zeitraum zählen in die Abdeckung mit',
        (tester) async {
      await boot();
      // Zwei volle Wochen mit einer leeren Woche dazwischen. Rechnete die
      // Abdeckung nur über die vorhandenen Wochen, sähe sie mit 28 von 28
      // perfekt aus — obwohl eine Woche gar nicht gemessen wurde.
      final davor = previousMonday(previousMonday(_juengsterMontag));
      await repository.importAll([
        ...volleWoche(davor),
        ...volleWoche(_juengsterMontag),
      ]);
      await controller.refreshForTest();

      await tester.pumpWidget(mit(WeekRangeScreen(controller: controller)));

      // Die Vorgabe ist die zusammenhängende Folge — hier also nur die
      // jüngste Woche. Der Bereich wird über die Lücke hinweg aufgezogen.
      expect(find.text('14 von 14 Feldern'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<int>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(formatWeekRange(davor)).last);
      await tester.pumpAndSettle();

      // Zwei gemessene Wochen, dazwischen eine ungemessene: 42 statt 28.
      expect(find.text('28 von 42 Feldern'), findsOneWidget);
      expect(find.textContaining('ohne eine einzige Messung'), findsOneWidget);
    });
  });
}
