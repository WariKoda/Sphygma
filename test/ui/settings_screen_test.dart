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
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
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

/// Health Connect verweigert die Berechtigung — ein alltaeglicher Fall.
class _FailingSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {
    throw StateError('Keine Berechtigung.');
  }

  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {
    throw StateError('Keine Berechtigung.');
  }
}

void main() {
  late AppDatabase db;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  Future<void> boot({
    bool paired = true,
    bool withSlot = true,
    HealthSink? sink,
  }) async {
    if (paired) await keyStore.save(Uint8List(16));
    final repository = MeasurementRepository(db);
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      occasionRepository: OccasionRepository(db),
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(
        repository: repository,
        sink: sink ?? _NoopSink(),
      ),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    if (paired && withSlot) await controller.setUserSlot(1);
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) {
    // Ein hohes Testfenster: Seit die gesamte Technik hier steht, ist das
    // Blatt sechs Karten lang. Auf 600 Pixeln waere die Haelfte nicht
    // gebaut, und jede Pruefung hinge am Scrollen statt an der Sache.
    tester.view.physicalSize = const Size(1080, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            SphygmaThemeScope(theme: themeFor(v), child: child!),
        home: SettingsScreen(controller: controller),
      ),
    );
  }

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
    await tester.ensureVisible(find.text('Phase'));
    await tester.tap(find.text('Phase'));
    await tester.pumpAndSettle();

    expect(controller.concept, AppConcept.phase);
  });

  testWidgets('die Form lässt sich umschalten', (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);
    // Seit dem 09.09.2026 steht je Achse ein Auswahlfeld statt einer
    // Radioliste: erst das Feld öffnen, dann den Eintrag wählen.
    await tester.ensureVisible(find.byType(DropdownMenu<Characteristic>));
    await tester.tap(find.byType(DropdownMenu<Characteristic>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tagebuch').last);
    await tester.pump();

    expect(controller.characteristic, Characteristic.tagebuch);
    expect(
      controller.themeVariant,
      ThemeVariant.diary,
      reason: 'die Diagonale übersetzt die Form zurück',
    );
  });

  testWidgets('die Farbwelt lässt sich unabhängig von der Form wählen', (
    tester,
  ) async {
    // Der Kern der Trennung: Messinstrument auf Nacht ist eine Kombination,
    // die es als Gestaltung nie gab.
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.ensureVisible(find.byType(DropdownMenu<Palette>));
    await tester.tap(find.byType(DropdownMenu<Palette>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nacht').last);
    await tester.pump();

    expect(controller.palette, Palette.nacht);
    expect(
      controller.characteristic,
      Characteristic.messinstrument,
      reason: 'die Form bleibt, wo sie war',
    );
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

  // Abgleich und Uebertragung sind am 08.09.2026 aus dem aufgeloesten Reiter
  // „Geraet" hierher gewandert. Ihre Tests sind mitgekommen.

  testWidgets('Abgleich und Übertragung stehen bei den Einstellungen', (
    tester,
  ) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Automatischer Abgleich'), findsOneWidget);
    expect(find.text('Jetzt abgleichen'), findsOneWidget);
    expect(find.text('Alle übertragen'), findsOneWidget);
  });

  testWidgets('die Reihenfolge folgt der Häufigkeit', (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    // Was im Alltag vorkommt, steht oben; was man einmal einstellt, unten.
    // Ohne diese Prüfung rutscht die Reihenfolge beim nächsten Umbau
    // zurück in die Zufälligkeit.
    double y(String titel) => tester.getTopLeft(find.text(titel)).dy;
    final reihe = [
      'ABGLEICH',
      'HEALTH CONNECT',
      'GERÄT',
      'ANSICHT',
      'KONZEPT',
      'GESTALTUNG',
    ];
    for (var i = 1; i < reihe.length; i++) {
      expect(
        y(reihe[i - 1]),
        lessThan(y(reihe[i])),
        reason: '${reihe[i - 1]} muss über ${reihe[i]} stehen',
      );
    }
  });

  testWidgets('das Wochenraster lässt sich abschalten, und es bleibt aus', (
    tester,
  ) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);
    expect(controller.weekPanelVisible, isTrue, reason: 'Standard ist an');

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(controller.weekPanelVisible, isFalse);
    // Nicht nur im Steuerungsteil: Ein Schalter, der den Neustart nicht
    // überlebt, ist keiner.
    expect(await SettingsRepository(db).weekPanelVisible(), isFalse);
  });

  testWidgets('eine fehlschlagende Aktion meldet, statt unbeobachtet zu '
      'scheitern', (tester) async {
    await boot(sink: _FailingSink());
    await MeasurementRepository(db).importAll([
      SlotRecord(
        userSlot: 1,
        record: BloodPressureRecord(
          systolic: 128,
          diastolic: 87,
          pulse: 82,
          timestamp: DateTime.now(),
          arrhythmiaFlag: false,
          movementFlag: false,
          sequence: 1,
        ),
        rawBytes: Uint8List(14),
      ),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Alle übertragen'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(controller.status, contains('Fehler'));
  });

  testWidgets('ohne Speicherplatz ist "Übertragene entfernen" abgeschaltet', (
    tester,
  ) async {
    await boot(withSlot: false);

    await pumpWith(tester, ThemeVariant.instrument);

    final button = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Übertragene entfernen'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('die Auswahlfelder tragen die Farben der Gestaltung', (
    tester,
  ) async {
    // Auf „Nacht" nimmt ein DropdownMenu ohne eigene Farben den
    // Material-Standard und stellt dunklen Text auf dunklen Grund. Geprüft
    // wird die Beschriftung, weil sie als einzige nicht schon durch
    // `textStyle` abgedeckt ist.
    await boot();
    await controller.setPalette(Palette.nacht);

    await pumpWith(tester, ThemeVariant.aura);

    final t = themeFrom(
      characteristic: controller.characteristic,
      palette: Palette.nacht,
      typeface: controller.typeface,
    );
    final label = tester.widget<Text>(
      find.descendant(
        of: find.byType(DropdownMenu<Palette>),
        matching: find.text('Farbwelt'),
      ),
    );
    expect(label.style?.color, t.muted);
  });
}
