import 'plan_models.dart';

enum ReminderMode { off, exact, inexact, blocked, failed }

class ReminderRule {
  const ReminderRule({
    required this.planId,
    required this.revisionId,
    required this.userSlot,
    required this.minutesOfDay,
    required this.effectiveAtUtc,
    this.endsAtUtc,
  });
  final int planId, revisionId, userSlot;
  final List<int> minutesOfDay;
  final DateTime effectiveAtUtc;
  final DateTime? endsAtUtc;
  Map<String, Object?> toJson() => {
    'planId': planId,
    'revisionId': revisionId,
    'userSlot': userSlot,
    'minutesOfDay': minutesOfDay,
    'effectiveAtUtc': effectiveAtUtc.toUtc().toIso8601String(),
    'endsAtUtc': endsAtUtc?.toUtc().toIso8601String(),
  };
}

class ReminderSnapshot {
  const ReminderSnapshot({
    required this.generation,
    required this.enabled,
    required this.rules,
    this.fulfilledKeys = const [],
    this.acknowledgedOccurrenceKeys = const [],
    this.acknowledgedEventIds = const [],
  });
  final int generation;
  final bool enabled;
  final List<ReminderRule> rules;
  final List<String> fulfilledKeys,
      acknowledgedOccurrenceKeys,
      acknowledgedEventIds;
  Map<String, Object?> toJson() => {
    'protocolVersion': 1,
    'generation': generation,
    'enabled': enabled,
    'rules': rules.map((rule) => rule.toJson()).toList(),
    'fulfilledKeys': fulfilledKeys,
    'acknowledgedOccurrenceKeys': acknowledgedOccurrenceKeys,
    'acknowledgedEventIds': acknowledgedEventIds,
  };
}

class ReminderTimeChange {
  const ReminderTimeChange({
    required this.eventId,
    required this.occurredAtUtc,
    required this.oldZoneId,
    required this.newZoneId,
  });
  final String eventId;
  final DateTime occurredAtUtc;
  final String? oldZoneId;
  final String newZoneId;
}

class ReminderReceipt {
  const ReminderReceipt({
    required this.generation,
    this.appliedGeneration,
    required this.mode,
    required this.notificationsAllowed,
    required this.exactAllowed,
    required this.channelBlocked,
    required this.pendingOccurrenceKeys,
    required this.occurrences,
    required this.timeChanges,
    this.error,
    this.openPlanRequested = false,
    this.retiredOccurrenceKeys = const [],
  });
  final int generation;
  final int? appliedGeneration;
  final ReminderMode mode;
  final bool notificationsAllowed,
      exactAllowed,
      channelBlocked,
      openPlanRequested;
  final List<String> pendingOccurrenceKeys;
  final List<String> retiredOccurrenceKeys;
  final List<PlannedOccurrence> occurrences;
  final List<ReminderTimeChange> timeChanges;
  final String? error;

  factory ReminderReceipt.fromJson(Map<Object?, Object?> json) {
    if (json['protocolVersion'] != 1) {
      throw const FormatException('Unbekanntes Erinnerungsprotokoll');
    }
    DateTime utc(Object? value) {
      final result = DateTime.parse(value as String);
      if (!result.isUtc) throw const FormatException('UTC-Zeitpunkt erwartet');
      return result;
    }

    for (final field in [
      'generation',
      'appliedGeneration',
      'mode',
      'notificationsAllowed',
      'exactAllowed',
      'channelBlocked',
      'pendingOccurrenceKeys',
      'retiredOccurrenceKeys',
      'occurrences',
      'timeChanges',
      'error',
      'openPlanRequested',
    ]) {
      if (!json.containsKey(field)) {
        throw FormatException('Pflichtfeld fehlt: $field');
      }
    }
    final mode = ReminderMode.values.byName(json['mode'] as String);
    final error = json['error'] as String?;
    if (mode == ReminderMode.failed && (error == null || error.isEmpty)) {
      throw const FormatException('Fehlermodus ohne Fehlerbeschreibung');
    }
    return ReminderReceipt(
      generation: json['generation'] as int,
      appliedGeneration: json['appliedGeneration'] as int?,
      mode: mode,
      notificationsAllowed: json['notificationsAllowed'] as bool,
      exactAllowed: json['exactAllowed'] as bool,
      channelBlocked: json['channelBlocked'] as bool,
      openPlanRequested: json['openPlanRequested'] as bool,
      pendingOccurrenceKeys: (json['pendingOccurrenceKeys'] as List)
          .cast<String>(),
      retiredOccurrenceKeys: (json['retiredOccurrenceKeys'] as List)
          .cast<String>(),
      occurrences: (json['occurrences'] as List).map((value) {
        final row = value as Map;
        return PlannedOccurrence(
          key: row['key'] as String,
          userSlot: row['userSlot'] as int,
          revisionId: row['revisionId'] as int,
          dueAt: row['dueAt'] == null ? null : utc(row['dueAt']),
          localDate: row['localDate'] as String,
          minuteOfDay: row['minuteOfDay'] as int,
          zoneId: row['zoneId'] as String?,
          timeAmbiguous: row['timeAmbiguous'] as bool,
        );
      }).toList(),
      timeChanges: (json['timeChanges'] as List).map((value) {
        final row = value as Map;
        return ReminderTimeChange(
          eventId: row['eventId'] as String,
          occurredAtUtc: utc(row['occurredAtUtc']),
          oldZoneId: row['oldZoneId'] as String?,
          newZoneId: row['newZoneId'] as String,
        );
      }).toList(),
      error: error,
    );
  }
}

abstract interface class ReminderGateway {
  Future<ReminderReceipt> replace(ReminderSnapshot desired);
  Future<ReminderReceipt> inspect();
  Future<ReminderReceipt> requestAccess();
  Future<ReminderReceipt> openAccessSettings();
}
