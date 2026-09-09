// test/ui/sphygma_app_test.dart
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
import 'package:sphygma/ui/history_screen.dart';
import 'package:sphygma/ui/settings_screen.dart';
import 'package:sphygma/ui/sphygma_app.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/today_screen.dart';

/// Ein hohes Testfenster.
///
/// Seit die gesamte Technik hinter dem Zahnrad steht, ist das
/// Einstellungsblatt sechs Karten lang. Auf der Standardhöhe von 600 Pixeln
/// ist die Hälfte davon nicht gebaut, und jede Prüfung hinge am Scrollen
/// statt an der Sache.
void _hohesFenster(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

// **Warum hier überall `tester.runAsync` steht.**
//
// `testWidgets` läuft in einer Fake-Async-Zone: Echte Ein- und Ausgabe kommt
// dort nur voran, wenn gepumpt wird. Ein Setter des Steuerungsteils schreibt
// aber wirklich in SQLite. Bis zum 08.09.2026 war das je Setter ein einziger
// INSERT, der zufällig durchrutschte; seit die Gestaltung aus drei Achsen
// besteht, sind es mehrere Runden — und der Test blieb ohne `runAsync`
// stehen, ohne zu scheitern. Das ist der dokumentierte Weg für echte
// Asynchronität im Widget-Test, nicht eine Notlösung.
class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    keyStore = InMemoryPairingKeyStore();
    await keyStore.save(Uint8List(16));
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
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  testWidgets('startet auf Heute', (tester) async {
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('wechselt zwischen den Bereichen', (tester) async {
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verlauf'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);

    await tester.tap(find.text('Heute'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('die gewählte Gestaltung liegt über dem Baum', (tester) async {
    await tester.runAsync(
      () => controller.setThemeVariant(ThemeVariant.diary),
    );
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(TodayScreen));
    expect(SphygmaTheme.of(context).name, themeFor(ThemeVariant.diary).name);
  });

  testWidgets('ein Gestaltungswechsel schlägt sofort durch', (tester) async {
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.runAsync(
      () => controller.setThemeVariant(ThemeVariant.material),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(TodayScreen));
    expect(SphygmaTheme.of(context).name, themeFor(ThemeVariant.material).name);
  });

  testWidgets('die Technik bleibt in jedem Konzept erreichbar', (tester) async {
    // Seit dem 08.09.2026 gibt es keinen Reiter „Gerät" mehr: Abgleich,
    // Übertragung, Kopplung und die Wahl von Konzept und Gestaltung stehen
    // gemeinsam hinter dem Zahnrad. Fehlte es in einem Konzept, käme man
    // weder an das Gerät noch aus dem Konzept heraus.
    await tester.runAsync(() => controller.setConcept(AppConcept.phase));
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Jetzt abgleichen'), findsOneWidget);
  });

  testWidgets('eine Meldung des Steuerungsteils erscheint', (tester) async {
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    // Ein Export ohne offene Messungen meldet "0 Messungen" - eine
    // Meldung ohne Geraet und ohne Fehler.
    await controller.exportAll();
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('jedes Konzept trägt den Zugang zur Wahl an derselben Stelle', (
    tester,
  ) async {
    _hohesFenster(tester);
    // Die Konzepte schließen einander aus — ein Zahnrad je Hülle sind
    // deshalb nicht drei Zugänge, sondern einer. Fehlte er in einem, käme
    // man aus diesem Konzept nicht mehr heraus.
    for (final k in allConcepts) {
      await tester.runAsync(() => controller.setConcept(k));
      await tester.pumpWidget(SphygmaApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget, reason: k.name);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('KONZEPT'), findsOneWidget, reason: k.name);
      expect(find.text('GESTALTUNG'), findsOneWidget, reason: k.name);

      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('ein Gestaltungswechsel wirkt sofort, auch im offenen Blatt', (
    tester,
  ) async {
    _hohesFenster(tester);
    // Bis zum 07.09.2026 nahm jede geschobene Route die Gestaltung beim
    // Öffnen mit und hielt sie fest. Wer im Einstellungsblatt die Gestaltung
    // wechselte, sah die Änderung erst nach dem Zurückgehen — ausgerechnet
    // dort, wo man sie beurteilen will.
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('KONZEPT'), findsOneWidget);

    double radiusImBlatt() => tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.borderRadius)
        .whereType<BorderRadius>()
        .map((r) => r.topLeft.x)
        .reduce((a, b) => a > b ? a : b);

    expect(radiusImBlatt(), themeFor(ThemeVariant.instrument).radius);

    await tester.ensureVisible(find.text('Tagebuch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tagebuch'));
    // Ein einzelner Frame, kein pumpAndSettle: Der Tipp löst im Hintergrund
    // einen echten Schreibvorgang aus, den niemand abwartet. In der
    // Fake-Async-Zone kommt der nie zum Ende, und pumpAndSettle liefe bis in
    // seinen Zehn-Minuten-Timeout. Ein Frame ist ohnehin genau das, was hier
    // zu prüfen ist — „wirkt sofort" heißt: beim nächsten Bild, nicht wenn
    // die Datenbank geantwortet hat.
    await tester.pump();
    expect(
      controller.themeVariant,
      ThemeVariant.diary,
      reason: 'der Wechsel selbst muss ankommen',
    );

    // Ohne Zurückgehen: Das Blatt trägt jetzt die Maße der neuen Handschrift.
    expect(
      radiusImBlatt(),
      themeFor(ThemeVariant.diary).radius,
      reason: 'die neue Gestaltung greift erst nach dem Verlassen',
    );

    // Den angestoßenen Schreibvorgang abfließen lassen, bevor der Abbau die
    // Datenbank schließt: `db.close()` wartet sonst auf eine Zusage, die in
    // der Fake-Async-Zone nie kommt, und der Test bliebe im Abbau stehen.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
  });

  testWidgets('eine freie Kombination erreicht die Oberfläche', (tester) async {
    // Bis zum 09.09.2026 nahm die Hülle `themeFor(controller.themeVariant)`.
    // Der Getter übersetzt nur die Charakteristik zurück — eine Palette, die
    // nicht zur Diagonale gehört, ging dabei verloren: Messinstrument auf
    // Nacht blieb hell. Gefunden im Codex-Gegenblick.
    await tester.runAsync(() => controller.setPalette(Palette.nacht));
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(TodayScreen));
    expect(
      SphygmaTheme.of(context).surface,
      Palette.nacht.grund,
      reason: 'die Palette muss ankommen, auch abseits der Diagonale',
    );
    expect(
      SphygmaTheme.of(context).radius,
      Characteristic.messinstrument.radius,
      reason: 'und die Charakteristik daneben bestehen bleiben',
    );

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
  });
}
