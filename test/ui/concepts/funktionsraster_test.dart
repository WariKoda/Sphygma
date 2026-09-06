// Das Funktionsraster als Test — docs/design/funktionsraster.md.
//
// „Jedes Konzept deckt alle fünfzehn ab. Wo eine Funktion in der Logik des
// Konzepts keinen naheliegenden Ort hat, muss das Konzept einen erfinden —
// sie wegzulassen ist kein Stilmittel, sondern ein Fehler."
//
// Diese Regel stand in einer Markdown-Datei und in keinem Test. Am 06.09.2026
// stellte sich heraus, dass F4 in vier von fünf Konzepten fehlte, ohne dass
// etwas rot wurde. Diese Datei schließt die Lücke: Sie kennt für jedes
// Konzept den Weg zu jeder Funktion und läuft ihn ab.
//
// Der Test ist damit zugleich die Karte: Wo eine Funktion sitzt, steht hier
// als ausführbarer Code statt als Prosa, die veralten kann.
//
// Nicht hier geprüft, sondern anderswo:
//   F4  — test/ui/concepts/f4_einordnung_test.dart, in beiden Flag-Zuständen
//   F13 — test/ui/sphygma_app_test.dart („eine Meldung des Steuerungsteils
//         erscheint"): Die Meldungen hängen an der App-Hülle, nicht am
//         Konzept, und sind deshalb dort einmal zu prüfen
//   F14, F15 — test/ui/sphygma_app_test.dart („jedes Konzept trägt den
//         Zugang zur Wahl an derselben Stelle")
//
// F5 (Bericht für die Praxis) ist in **keinem** Konzept gebaut und hat einen
// eigenen Plan (PLAN.md §9.5). Hier steht bewusst kein Test dafür: Ein Test,
// der die Abwesenheit festschreibt, würde die Lücke zementieren statt sie zu
// schließen.
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
import 'package:sphygma/stats/measurement_week.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/concepts/concept_home.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _rec(int seq, DateTime at, {int sys = 148, int dia = 92}) =>
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

/// Montag der Vorwoche: alles liegt in der Vergangenheit, unabhängig davon,
/// an welchem Wochentag der Test läuft.
final _montag = previousMonday(mondayOf(DateTime.now()));

DateTime _tag(int versatz, int stunde, [int minute = 0]) =>
    DateTime(_montag.year, _montag.month, _montag.day + versatz, stunde, minute);

DateTime _vorTagen(int n) =>
    DateTime(_montag.year, _montag.month, _montag.day - n, 9);

/// Freitag jener Woche — was die Oberfläche als „jetzt" sieht.
final _jetzt = _tag(4, 18);

/// Eine Messwertzeile: „148/92 · 78". Der Mittelwert steht mit Leerzeichen
/// um den Schrägstrich und wird davon nicht getroffen — angetippt werden soll
/// eine Messung, keine Zusammenfassung.
final _wertMuster = RegExp(r'\d{3}/\d{2} ·');

/// Eine **antippbare** Messwertzeile.
///
/// Der Verlauf zeigt seinen Mittelwert im selben Format wie eine Messung
/// („148/92 · 78"), er führt aber nirgendwohin. Ohne die Einschränkung auf
/// einen InkWell träfe der Test die Zusammenfassung statt der Messung — und
/// meldete eine fehlende Funktion, die vorhanden ist.
Finder get _messzeile => find.descendant(
      of: find.byType(InkWell),
      matching: find.textContaining(_wertMuster),
    );

/// Wie man in einem Konzept an eine Funktion herankommt.
///
/// Jedes Konzept ordnet anders; die Wege unterscheiden sich deshalb. Genau
/// das ist der Punkt des Rasters: dieselbe Funktion, ein anderer Weg — aber
/// keiner darf fehlen.
class _Weg {
  const _Weg({
    required this.zumGeraet,
    required this.zurAuswertung,
    required this.zurEinzelmessung,
  });

  final Future<void> Function(WidgetTester) zumGeraet;
  final Future<void> Function(WidgetTester) zurAuswertung;
  final Future<void> Function(WidgetTester) zurEinzelmessung;
}

/// Prüft, dass etwas da ist — notfalls, nachdem danach gescrollt wurde.
///
/// Eine ListView baut nur, was ins Fenster passt. Mit eingeschalteter
/// Einordnung werden die Bildschirme länger, und ein Hinweis am Fuß ist
/// schlicht noch nicht gebaut. Ohne Scrollen prüfte der Test, was zufällig
/// sichtbar ist, und meldete eine fehlende Funktion, die vorhanden ist.
Future<void> _erwarte(
  WidgetTester tester,
  Finder f, {
  required String reason,
}) async {
  if (f.evaluate().isEmpty && find.byType(Scrollable).evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(f, 240, maxScrolls: 40);
    await tester.pumpAndSettle();
  }
  expect(f, findsWidgets, reason: reason);
}

Future<void> _tippe(WidgetTester tester, Finder f) async {
  // Wie bei _erwarte: Was nicht ins Fenster passt, ist noch nicht gebaut und
  // wird erst durch Scrollen auffindbar. „Nicht sichtbar" ist kein „nicht
  // vorhanden".
  if (f.evaluate().isEmpty && find.byType(Scrollable).evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(f, 240, maxScrolls: 40);
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.first);
  await tester.pumpAndSettle();
}

final Map<AppConcept, _Weg> _wege = {
  AppConcept.klassisch: _Weg(
    zumGeraet: (t) => _tippe(t, find.text('Gerät')),
    zurAuswertung: (t) => _tippe(t, find.text('Verlauf')),
    zurEinzelmessung: (t) async {
      await _tippe(t, find.text('Verlauf'));
      // „Woche" misst ab der echten Uhr, der Testbestand liegt in der
      // Vorwoche — über „Alles" ist er unabhängig davon erreichbar.
      await _tippe(t, find.text('Alles'));
      await _tippe(t, _messzeile);
    },
  ),
  AppConcept.tagesprofil: _Weg(
    zumGeraet: (t) => _tippe(t, find.text('Gerät')),
    zurAuswertung: (t) => _tippe(t, find.text('Verlauf')),
    zurEinzelmessung: (t) async {
      // Über den Tagesabschnitt, nicht über den Kalender.
      await _tippe(t, find.text('Morgens'));
      await _tippe(t, _messzeile);
    },
  ),
  AppConcept.siebenTage: _Weg(
    zumGeraet: (t) => _tippe(t, find.text('Gerät und Übertragung')),
    zurAuswertung: (t) async {
      await _tippe(t, find.text('Frühere Wochen'));
      await _tippe(t, find.byIcon(Icons.calculate_outlined));
    },
    zurEinzelmessung: (t) async {
      // Über das Feld im Wochenraster.
      await _tippe(t, find.text('148'));
    },
  ),
  AppConcept.messanlass: _Weg(
    zumGeraet: (t) => _tippe(t, find.text('Gerät')),
    zurAuswertung: (t) async {
      await _tippe(t, find.text('Archiv'));
      await _tippe(t, find.text('Anlässe auswerten'));
    },
    zurEinzelmessung: (t) async {
      // Über den Rohwert des letzten Messens — welche Zahl dort steht,
      // hängt davon ab, welche Messungen zum letzten Anlass gehören.
      await _tippe(t, _messzeile);
    },
  ),
  AppConcept.phase: _Weg(
    zumGeraet: (t) => _tippe(t, find.text('Gerät')),
    zurAuswertung: (t) => _tippe(t, find.text('Vergleich ansehen')),
    zurEinzelmessung: (t) async {
      await _tippe(t, find.text('Phasen'));
      await _tippe(t, find.text('Laufender Abschnitt'));
      await _tippe(t, _messzeile);
    },
  ),
};

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late OccasionRepository occasions;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  Future<void> boot({bool paired = true}) async {
    if (paired) await keyStore.save(Uint8List(16));
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      occasionRepository: occasions,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    await controller.setUserSlot(1);

    // Zwei Phasen, damit „Phase" einen Vergleich anbieten kann — er braucht
    // einen Abschnitt davor mit eigenen Messungen.
    await occasions.startPhase(
      name: 'Früherer Abschnitt',
      anchor: PhaseAnchor.bestaetigt,
      begin: _vorTagen(60),
    );
    final frueh = (await occasions.phases()).single;
    await occasions.endPhase(frueh.id, at: _vorTagen(20));
    await occasions.startPhase(
      name: 'Laufender Abschnitt',
      anchor: PhaseAnchor.bestaetigt,
      begin: _vorTagen(20),
    );

    await repository.importAll([
      // Im früheren Abschnitt — kleinere Nummern, älteres Datum.
      _rec(1, _vorTagen(40), sys: 160, dia: 98),
      _rec(2, _vorTagen(39), sys: 158, dia: 96),
      // Die Messwoche: Montag bis Donnerstag, morgens und abends.
      for (var i = 0; i < 4; i++) ...[
        _rec(3 + i * 2, _tag(i, 7)),
        _rec(4 + i * 2, _tag(i, 20), sys: 144, dia: 90),
      ],
      // Zwei Minuten nach der letzten: ein Messanlass aus zwei Rohwerten.
      _rec(11, _tag(3, 20, 2), sys: 146, dia: 91),
    ]);
    await controller.refreshForTest();
  }

  Future<void> pump(WidgetTester tester, AppConcept k) async {
    await controller.setConcept(k);
    await tester.pumpWidget(MaterialApp(
      home: SphygmaThemeScope(
        theme: themeFor(ThemeVariant.instrument),
        child: conceptHome(
          concept: k,
          controller: controller,
          clock: () => _jetzt,
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    occasions = OccasionRepository(db);
    keyStore = InMemoryPairingKeyStore();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  for (final k in allConcepts) {
    final weg = _wege[k]!;

    group('${k.name} deckt das Raster', () {
      testWidgets('F1 — Messwerte sind zu sehen', (tester) async {
        await boot();
        await pump(tester, k);

        // Irgendein Messwert des Bestands steht auf dem Einstieg.
        expect(find.textContaining('14'), findsWidgets);
      });

      testWidgets('F2 — Auswertung über einen Zeitraum', (tester) async {
        await boot();
        await pump(tester, k);
        await weg.zurAuswertung(tester);

        expect(tester.takeException(), isNull);
        // Eine Auswertung nennt mmHg oder einen Zeitraum — leer wäre sie
        // keine.
        expect(find.textContaining(RegExp('mmHg|Woche|Anlass|Zeitraum|Tage')),
            findsWidgets);
      });

      testWidgets('F3 und F10 — eine Messung im Detail, mit Health Connect',
          (tester) async {
        await boot();
        await pump(tester, k);
        await weg.zurEinzelmessung(tester);

        expect(find.text('HEALTH CONNECT'), findsOneWidget,
            reason: 'F10 sitzt im Blatt der Einzelmessung');
        expect(find.textContaining('Messung Nr.'), findsOneWidget,
            reason: 'F3 — die Herkunft der Messung');
      });

      testWidgets('F6 bis F9 — Gerät, Abgleich und Health Connect',
          (tester) async {
        await boot();
        await pump(tester, k);
        await weg.zumGeraet(tester);

        await _erwarte(tester, find.textContaining('Automatischer Abgleich'),
            reason: 'F8 fehlt in ${k.name}');
        await _erwarte(tester, find.text('Jetzt abgleichen'),
            reason: 'F7 fehlt in ${k.name}');
        await _erwarte(tester, find.text('Alle übertragen'),
            reason: 'F9 fehlt in ${k.name}');
        await _erwarte(tester, find.text('Neu koppeln'),
            reason: 'F6 fehlt in ${k.name}');
      });

      testWidgets('F11 — eine unglaubwürdige Gerätezeit wird gemeldet',
          (tester) async {
        await boot();
        // Höchste Nummer, Datum von 2023: Die Uhr des Geräts stand falsch.
        await repository.importAll([_rec(99, DateTime(2023, 4, 18, 11))]);
        await controller.refreshForTest();
        await pump(tester, k);

        // Die Konzepte sagen es in ihrer eigenen Sprache: vier warnen vor
        // der Geräteuhr, „Phase" führt die Messung als zeitlich ungeklärt —
        // dort ist die Zuordnung die eigentliche Folge des Fehlers.
        await _erwarte(
          tester,
          find.textContaining(RegExp('Geräteuhr|ungeklärt')),
          reason: 'F11 fehlt in ${k.name}',
        );
      });

      testWidgets('F12 — ohne Kopplung sagt das Konzept, wo man koppelt',
          (tester) async {
        await boot(paired: false);
        await pump(tester, k);

        await _erwarte(tester, find.textContaining('Nicht gekoppelt'),
            reason: 'F12 fehlt in ${k.name}');
      });
    });
  }
}
