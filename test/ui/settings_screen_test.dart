import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/app/concept.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/occasion_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/settings_screen.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

void main() {
  late AppDatabase db;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  Future<void> boot({bool paired = true, bool withSlot = true}) async {
    if (paired) await keyStore.save(Uint8List(16));
    final repository = MeasurementRepository(db);
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      occasionRepository: OccasionRepository(db),
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    if (paired && withSlot) await controller.setUserSlot(1);
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) =>
      tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              SphygmaThemeScope(theme: themeFor(v), child: child!),
          home: SettingsScreen(controller: controller),
        ),
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    keyStore = InMemoryPairingKeyStore();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  group('in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('baut ohne Fehler (${v.name})', (tester) async {
        await boot();

        await pumpWith(tester, v);

        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('Konzept und Gestaltung stehen beide zur Wahl', (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    // Zwei freie Achsen: Ordnung und Aussehen.
    // SectionHeader setzt den Titel in Großbuchstaben.
    expect(find.text('KONZEPT'), findsOneWidget);
    expect(find.text('GESTALTUNG'), findsOneWidget);
    for (final k in allConcepts) {
      expect(find.text(k.label), findsOneWidget, reason: k.name);
    }
  });

  testWidgets('das Konzept lässt sich umschalten', (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.ensureVisible(find.text('Tagesprofil'));
    await tester.tap(find.text('Tagesprofil'));
    await tester.pumpAndSettle();

    expect(controller.concept, AppConcept.tagesprofil);
  });

  testWidgets('die Gestaltung lässt sich umschalten', (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.ensureVisible(find.text('Tagebuch'));
    await tester.tap(find.text('Tagebuch'));
    await tester.pumpAndSettle();

    expect(controller.themeVariant, ThemeVariant.diary);
  });

  testWidgets('sagt, dass ein Konzeptwechsel keine Messung anfasst', (
    tester,
  ) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    // Der Wechsel darf sich nicht anfühlen wie ein Datenverlust.
    expect(
      find.textContaining('Keine Messung wird dabei kopiert'),
      findsOneWidget,
    );
  });

  // Kopplung und Speicherplatz sind am 08.09.2026 aus dem Gerätebereich
  // hierher gezogen: Sie sind Entscheidungen, keine Handlungen. Die Tests
  // sind mitgewandert.

  testWidgets('ohne Kopplung fuehrt der Knopf zum Koppeln', (tester) async {
    await boot(paired: false);

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('Koppeln'), findsOneWidget);
  });

  testWidgets('die Speicherplatzwahl erscheint nur ohne Kopplung', (
    tester,
  ) async {
    await boot(paired: false, withSlot: false);

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('Benutzer 1'), findsOneWidget);
  });

  testWidgets('ohne gewählten Slot ist keiner ausgewählt und Slot 1 lässt '
      'sich mit einem Tipp wählen', (tester) async {
    await boot(paired: false, withSlot: false);

    await pumpWith(tester, ThemeVariant.instrument);

    final button = tester.widget<SegmentedButton<int>>(
      find.byType(SegmentedButton<int>),
    );
    expect(button.selected, isEmpty);

    await tester.tap(find.text('Benutzer 1'));
    await tester.pumpAndSettle();

    expect(controller.userSlot, 1);
  });

  testWidgets('gekoppelt ist die Speicherplatzwahl verdeckt, "Neu koppeln" '
      'holt sie zurück', (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);
    expect(find.byType(SegmentedButton<int>), findsNothing);

    await tester.ensureVisible(find.text('Neu koppeln'));
    await tester.tap(find.text('Neu koppeln'));
    await tester.pumpAndSettle();

    expect(find.byType(SegmentedButton<int>), findsOneWidget);
    expect(find.text('Koppeln'), findsOneWidget);
  });
}
