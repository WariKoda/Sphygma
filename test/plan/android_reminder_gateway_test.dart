import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/plan/android_reminder_gateway.dart';
import 'package:sphygma/plan/reminder_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('de.bdgraue.sphygma/reminders');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  test('vollständiger Beleg und Ack-Snapshot durchlaufen den Kanal', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'replace');
      expect((call.arguments as Map)['acknowledgedEventIds'], ['ack']);
      return {
        'protocolVersion': 1,
        'generation': 7,
        'appliedGeneration': 7,
        'mode': 'inexact',
        'notificationsAllowed': true,
        'exactAllowed': false,
        'channelBlocked': false,
        'openPlanRequested': false,
        'pendingOccurrenceKeys': ['o'],
        'retiredOccurrenceKeys': ['retired'],
        'error': null,
        'occurrences': [
          {
            'key': 'o',
            'userSlot': 1,
            'revisionId': 2,
            'dueAt': '2026-09-11T06:00:00Z',
            'localDate': '2026-09-11',
            'minuteOfDay': 480,
            'zoneId': 'Europe/Berlin',
            'timeAmbiguous': false,
          },
        ],
        'timeChanges': [
          {
            'eventId': 'e',
            'occurredAtUtc': '2026-09-11T05:00:00Z',
            'oldZoneId': null,
            'newZoneId': 'Europe/Berlin',
          },
        ],
      };
    });
    final result = await AndroidReminderGateway().replace(
      const ReminderSnapshot(
        generation: 7,
        enabled: true,
        rules: [],
        acknowledgedEventIds: ['ack'],
      ),
    );
    expect(result.mode, ReminderMode.inexact);
    expect(result.retiredOccurrenceKeys, ['retired']);
    expect(result.occurrences.single.dueAt, DateTime.utc(2026, 9, 11, 6));
    expect(result.timeChanges.single.oldZoneId, isNull);
  });
  test('leere und falsche Antworten scheitern ausdrücklich', () async {
    for (final value in [
      null,
      <String, Object?>{},
      {'protocolVersion': 99},
    ]) {
      messenger.setMockMethodCallHandler(channel, (_) async => value);
      await expectLater(
        AndroidReminderGateway().inspect(),
        throwsFormatException,
      );
    }
  });
  test('öffnet Berechtigungseinstellungen über eigenen Kanalaufruf', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'openAccessSettings');
      expect(call.arguments, isNull);
      return {
        'protocolVersion': 1,
        'generation': 0,
        'appliedGeneration': 0,
        'mode': 'blocked',
        'notificationsAllowed': false,
        'exactAllowed': true,
        'channelBlocked': false,
        'openPlanRequested': false,
        'pendingOccurrenceKeys': <String>[],
        'retiredOccurrenceKeys': <String>[],
        'error': null,
        'occurrences': <Object?>[],
        'timeChanges': <Object?>[],
      };
    });

    final result = await AndroidReminderGateway().openAccessSettings();

    expect(result.mode, ReminderMode.blocked);
  });
}
