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
import '../db/settings_repository.dart';
import '../protocol/exceptions.dart';
import '../stats/measurement_metadata.dart';
import '../stats/measurement_windows.dart';
import '../plan/plan_controller.dart';
import '../stats/measurement_filter.dart';
import '../stats/phase_grouping.dart';
import '../stats/period.dart';
import '../stats/time_plausibility.dart';
import '../sync/export_service.dart';
import '../sync/health_sink.dart';
import '../sync/sync_service.dart';
import '../ui/theme/variants.dart';
import '../ui/theme/sphygma_theme.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.settings,
    required this.keyStore,
    required this.repository,
    required this.metadataRepository,
    required this.phaseRepository,
    required this.syncService,
    required this.exportService,
    this.planController,
    Stream<OmronAdvertisedStatus> Function()? statusStream,
    DateTime Function()? clock,
  }) : _statusStream = statusStream ?? watchOmronStatus,
       _clock = clock ?? DateTime.now {
    planController?.addListener(_onPlanChanged);
  }

  /// Quelle der Advertising-Meldungen. Injizierbar, damit der Autosync
  /// ohne Bluetooth getestet werden kann.
  final Stream<OmronAdvertisedStatus> Function() _statusStream;
  final DateTime Function() _clock;
  StreamSubscription<OmronAdvertisedStatus>? _watch;
  bool _disposed = false;
  Future<void> _watchTransitions = Future<void>.value();

  /// Die gespeicherte Zustimmung ist unabhängig vom aktuellen Scan-Zustand.
  bool autoSyncEnabled = false;

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

  final MetadataStore metadataRepository;
  final PhaseStore phaseRepository;

  final SyncService syncService;
  final ExportService exportService;
  final PlanController? planController;

  int? userSlot;
  bool paired = false;
  bool busy = false;
  String? status;
  List<Measurement> measurements = const [];
  int pendingExport = 0;
  Map<int, MeasurementExportState> exportStates = const {};

  /// Gewaehlter Zeitraum im Verlauf.
  Period period = Period.week;

  Characteristic characteristic = Characteristic.messinstrument;
  Palette palette = Palette.papier;
  Typeface typeface = Typeface.system;

  /// Das bestehende Auswahlblatt zeigt die Form der Diagonale. Die freie
  /// Kombination bleibt in den drei Achsen erhalten.
  ThemeVariant get themeVariant => variantFor(characteristic);

  SphygmaTheme get theme => themeFrom(
    characteristic: characteristic,
    palette: palette,
    typeface: typeface,
  );

  /// Ob das Wochenraster auf „Heute" erscheint. Wird in [init] aus der DB
  /// geladen.
  MeasurementWindows measurementWindows = MeasurementWindows.defaults;
  bool weekPanelVisible = true;
  bool recentMeasurementsVisible = true;
  DateTime? lastSuccessfulSyncAt;

  /// Ob neue Messungen von selbst nach Health Connect gehen.
  ///
  /// Standard ist **an**: Messwerte dorthin zu bringen ist der Zweck dieser
  /// App, und wer die Berechtigung erteilt hat, will genau das. Abschaltbar
  /// bleibt es trotzdem — es gehen Gesundheitsdaten in eine fremde Akte.
  bool autoExport = true;

  /// Warum der letzte automatische Export nicht durchlief, oder null.
  ///
  /// Ein automatischer Vorgang darf nicht bei jeder Messung eine Fehlermeldung
  /// werfen — Health Connect kann die Berechtigung dauerhaft verweigern, und
  /// die Meldung käme dann endlos. Verschwiegen werden darf es aber auch
  /// nicht: Wer glaubt, seine Werte seien übertragen, verlässt sich darauf.
  /// Deshalb bleibt der Grund hier stehen und wird in den Einstellungen
  /// angezeigt.
  String? autoExportProblem;

  bool phasesEnabled = false;
  Map<int, MeasurementMetadata> metadataBySequence = const {};
  List<MeasurementTag> tags = const [];
  List<ScopedPhase> phases = const [];
  Map<int, Set<int>> manualPhaseSelections = const {};
  Map<int, Set<int>> phaseIdsBySequence = const {};
  Map<int, TimestampVerdict> timestampVerdicts = const {};
  HistoryFilter historyFilter = const HistoryFilter();

  /// Die neueste Messung, unabhaengig vom Zeitraum. Null heisst: noch
  /// keine Messung gespeichert - ein echter Zustand, kein Fehler.
  Measurement? get latest => measurements.isEmpty ? null : measurements.first;

  /// Messungen im gewaehlten Zeitraum, aelteste zuerst.
  List<Measurement> get measurementsInPeriod =>
      filterByPeriod(measurements, period, _clock());

  List<Measurement> get filteredMeasurements => applyHistoryFilter(
    measurementsInPeriod,
    historyFilter,
    tagIdsBySequence: {
      for (final entry in metadataBySequence.entries)
        entry.key: entry.value.tagIds,
    },
    phaseIdsBySequence: phaseIdsBySequence,
  );

  void setHistoryFilter(HistoryFilter value) {
    historyFilter = value;
    notifyListeners();
  }

  void resetHistoryFilter() => setHistoryFilter(const HistoryFilter());

  Future<void> setPeriod(Period value) async {
    period = value;
    notifyListeners();
  }

  // **Bei der Gestaltung wird zuerst gezeigt, dann gespeichert.**
  //
  // Die übrigen Einstellungen halten es umgekehrt: erst schreiben, dann
  // melden — bei Speicherplatz oder Konzept hängt daran, welche Daten
  // gelesen werden, und ein Zustand, der nur auf dem Bildschirm existiert,
  // wäre dort gefährlich.
  //
  // Bei der Gestaltung ist die sichtbare Wirkung dagegen die Sache selbst:
  // Wer eine Handschrift wählt, will sie beurteilen. Auf die Datenbank zu
  // warten, bevor sich etwas rührt, macht aus der Wahl ein Rätsel — genau
  // das war am 07.09. schon einmal zu beheben, damals im geschobenen Blatt.
  //
  // Der Preis ist benannt: Scheitert das Speichern, eilt die Anzeige der
  // Datenbank voraus und die Wahl ist nach dem Neustart weg. Der Fehler
  // wird deshalb **nicht** geschluckt — er fliegt weiter.
  Future<void> setThemeVariant(ThemeVariant value) async {
    final axes = axesFor(value);
    characteristic = axes.characteristic;
    palette = axes.palette;
    typeface = axes.typeface;
    notifyListeners();
    await settings.setThemeVariant(value);
  }

  Future<void> setCharacteristic(Characteristic value) async {
    characteristic = value;
    notifyListeners();
    await settings.setCharacteristic(value);
  }

  Future<void> setPalette(Palette value) async {
    palette = value;
    notifyListeners();
    await settings.setPalette(value);
  }

  Future<void> setTypeface(Typeface value) async {
    typeface = value;
    notifyListeners();
    await settings.setTypeface(value);
  }

  Future<void> setAutoSync(bool value) async {
    await settings.setAutoSync(value);
    autoSyncEnabled = value;
    _lastAutoSyncAttempt = null;
    notifyListeners();
    await _restartWatching();
  }

  Future<void> setAutoExport(bool value) async {
    await settings.setAutoExport(value);
    autoExport = value;
    if (value) autoExportProblem = null;
    notifyListeners();
  }

  Future<void> setMeasurementWindows(MeasurementWindows value) async {
    await settings.setMeasurementWindows(value);
    measurementWindows = value;
    notifyListeners();
  }

  Future<void> setWeekPanelVisible(bool value) async {
    await settings.setWeekPanelVisible(value);
    weekPanelVisible = value;
    notifyListeners();
  }

  Future<void> setRecentMeasurementsVisible(bool value) async {
    await settings.setRecentMeasurementsVisible(value);
    recentMeasurementsVisible = value;
    notifyListeners();
  }

  /// Nur für Tests: stößt den automatischen Export an.
  ///
  /// Der echte Weg führt über einen Abgleich, und der braucht ein Gerät.
  @visibleForTesting
  Future<void> autoExportForTest() => _autoExport();

  /// Nur fuer Tests: erzwingt das Neuladen aus der DB.
  @visibleForTesting
  Future<void> refreshForTest() => _refresh();

  /// Deutet auf eine falsch gehende Geraeteuhr hin (Protokollreferenz §8.2):
  /// die neueste Messung liegt weit in der Vergangenheit oder in der Zukunft.
  bool clockLooksWrong = false;

  Future<void> init() async {
    userSlot = await settings.userSlot();
    paired = await keyStore.load() != null;
    characteristic = await settings.characteristic();
    palette = await settings.palette();
    typeface = await settings.typeface();
    phasesEnabled = await settings.phasesEnabled();
    measurementWindows = await settings.measurementWindows();
    weekPanelVisible = await settings.weekPanelVisible();
    recentMeasurementsVisible = await settings.recentMeasurementsVisible();
    lastSuccessfulSyncAt = await settings.lastSuccessfulSyncAt();
    autoExport = await settings.autoExport();
    autoSyncEnabled = await settings.autoSync();
    if (userSlot case final slot?) {
      intakeFloor = await repository.intakeFloor(slot);
    }
    await _refresh();
    final plan = planController;
    if (plan != null) {
      await _planAction(() async {
        if (userSlot case final slot?) await plan.setUserSlot(slot);
        await plan.load();
      });
    }
    _startWatching();
  }

  void _onPlanChanged() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _planAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      // Der Messplan hält seinen Fehler sichtbar. Ein importierter Messwert
      // bleibt erfolgreich importiert, und sein Export darf weiterlaufen.
      debugPrint('[Sphygma] Messplan: $error');
    }
  }

  Future<void> reconcilePlan() async {
    final plan = planController;
    if (plan != null) await _planAction(plan.reconcileReminders);
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
    if (_disposed || _watch != null || !paired || !autoSyncEnabled || busy) {
      return;
    }
    // Meldungen der Reihe nach abarbeiten. Das Geraet sendet mehrmals je
    // Sekunde; ohne diese Kette starten mehrere Meldungen ihre
    // DB-Abfrage, bevor die erste den Versuch vermerkt hat, und der Sync
    // liefe doppelt.
    //
    // Jedes Glied faengt seine eigenen Fehler ab. Ohne das wuerde ein
    // einziger Fehlschlag die Kette dauerhaft vergiften und jede weitere
    // Meldung stillschweigend uebersprungen (Codex-Review 2026-09-04).
    var pending = Future<void>.value();
    // Das Abonnieren selbst kann scheitern — etwa wenn der Datenstrom nur
    // einmal gelesen werden kann. Das darf die Aktion nicht mitreißen, aus
    // deren Abschluss heraus hier neu gelauscht wird: Der Abgleich war dann
    // erfolgreich, nur das Lauschen nicht.
    final StreamSubscription<OmronAdvertisedStatus> abo;
    try {
      abo = _statusStream().listen((status) {
        pending = pending.then((_) async {
          if (_disposed) return;
          try {
            await _onAdvertisedStatus(status);
          } catch (e) {
            debugPrint('[Sphygma] Autosync-Meldung verworfen: $e');
          }
        });
      }, onError: _onWatchError);
    } catch (e) {
      _onWatchError(e);
      return;
    }
    _watch = abo;
  }

  Future<void> _onAdvertisedStatus(OmronAdvertisedStatus status) async {
    final slot = userSlot;
    if (slot == null || busy || !autoSyncEnabled) return;

    final onDevice = status.highestSequence(slot);
    if (onDevice == _lastAutoSyncAttempt) return;

    final known = await repository.highestSequenceFor(slot);
    if (_disposed || !autoSyncEnabled || userSlot != slot || busy) return;
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
    planController?.removeListener(_onPlanChanged);
    super.dispose();
  }

  Future<void> setUserSlot(int slot) =>
      _run('Wechsle Speicherplatz…', () async {
        await settings.setUserSlot(slot);
        userSlot = slot;
        final plan = planController;
        if (plan != null) await _planAction(() => plan.setUserSlot(slot));
        historyFilter = const HistoryFilter();
        // Eine gleiche Messungsnummer im anderen Slot ist ein eigener Bestand.
        _lastAutoSyncAttempt = null;
      }, restartScan: false);

  /// Die Aufnahmegrenze des gewählten Speicherplatzes, oder null.
  ///
  /// Alles unterhalb wird nie angezeigt und nie übertragen. Sie wird beim
  /// Koppeln gesetzt und ist jederzeit widerrufbar.
  int? intakeFloor;
  IntakeState intakeState = IntakeState.complete;
  bool get intakeDecisionPending => intakeState != IntakeState.complete;
  bool get canChooseIntake => intakeState != IntakeState.awaitingReadout;

  Future<void> _requireIntakeReady(int slot) async {
    if (await settings.intakeState(slot) == IntakeState.awaitingReadout) {
      throw StateError('Bitte das Gerät zuerst vollständig abgleichen.');
    }
  }

  Future<void> _completeIntake(int slot, int? floor) async {
    await repository.setIntakeFloor(slot, floor);
    // Bei einem Abbruch zwischen diesen Schreibvorgängen bleibt der Export
    // gesperrt; eine gesetzte Grenze allein ist noch keine fertige Auswahl.
    await settings.setIntakeState(slot, IntakeState.complete);
    final plan = planController;
    if (plan != null) await _planAction(plan.refreshAfterSync);
  }

  /// Übernimmt alles, was auf dem Gerät liegt — die Grenze fällt.
  Future<void> takeAll() => _run('Übernehme Auswahl…', () async {
    final slot = _slotOderWurf();
    await _requireIntakeReady(slot);
    await _completeIntake(slot, null);
  });

  /// Übernimmt nur, was ab [ab] gemessen wurde.
  ///
  /// Das Datum wird **einmal** in eine Messungsnummer übersetzt: Die
  /// Geräteuhr geht nachweislich falsch, eine Grenze aus Zeitstempeln wäre
  /// nicht stabil. Gibt es ab dann nichts, gilt alles Bekannte als alt —
  /// dann liegt die Grenze über der höchsten Nummer.
  Future<void> takeFrom(DateTime ab) => _run('Übernehme Auswahl…', () async {
    final slot = _slotOderWurf();
    await _requireIntakeReady(slot);
    final floor =
        await repository.firstSequenceFrom(slot, ab) ??
        ((await repository.highestSequenceFor(slot) ?? 0) + 1);
    await _completeIntake(slot, floor);
  });

  /// Übernimmt nur, was ab jetzt dazukommt.
  ///
  /// Die Grenze liegt eine Nummer über der höchsten bekannten. Ohne jede
  /// Messung ist das 1 — dann fällt nichts weg, weil es nichts gibt.
  Future<void> takeOnlyNew() => _run('Übernehme Auswahl…', () async {
    final slot = _slotOderWurf();
    await _requireIntakeReady(slot);
    final floor = (await repository.highestSequenceFor(slot) ?? 0) + 1;
    await _completeIntake(slot, floor);
  });

  /// Der gewählte Speicherplatz — oder ein Wurf.
  ///
  /// Ohne Slot wüsste niemand, für wen die Grenze gilt. Ein Standard wäre
  /// hier gefährlich: Er könnte die Messungen des falschen Benutzers
  /// ausblenden oder freigeben.
  int _slotOderWurf() {
    final slot = userSlot;
    if (slot == null) {
      throw StateError(
        'Ohne gewählten Speicherplatz gibt es keine Aufnahmegrenze.',
      );
    }
    return slot;
  }

  Future<void> pair() => _run('Pairing…', () async {
    _requireSlot();
    await settings.beginIntake();
    intakeState = IntakeState.awaitingReadout;
    await syncService.pair(log: _log);
    paired = true;
    status = 'Pairing erfolgreich.';
    // Nach dem Pairing kann ein anderes Geraet mit eigener
    // Nummernfolge dranhaengen.
    _lastAutoSyncAttempt = null;
    _startWatching();
  });

  /// Holt neue Messungen vom Gerät.
  ///
  /// [autoExport] steuert, ob danach automatisch übertragen wird. Beim
  /// **ersten Koppeln** steht das auf falsch: Dort läuft der Abgleich, bevor
  /// der Nutzer entschieden hat, was von dem, was auf dem Gerät liegt,
  /// überhaupt übernommen werden soll. Ohne diese Bremse gingen die
  /// Messungen eines Vorbesitzers in die Gesundheitsakte, bevor die Frage
  /// überhaupt gestellt wurde (Codex-Gegenblick 2026-09-09).
  Future<void> sync({bool autoExport = true}) => _run('Verbinde…', () async {
    try {
      final result = await syncService.sync(log: _log);
      await settings.completeIntakeReadout();
      final completedAt = _clock().toUtc();
      // Der Import ist bereits dauerhaft gespeichert. Seine Planzuordnung
      // darf nicht am anschließenden Speichern der Statusanzeige scheitern.
      final plan = planController;
      if (plan != null) await _planAction(plan.refreshAfterSync);
      try {
        await settings.setLastSuccessfulSyncAt(completedAt);
      } catch (error) {
        throw StateError(
          'Geräteabgleich erfolgreich, Zeitpunkt konnte nicht gespeichert '
          'werden: $error',
        );
      }
      lastSuccessfulSyncAt = completedAt;
      // Ueber _log statt nur ueber [status]: Ein automatisch
      // ausgeloester Abgleich soll im Protokoll nachvollziehbar sein,
      // auch wenn niemand auf den Bildschirm geschaut hat.
      _log(
        result.newlyStored == 0
            ? 'Keine neuen Messungen (${result.readFromDevice} gelesen).'
            : '${result.newlyStored} neue Messungen.',
      );
      if (autoExport && result.newlyStored > 0) await _autoExport();
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
    await _requireExportReady(slot);
    final n = await exportService.exportPending(userSlot: slot);
    status = '$n Messungen nach Health Connect geschrieben.';
  });

  Future<void> retractAll() => _run('Entferne…', () async {
    final slot = _requireSlot();
    final n = await exportService.retractExported(userSlot: slot);
    status = '$n Messungen aus Health Connect entfernt.';
  });

  Future<void> exportOne(Measurement m) => _run('Exportiere…', () async {
    if (m.userSlot != _requireSlot()) {
      throw StateError('Die Messung gehört zu einem anderen Speicherplatz.');
    }
    await _requireExportReady(m.userSlot);
    await exportService.exportOne(m);
    status = 'Messung nach Health Connect geschrieben.';
  });

  Future<void> retractOne(Measurement m) => _run('Entferne…', () async {
    await exportService.retractOne(m);
    status = 'Messung aus Health Connect entfernt.';
  });

  Future<void> _requireExportReady(int slot) async {
    if (await settings.intakeState(slot) != IntakeState.complete) {
      throw StateError('Bitte zuerst die Übernahme festlegen.');
    }
  }

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
    if (!_disposed) notifyListeners();
  }

  Future<void> _run(
    String initial,
    Future<void> Function() action, {
    bool restartScan = true,
  }) async {
    if (busy) throw StateError('Eine andere Aktion läuft bereits.');
    busy = true;
    status = initial;
    notifyListeners();
    try {
      // Ein noch ausstehender Stop darf nicht den Scan dieser Aktion beenden.
      await _watchTransitions;
      await action();
    } catch (e) {
      debugPrint('[Sphygma] Fehler: $e');
      status = 'Fehler: $e';
      rethrow;
    } finally {
      try {
        await _refresh();
      } finally {
        busy = false;
        if (!_disposed) notifyListeners();
        // Plattform-Cancel läuft asynchron; alle Übergänge teilen eine Kette.
        if (restartScan || _watch == null) unawaited(_restartWatching());
      }
    }
  }

  /// Überträgt neue Messungen nach Health Connect, wenn es eingeschaltet ist.
  ///
  /// **Scheitert leise, aber nicht spurlos.** Fehlt die Berechtigung, käme
  /// sonst nach jeder Messung dieselbe Fehlermeldung; der Abgleich selbst war
  /// ja erfolgreich, und seine Meldung soll nicht davon überschrieben werden.
  /// Der Grund bleibt in [autoExportProblem] stehen und ist in den
  /// Einstellungen zu sehen.
  Future<void> _autoExport() async {
    if (!autoExport) return;
    final slot = userSlot;
    if (slot == null) return;
    if (await settings.intakeState(slot) != IntakeState.complete) {
      autoExportProblem =
          'Bitte zuerst festlegen, welche Messungen übernommen werden.';
      return;
    }

    // **Nichts erzwingen.** Fehlen die Schreibrechte, öffnete der Export
    // einen Berechtigungsdialog — von selbst, während der Nutzer etwas
    // anderes tut, und im ungünstigsten Fall nach jeder Messung. Der Knopf
    // von Hand fragt weiterhin.
    // Eine Senke, die keine Rechte kennt, schreibt einfach — sie kann auch
    // keinen Dialog öffnen.
    if (exportService.sink case final PermissionAwareSink s) {
      final lage = await s.readiness();
      if (lage.erklaerung case final grund?) {
        autoExportProblem = grund;
        return;
      }
    }

    try {
      final anzahl = await exportService.exportPending(
        userSlot: slot,
        onlyNew: true,
      );
      autoExportProblem = null;
      if (anzahl > 0) _log('$anzahl an Health Connect übertragen.');
    } catch (e) {
      autoExportProblem = '$e';
      debugPrint('[Sphygma] Automatischer Export fehlgeschlagen: $e');
    }
  }

  /// Serialisiert Start und Stop, auch wenn weitere Aktionen dazwischen enden.
  Future<void> _restartWatching() {
    final transition = _watchTransitions.then((_) async {
      final previous = _watch;
      _watch = null;
      if (!_disposed) notifyListeners();
      await previous?.cancel();
      _startWatching();
      if (!_disposed) notifyListeners();
    });
    _watchTransitions = transition.catchError((Object error) {
      _onWatchError(error);
    });
    return _watchTransitions;
  }

  Future<void> _refresh() async {
    final slot = userSlot;
    if (slot == null) {
      measurements = const [];
      pendingExport = 0;
      exportStates = const {};
      clockLooksWrong = false;
      metadataBySequence = const {};
      tags = const [];
      phases = const [];
      manualPhaseSelections = const {};
      phaseIdsBySequence = const {};
      timestampVerdicts = const {};
      historyFilter = const HistoryFilter();
      intakeFloor = null;
      intakeState = IntakeState.complete;
    } else {
      intakeFloor = await repository.intakeFloor(slot);
      intakeState = await settings.intakeState(slot);
      measurements = (await repository.allForSlot(slot)).reversed.toList();
      pendingExport = (await repository.pendingExport(slot)).length;
      exportStates = await repository.exportStatesForSlot(slot);
      final now = _clock();
      timestampVerdicts = judgeTimestamps(measurements, now: now);
      clockLooksWrong = deviceClockLooksWrong(measurements, now: now);
      metadataBySequence = await metadataRepository.readSlot(slot);
      tags = await metadataRepository.tags(slot);
      phases = await phaseRepository.phases(slot);
      manualPhaseSelections = await phaseRepository.selections(slot);
      phaseIdsBySequence = Map.unmodifiable({
        for (final measurement in measurements)
          measurement.deviceSequence: resolvePhaseIds(
            measuredAt: measurement.measuredAt,
            timePlausible:
                timestampVerdicts[measurement.deviceSequence]?.isPlausible ==
                true,
            phases: phases,
            manualSelection: manualPhaseSelections[measurement.deviceSequence],
          ),
      });
      final validTagIds = tags.map((tag) => tag.id).toSet();
      final validPhaseIds = phases.map((phase) => phase.id).toSet();
      final keptTags = historyFilter.tagIds.intersection(validTagIds);
      final keptPhases = historyFilter.phaseIds.intersection(validPhaseIds);
      historyFilter = historyFilter.copyWith(
        tagIds: keptTags,
        tags:
            historyFilter.tags == MembershipFilter.selected && keptTags.isEmpty
            ? MembershipFilter.unrestricted
            : historyFilter.tags,
        phaseIds: keptPhases,
        phases:
            !phasesEnabled ||
                (historyFilter.phases == MembershipFilter.selected &&
                    keptPhases.isEmpty)
            ? MembershipFilter.unrestricted
            : historyFilter.phases,
      );
    }
    if (!_disposed) notifyListeners();
  }

  /// Der Nutzer entscheidet einen Grenzfall: Diese Messung gehört zum
  /// vorherigen Anlass.
  MeasurementKey measurementKey(int deviceSequence) =>
      (userSlot: _requireSlot(), deviceSequence: deviceSequence);

  /// Der Nutzer entscheidet einen Grenzfall: Diese Messung ist ein eigener
  /// Anlass.
  Future<void> saveMeasurementMetadata({
    required int deviceSequence,
    required String? note,
    required Set<int> tagIds,
  }) async {
    await metadataRepository.save(
      measurementKey(deviceSequence),
      note: note,
      tagIds: tagIds,
    );
    await _refresh();
  }

  /// Legt einen wiederverwendbaren Tag im aktiven Speicherplatz an.
  Future<int> createTag(String name) async {
    final id = await metadataRepository.createTag(_requireSlot(), name);
    await _refresh();
    return id;
  }

  /// Benennt einen Tag um; bestehende Zuordnungen bleiben erhalten.
  Future<void> renameTag(int tagId, String name) async {
    await metadataRepository.renameTag(tagId, name);
    await _refresh();
  }

  /// Löscht einen Tag und seine Zuordnungen, aber keine Messungen.
  Future<void> deleteTag(int tagId) async {
    await metadataRepository.deleteTag(tagId);
    await _refresh();
  }

  Future<int> savePhase({
    int? id,
    required String name,
    required DateTime begin,
    required DateTime? end,
  }) async {
    final result = await phaseRepository.savePhase(
      id: id,
      userSlot: _requireSlot(),
      name: name,
      begin: begin,
      end: end,
    );
    await _refresh();
    return result;
  }

  Future<void> selectPhases(int deviceSequence, Set<int> phaseIds) async {
    await phaseRepository.select(measurementKey(deviceSequence), phaseIds);
    await _refresh();
  }

  Future<void> deletePhase(int id) async {
    await phaseRepository.deletePhase(id);
    await _refresh();
  }

  Future<void> useAutomaticPhases(int deviceSequence) async {
    await phaseRepository.useAutomatic(measurementKey(deviceSequence));
    await _refresh();
  }

  Future<void> setPhasesEnabled(bool value) async {
    await settings.setPhasesEnabled(value);
    phasesEnabled = value;
    if (!value && historyFilter.phases != MembershipFilter.unrestricted) {
      historyFilter = historyFilter.copyWith(
        phaseIds: const {},
        phases: MembershipFilter.unrestricted,
      );
    }
    notifyListeners();
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
