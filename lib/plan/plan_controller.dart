import 'dart:async';

import 'package:flutter/foundation.dart';

import '../db/measurement_plan_repository.dart';
import '../db/measurement_repository.dart';
import '../protocol/record.dart';
import '../stats/measurement_metadata.dart';
import '../stats/time_plausibility.dart';
import 'occurrence_matching.dart';
import 'plan_models.dart';
import 'reminder_gateway.dart';

abstract interface class ControllerCalendarTimer {
  void schedule(Duration delay, void Function() callback);
  void cancel();
}

class DartControllerCalendarTimer implements ControllerCalendarTimer {
  Timer? _timer;

  @override
  void schedule(Duration delay, void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

class _ReconcileFailure implements Exception {
  const _ReconcileFailure(this.cause);
  final Object cause;

  @override
  String toString() => cause.toString();
}

class PlanController extends ChangeNotifier {
  PlanController({
    required MeasurementPlanRepository repository,
    required MeasurementRepository measurements,
    required ReminderGateway gateway,
    DateTime Function()? now,
    ControllerCalendarTimer? calendarTimer,
    // Öffentliche Parameternamen bleiben Teil des stabilen Integrationsvertrags.
    // ignore: prefer_initializing_formals
  }) : _repository = repository,
       // ignore: prefer_initializing_formals
       _measurements = measurements,
       // ignore: prefer_initializing_formals
       _gateway = gateway,
       _now = now ?? DateTime.now,
       _calendarTimer = calendarTimer ?? DartControllerCalendarTimer();

  final MeasurementPlanRepository _repository;
  final MeasurementRepository _measurements;
  final ReminderGateway _gateway;
  final DateTime Function() _now;
  final ControllerCalendarTimer _calendarTimer;
  Future<void> _tail = Future.value();
  bool _disposed = false;
  bool _openPlanRequested = false;
  bool enabled = false;
  bool busy = false;
  ReminderMode mode = ReminderMode.off;
  String? error;
  int? userSlot;
  PlanDetails? currentSlotPlan;
  List<PlannedOccurrence> todayOccurrences = const [];
  Map<String, MeasurementKey> fulfillment = const {};
  PlannedOccurrence? nextOccurrence;
  Map<String, MeasurementKey> _allFulfillment = const {};

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) {
    final operation = _tail.then((_) async {
      if (_disposed) throw StateError('Messplan-Steuerung wurde geschlossen.');
      busy = true;
      error = null;
      _notify();
      try {
        await action();
      } catch (failure, stackTrace) {
        error = failure.toString();
        if (failure is _ReconcileFailure) {
          mode = ReminderMode.failed;
          try {
            final snapshot = await _repository.desiredSnapshot();
            await _repository.recordFailure(snapshot.generation, failure.cause);
            enabled = snapshot.enabled;
          } catch (persistenceFailure) {
            error =
                '${failure.cause}; Fehlerzustand konnte nicht gespeichert werden: $persistenceFailure';
          }
        }
        if (failure is _ReconcileFailure) {
          Error.throwWithStackTrace(failure.cause, stackTrace);
        }
        rethrow;
      } finally {
        busy = false;
        _notify();
      }
    });
    // Jeder Aufrufer erhält seinen Fehler; nur die Warteschlange läuft weiter.
    _tail = operation.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return operation;
  }

  int _slot() {
    final slot = userSlot;
    if (slot == null) {
      throw StateError('Bitte zuerst den Speicherplatz wählen.');
    }
    return slot;
  }

  Future<void> _reload() async {
    final now = _now();
    enabled = await _repository.isEnabled();
    currentSlotPlan = userSlot == null
        ? null
        : await _repository.readSlot(userSlot!);
    final all = <String, MeasurementKey>{};
    final bySlot = <int, List<PlannedOccurrence>>{};
    if (enabled) {
      for (final slot in [1, 2]) {
        final occurrences = await _repository.occurrences(slot);
        bySlot[slot] = occurrences;
        if (occurrences.isEmpty) continue;
        final measurements = await _measurements.allForSlot(slot);
        final verdicts = judgeTimestamps(measurements, now: now);
        final timed = <TimedMeasurement>[];
        for (final measurement in measurements) {
          final record = parseRecord(measurement.rawBytes);
          if (record == null || record.sequence != measurement.deviceSequence) {
            throw StateError(
              'Gespeicherte Rohaufzeichnung passt nicht zur Messung.',
            );
          }
          timed.add(
            TimedMeasurement(
              key: (userSlot: slot, deviceSequence: measurement.deviceSequence),
              localTime: record.civilTime.utcContainer,
              plausible: verdicts[measurement.deviceSequence]!.isPlausible,
            ),
          );
        }
        final visibleKeys = timed.map((m) => m.key).toSet();
        final manual = await _repository.assignments(slot);
        all.addAll(
          matchOccurrences(
            timed,
            occurrences,
            manualAssignments: {
              for (final entry in manual.entries)
                if (visibleKeys.contains(entry.key)) entry.key: entry.value,
            },
          ),
        );
      }
    }
    _allFulfillment = Map.unmodifiable(all);
    final slotOccurrences = bySlot[userSlot] ?? <PlannedOccurrence>[];
    final day =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    todayOccurrences = List.unmodifiable(
      slotOccurrences.where((o) => o.localDate == day),
    );
    fulfillment = Map.unmodifiable({
      for (final e in all.entries)
        if (e.value.userSlot == userSlot) e.key: e.value,
    });
    final pending =
        slotOccurrences
            .where(
              (o) =>
                  o.dueAt != null &&
                  o.dueAt!.isAfter(now) &&
                  !all.containsKey(o.key),
            )
            .toList()
          ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
    nextOccurrence = pending.isEmpty ? null : pending.first;
    _scheduleVisibleRefresh(now);
  }

  void _scheduleVisibleRefresh(DateTime now) {
    _calendarTimer.cancel();
    if (_disposed) return;
    final midnight = DateTime(now.year, now.month, now.day + 1);
    var deadline = midnight;
    final due = nextOccurrence?.dueAt;
    if (due != null && due.isBefore(deadline)) deadline = due;
    final reconcileNative = deadline == midnight;
    var delay = deadline.difference(now) + const Duration(milliseconds: 1);
    if (delay.isNegative) delay = Duration.zero;
    _calendarTimer.schedule(delay, () {
      unawaited(
        _run(reconcileNative ? _reconcile : _reload).catchError((Object _) {}),
      );
    });
  }

  void _captureReceiptState(ReminderReceipt receipt) {
    _openPlanRequested |= receipt.openPlanRequested;
  }

  Future<void> _inspectNative() async {
    final receipt = await _gateway.inspect();
    _captureReceiptState(receipt);
    var desired = await _repository.desiredSnapshot();
    if (receipt.generation > desired.generation) {
      await _repository.advanceGenerationBeyond(receipt.generation);
      return;
    }
    if (receipt.generation < desired.generation) return;
    if (!await _repository.acceptReceipt(receipt)) return;
    mode = receipt.mode;
    error = receipt.error;
  }

  Future<void> _consumeAccessReceipt(ReminderReceipt receipt) async {
    _captureReceiptState(receipt);
    final desired = await _repository.desiredSnapshot();
    if (receipt.generation > desired.generation) {
      await _repository.advanceGenerationBeyond(receipt.generation);
      return;
    }
    if (receipt.generation == desired.generation) {
      await _repository.acceptReceipt(receipt);
      mode = receipt.mode;
      error = receipt.error;
    }
  }

  Future<ReminderReceipt> _replace() async {
    var desired = await _repository.desiredSnapshot(
      fulfilledKeys: _allFulfillment.keys.toList(),
    );
    var receipt = await _gateway.replace(desired);
    _captureReceiptState(receipt);
    if (receipt.generation > desired.generation) {
      await _repository.advanceGenerationBeyond(receipt.generation);
      desired = await _repository.desiredSnapshot(
        fulfilledKeys: _allFulfillment.keys.toList(),
      );
      receipt = await _gateway.replace(desired);
      _captureReceiptState(receipt);
    }
    if (receipt.generation != desired.generation) {
      throw StateError(
        'Die Erinnerungsquittung gehört zu einer überholten Konfiguration.',
      );
    }
    if (receipt.mode == ReminderMode.failed) {
      await _repository.acceptReceipt(receipt);
      throw StateError(
        receipt.error ??
            'Erinnerungsplanung ohne Fehlerbeschreibung fehlgeschlagen.',
      );
    }
    if (receipt.appliedGeneration != desired.generation) {
      throw StateError(
        'Die Anwendung der Erinnerungsplanung ist nicht bestätigt.',
      );
    }
    if (!await _repository.acceptReceipt(receipt)) {
      throw StateError(
        'Die Erinnerungsquittung gehört zu einer überholten Konfiguration.',
      );
    }
    mode = receipt.mode;
    error = receipt.error;
    return receipt;
  }

  Future<void> _reconcile({bool inspectFirst = true}) async {
    try {
      if (inspectFirst) await _inspectNative();
      await _reload();
      final before = _allFulfillment.keys.toSet();
      final receipt = await _replace();
      await _reload();
      if (receipt.occurrences.isNotEmpty ||
          receipt.timeChanges.isNotEmpty ||
          receipt.retiredOccurrenceKeys.isNotEmpty ||
          !setEquals(before, _allFulfillment.keys.toSet())) {
        await _replace();
        await _reload();
      }
    } catch (failure) {
      if (failure is _ReconcileFailure) rethrow;
      throw _ReconcileFailure(failure);
    }
  }

  Future<void> load() => _run(_reconcile);
  Future<void> reconcileReminders() => _run(_reconcile);

  Future<void> setUserSlot(int slot) => _run(() async {
    if (slot != 1 && slot != 2) throw ArgumentError.value(slot, 'slot');
    userSlot = slot;
    await _reload();
  });

  Future<void> setEnabled(bool value) => _run(() async {
    final wasEnabled = await _repository.isEnabled();
    await _repository.setFeatureEnabled(value);
    enabled = value;
    if (value && !wasEnabled) {
      try {
        await _consumeAccessReceipt(await _gateway.requestAccess());
      } catch (failure) {
        throw _ReconcileFailure(failure);
      }
    }
    await _reconcile(inspectFirst: false);
  });

  Future<void> saveTimes(List<int> minutes) => _run(() async {
    final slot = _slot();
    final current = await _repository.readSlot(slot);
    if (current == null || current.plan.endedAt != null) {
      await _repository.start(slot, minutes);
    } else {
      await _repository.changeTimes(current.plan.id, minutes);
    }
    await _reconcile(inspectFirst: false);
  });

  Future<void> endPlan() => _run(() async {
    final current = await _repository.readSlot(_slot());
    if (current == null) throw StateError('Es gibt keinen Messplan.');
    await _repository.end(current.plan.id);
    await _reconcile(inspectFirst: false);
  });

  Future<void> refreshAfterSync() => _run(() async {
    await _repository.markMeasurementsChanged();
    await _reconcile(inspectFirst: false);
  });

  Future<void> requestAccess() => _run(() async {
    if (!enabled) throw StateError('Der Messplan ist ausgeschaltet.');
    try {
      await _consumeAccessReceipt(await _gateway.requestAccess());
    } catch (failure) {
      throw _ReconcileFailure(failure);
    }
    await _reconcile(inspectFirst: false);
  });

  Future<void> assign(MeasurementKey key, String? occurrenceKey) =>
      _run(() async {
        if (key.userSlot != _slot()) {
          throw ArgumentError(
            'Die Messung gehört zu einem anderen Speicherplatz.',
          );
        }
        await _repository.assign(key, occurrenceKey);
        await _reconcile(inspectFirst: false);
      });

  Future<void> useAutomaticAssignment(MeasurementKey key) => _run(() async {
    if (key.userSlot != _slot()) {
      throw ArgumentError('Die Messung gehört zu einem anderen Speicherplatz.');
    }
    await _repository.useAutomaticAssignment(key);
    await _reconcile(inspectFirst: false);
  });

  bool takeOpenPlanRequest() {
    final request = _openPlanRequested && enabled;
    _openPlanRequested = false;
    return request;
  }

  @override
  void dispose() {
    _disposed = true;
    _calendarTimer.cancel();
    super.dispose();
  }
}
