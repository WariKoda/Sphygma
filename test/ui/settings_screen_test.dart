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

  Future<void> boot() async {
    await keyStore.save(Uint8List(16));
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
    await controller.setUserSlot(1);
  }

  Future<void> pumpWith(
    WidgetTester tester,
    ThemeVariant v, {
    String title = 'Einstellungen',
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: SphygmaThemeScope(
            theme: themeFor(v),
            child: SettingsScreen(controller: controller, title: title),
          ),
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

  testWidgets('sagt, dass ein Konzeptwechsel keine Messung anfasst',
      (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    // Der Wechsel darf sich nicht anfühlen wie ein Datenverlust.
    expect(find.textContaining('Keine Messung wird dabei kopiert'),
        findsOneWidget);
  });

  testWidgets('jedes Konzept darf das Blatt in seiner Sprache benennen',
      (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument,
        title: 'Wochen-Einstellungen');

    expect(find.text('Wochen-Einstellungen'), findsOneWidget);
  });
}
