import 'package:flutter/services.dart';

import 'reminder_gateway.dart';

class AndroidReminderGateway implements ReminderGateway {
  AndroidReminderGateway({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('de.bdgraue.sphygma/reminders');
  final MethodChannel _channel;

  Future<ReminderReceipt> _invoke(String method, [Object? arguments]) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      method,
      arguments,
    );
    if (result == null) throw const FormatException('Erinnerungsbeleg fehlt');
    return ReminderReceipt.fromJson(result);
  }

  @override
  Future<ReminderReceipt> replace(ReminderSnapshot desired) =>
      _invoke('replace', desired.toJson());
  @override
  Future<ReminderReceipt> inspect() => _invoke('inspect');
  @override
  Future<ReminderReceipt> requestAccess() => _invoke('requestAccess');
  @override
  Future<ReminderReceipt> openAccessSettings() => _invoke('openAccessSettings');
}
