// Zustand und Aktionen der App (M6). Buendelt die Services der unteren
// Schichten; die UI beobachtet ihn per ListenableBuilder. Bewusst ohne
// State-Management-Paket - ein ChangeNotifier reicht fuer diese App.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../ble/omron_advertising.dart';
import '../ble/omron_session.dart';
import '../ble/pairing_key_store.dart';
import '../db/app_database.dart';
import '../db/measurement_repository.dart';
import '../db/occasion_repository.dart';
import '../db/settings_repository.dart';
import 'concept.dart';
import '../protocol/exceptions.dart';
import '../stats/occasion_grouping.dart';
import '../stats/period.dart';
import '../sync/export_service.dart';
import '../sync/sync_service.dart';
import '../ui/theme/variants.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.settings,
    required this.keyStore,
    required this.repository,
    required this.occasionRepository,
    required this.syncService,
    required this.exportService,
    Stream<OmronAdvertisedStatus> Function()? statusStream,
  }) : _statusStream = statusStream ?? watchOmronStatus;

  /// Quelle der Advertising-Meldungen. Injizierbar, damit der Autosync
  /// ohne Bluetooth getestet werden kann.
  final Stream<OmronAdvertisedStatus> Function() _statusStream;
  StreamSubscription<OmronAdvertisedStatus>? _watch;
  bool _disposed = false;

  /// Ob der Autosync gerade lauscht. False heisst: Es kommt nichts von
  /// selbst, der Sync auf Knopfdruck funktioniert aber weiter.
  bool get autoSyncActive => _watch != null;

  /// Messungsnummer, fuer die zuletzt ein automatischer Sync versucht
  /// wurde. Verhindert, dass ein Fehlschlag bei jedem weiteren
  /// Advertising erneut probiert wird - das Geraet sendet mehrmals je
  /// Sekunde.
  int? _lastAutoSyncAttempt;

  final SettingsRepository settings;
  final PairingKeyStore keyStore;
  final MeasurementRepository repository;

  /// Die Entscheidungen des Nutzers zur Gruppierung und seine Phasen.
  /// Beides gehört keinem einzelnen Konzept: „Messanlass" braucht die
  /// Gruppierung, „Phase" die Lebensabschnitte, und beide arbeiten auf
  /// demselben Bestand wie alle anderen.
  final OccasionRepository occasionRepository;

  final SyncService syncService;
  final ExportService exportService;

  int? userSlot;
  bool paired = false;
  bool busy = false;
  String? status;
  List<Measurement> measurements = const [];
  int pendingExport = 0;

  /// Gewaehlter Zeitraum im Verlauf.
  Period period = Period.week;

  /// Gewaehlte Gestaltung. Wird in [init] aus der DB geladen.
  ThemeVariant themeVariant = ThemeVariant.instrument;

  /// Die zweite Achse: wie die App geordnet ist. Frei mit der Gestaltung
  /// kombinierbar — jedes Konzept trägt denselben Funktionsumfang.
  AppConcept concept = AppConcept.klassisch;

  /// Die Messanlässe des gewählten Speicherplatzes: Rohmessungen, die kurz
  /// nacheinander entstanden sind, gehören zu einem Messen. Abgeleitet, nicht
  /// gespeichert — nur die Entscheidungen des Nutzers liegen in der DB.
  List<MeasurementOccasion> occasions = const [];

  /// Die benannten Lebensabschnitte, neueste zuerst.
  List<Phase> phases = const [];

  /// Anlässe, bei denen die Regel keine eindeutige Antwort gibt. Sie werden
  /// nicht still zusammengefasst — eine zugedeckte Frage ist schlimmer als
  /// eine unbeantwortete.
  Iterable<MeasurementOccasion> get openOccasions =>
      occasions.where((o) => o.state == OccasionState.zuPruefen);

  /// Die neueste Messung, unabhaengig vom Zeitraum. Null heisst: noch
  /// keine Messung gespeichert - ein echter Zustand, kein Fehler.
  Measurement? get latest => measurements.isEmpty ? null : measurements.first;

  /// Messungen im gewaehlten Zeitraum, aelteste zuerst.
  List<Measurement> get measurementsInPeriod =>
      filterByPeriod(measurements, period, DateTime.now());

  Future<void> setPeriod(Period value) async {
    period = value;
    notifyListeners();
  }

  Future<void> setConcept(AppConcept value) async {
    await settings.setConcept(value);
    concept = value;
    notifyListeners();
  }

  Future<void> setThemeVariant(ThemeVariant value) async {
    await settings.setThemeVariant(value);
    themeVariant = value;
    notifyListeners();
  }

  /// Nur fuer Tests: erzwingt das Neuladen aus der DB.
  @visibleForTesting
  Future<void> refreshForTest() => _refresh();

  /// Deutet auf eine falsch gehende Geraeteuhr hin (Protokollreferenz §8.2):
  /// die neueste Messung liegt weit in der Vergangenheit oder in der Zukunft.
  bool clockLooksWrong = false;

  Future<void> init() async {
    userSlot = await settings.userSlot();
    paired = await keyStore.load() != null;
    themeVariant = await settings.themeVariant();
    concept = await settings.concept();
    await _refresh();
    _startWatching();
  }

  /// Lauscht auf das Advertising des Geraets und synchronisiert von
  /// selbst, sobald es eine hoehere Messungsnummer meldet als die
  /// Datenbank kennt.
  ///
  /// Das Geraet sendet nach jeder Messung von sich aus
  /// (docs/protocol/hem-6232t.md §2.1), es braucht also keinen
  /// Tastendruck. Verbunden wird nur, wenn es wirklich etwas zu holen
  /// gibt.
  void _startWatching() {
    if (_watch != null || !paired) return;
    // Meldungen der Reihe nach abarbeiten. Das Geraet sendet mehrmals je
    // Sekunde; ohne diese Kette starten mehrere Meldungen ihre
    // DB-Abfrage, bevor die erste den Versuch vermerkt hat, und der Sync
    // liefe doppelt.
    //
    // Jedes Glied faengt seine eigenen Fehler ab. Ohne das wuerde ein
    // einziger Fehlschlag die Kette dauerhaft vergiften und jede weitere
    // Meldung stillschweigend uebersprungen (Codex-Review 2026-09-04).
    var pending = Future<void>.value();
    _watch = _statusStream().listen(
      (status) {
        pending = pending.then((_) async {
          if (_disposed) return;
          try {
            await _onAdvertisedStatus(status);
          } catch (e) {
            debugPrint('[Sphygma] Autosync-Meldung verworfen: $e');
          }
        });
      },
      onError: _onWatchError,
    );
  }

  Future<void> _onAdvertisedStatus(OmronAdvertisedStatus status) async {
    final slot = userSlot;
    if (slot == null || busy) return;

    final onDevice = status.highestSequence(slot);
    if (onDevice == _lastAutoSyncAttempt) return;

    final known = await repository.highestSequenceFor(slot);
    if (!status.hasNewMeasurements(userSlot: slot, knownSequence: known)) {
      return;
    }

    _lastAutoSyncAttempt = onDevice;
    debugPrint(
      '[Sphygma] Autosync: Gerät meldet $onDevice, bekannt ${known ?? "nichts"}',
    );
    try {
      await sync();
    } catch (_) {
      // _run hat den Fehler bereits in [status] hinterlegt und geloggt.
      // Erneut versucht wird erst bei einer anderen Messungsnummer.
    }
  }

  /// Fehler im Advertising-Scan.
  ///
  /// Der Strom endet damit, das Lauschen ist also vorbei. Das darf nicht
  /// stillschweigend passieren: Der Nutzer wuerde sonst auf einen
  /// Autosync warten, den es nicht mehr gibt. Ein harter Abbruch waere
  /// aber falsch, denn der Sync auf Knopfdruck traegt weiterhin.
  void _onWatchError(Object error) {
    debugPrint('[Sphygma] Autosync-Scan: $error');
    _watch = null;
    if (_disposed) return;
    status = 'Automatischer Abgleich nicht verfügbar: $error';
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_watch?.cancel());
    _watch = null;
    super.dispose();
  }

  Future<void> setUserSlot(int slot) async {
    await settings.setUserSlot(slot);
    userSlot = slot;
    // Der Vermerk gilt je Slot: Slot 2 kann dieselbe Messungsnummer
    // tragen wie Slot 1, und ohne Ruecksetzen bliebe sein Sync aus
    // (Codex-Review 2026-09-04).
    _lastAutoSyncAttempt = null;
    await _refresh();
  }

  Future<void> pair() => _run('Pairing…', () async {
        await syncService.pair(log: _log);
        paired = true;
        status = 'Pairing erfolgreich.';
        // Nach dem Pairing kann ein anderes Geraet mit eigener
        // Nummernfolge dranhaengen.
        _lastAutoSyncAttempt = null;
        _startWatching();
      });

  Future<void> sync() => _run('Verbinde…', () async {
        try {
          final result = await syncService.sync(log: _log);
          // Ueber _log statt nur ueber [status]: Ein automatisch
          // ausgeloester Abgleich soll im Protokoll nachvollziehbar sein,
          // auch wenn niemand auf den Bildschirm geschaut hat.
          _log(result.newlyStored == 0
              ? 'Keine neuen Messungen (${result.readFromDevice} gelesen).'
              : '${result.newlyStored} neue Messungen.');
        } on NotPairedException {
          status = 'Noch nicht gepairt.';
          rethrow;
        } on ProtocolException catch (e) {
          // Entsperren mit dem gespeicherten Key abgelehnt -> Key im Geraet
          // passt nicht mehr (z. B. nach Neuinstallation, Risiko R-4).
          if (e.message.contains('Entsperren')) {
            paired = false;
            status = 'Das Gerät kennt diesen Key nicht mehr - bitte neu pairen.';
          }
          rethrow;
        }
      });

  Future<void> exportAll() => _run('Exportiere…', () async {
        final slot = _requireSlot();
        final n = await exportService.exportPending(userSlot: slot);
        status = '$n Messungen nach Health Connect geschrieben.';
      });

  Future<void> retractAll() => _run('Entferne…', () async {
        final slot = _requireSlot();
        final n = await exportService.retractExported(userSlot: slot);
        status = '$n Messungen aus Health Connect entfernt.';
      });

  Future<void> exportOne(Measurement m) => _run('Exportiere…', () async {
        await exportService.exportOne(m);
        status = 'Messung nach Health Connect geschrieben.';
      });

  Future<void> retractOne(Measurement m) => _run('Entferne…', () async {
        await exportService.retractOne(m);
        status = 'Messung aus Health Connect entfernt.';
      });

  int _requireSlot() {
    final slot = userSlot;
    if (slot == null) {
      throw StateError('Kein User-Slot gewählt.');
    }
    return slot;
  }

  void _log(String message) {
    debugPrint('[Sphygma] $message');
    status = message;
    notifyListeners();
  }

  Future<void> _run(String initial, Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    status = initial;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      debugPrint('[Sphygma] Fehler: $e');
      status = 'Fehler: $e';
      rethrow;
    } finally {
      busy = false;
      await _refresh();
    }
  }

  Future<void> _refresh() async {
    final slot = userSlot;
    if (slot == null) {
      measurements = const [];
      pendingExport = 0;
      clockLooksWrong = false;
      occasions = const [];
      phases = const [];
    } else {
      measurements = (await repository.allForSlot(slot)).reversed.toList();
      pendingExport = (await repository.pendingExport(slot)).length;
      clockLooksWrong = _clockLooksWrong(measurements);
      occasions = proposeOccasions(
        measurements,
        confirmedJoins: await occasionRepository.confirmedJoins(slot),
        confirmedSplits: await occasionRepository.confirmedSplits(slot),
      );
      phases = await occasionRepository.phases();
    }
    notifyListeners();
  }

  /// Der Nutzer entscheidet einen Grenzfall: Diese Messung gehört zum
  /// vorherigen Anlass.
  Future<void> confirmJoin(int deviceSequence) async {
    await occasionRepository.confirmJoin(
      userSlot: _requireSlot(),
      deviceSequence: deviceSequence,
    );
    await _refresh();
  }

  /// Der Nutzer entscheidet einen Grenzfall: Diese Messung ist ein eigener
  /// Anlass.
  Future<void> confirmSplit(int deviceSequence) async {
    await occasionRepository.confirmSplit(
      userSlot: _requireSlot(),
      deviceSequence: deviceSequence,
    );
    await _refresh();
  }

  /// Nimmt eine Entscheidung zurück — die Regel gilt wieder.
  Future<void> clearOccasionDecision(int deviceSequence) async {
    await occasionRepository.clearDecision(
      userSlot: _requireSlot(),
      deviceSequence: deviceSequence,
    );
    await _refresh();
  }

  Future<void> startPhase({
    required String name,
    required PhaseAnchor anchor,
    DateTime? begin,
  }) async {
    await occasionRepository.startPhase(
      name: name,
      anchor: anchor,
      begin: begin,
    );
    await _refresh();
  }

  Future<void> endPhase(int id, {required DateTime at}) async {
    await occasionRepository.endPhase(id, at: at);
    await _refresh();
  }

  Future<void> deletePhase(int id) async {
    await occasionRepository.deletePhase(id);
    await _refresh();
  }

  /// Geht die Geraeteuhr falsch?
  ///
  /// Massgeblich ist die **zuletzt gemessene** Messung, und das ist die mit
  /// der hoechsten Geraetenummer - nicht die mit dem spaetesten Datum. Genau
  /// darin liegt der Fall: Bei falscher Uhr traegt die frischeste Messung ein
  /// altes Datum und stuende in einer nach Datum sortierten Liste weit hinten.
  /// Die Anzeige sortiert nach Datum, diese Pruefung nach Zaehler.
  static bool _clockLooksWrong(List<Measurement> all) {
    if (all.isEmpty) return false;
    var newest = all.first;
    for (final m in all) {
      if (m.deviceSequence > newest.deviceSequence) newest = m;
    }
    final now = DateTime.now();
    return newest.measuredAt.isAfter(now.add(const Duration(days: 1))) ||
        newest.measuredAt.isBefore(now.subtract(const Duration(days: 365)));
  }

  /// Nur zur Anzeige: erklaert die Ausnahme aus dem BLE-Scan.
  static String describe(Object error) {
    if (error is DeviceNotFoundException) {
      return 'Kein Omron gefunden. Bluetooth-Taste am Gerät kurz drücken '
          'und erneut versuchen.';
    }
    return error.toString();
  }
}
