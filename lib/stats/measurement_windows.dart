import 'dart:convert';

class MeasurementWindows {
  MeasurementWindows({
    required this.morningStart,
    required this.morningEnd,
    required this.eveningStart,
    required this.eveningEnd,
  }) {
    for (final entry in {
      'morningStart': morningStart,
      'morningEnd': morningEnd,
      'eveningStart': eveningStart,
      'eveningEnd': eveningEnd,
    }.entries) {
      if (entry.value < 0 || entry.value >= _minutesPerDay) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'muss zwischen 0 und 1439 liegen',
        );
      }
    }
    if (morningStart == morningEnd) {
      throw ArgumentError('Das Morgenfenster darf nicht leer sein');
    }
    if (eveningStart == eveningEnd) {
      throw ArgumentError('Das Abendfenster darf nicht leer sein');
    }
    for (var minute = 0; minute < _minutesPerDay; minute++) {
      if (_contains(minute, morningStart, morningEnd) &&
          _contains(minute, eveningStart, eveningEnd)) {
        throw ArgumentError('Morgen- und Abendfenster dürfen nicht überlappen');
      }
    }
  }

  static final MeasurementWindows defaults = MeasurementWindows(
    morningStart: 5 * 60,
    morningEnd: 10 * 60,
    eveningStart: 18 * 60,
    eveningEnd: 23 * 60,
  );

  static const int _minutesPerDay = 24 * 60;
  static const Set<String> _persistedKeys = {
    'version',
    'morningStart',
    'morningEnd',
    'eveningStart',
    'eveningEnd',
  };

  final int morningStart;
  final int morningEnd;
  final int eveningStart;
  final int eveningEnd;

  String get morningLabel => '${_format(morningStart)}–${_format(morningEnd)}';
  String get eveningLabel => '${_format(eveningStart)}–${_format(eveningEnd)}';

  bool isMorning(DateTime value) =>
      _contains(_minuteOfDay(value), morningStart, morningEnd);

  bool isEvening(DateTime value) =>
      _contains(_minuteOfDay(value), eveningStart, eveningEnd);

  String encode() => jsonEncode({
    'version': 1,
    'morningStart': morningStart,
    'morningEnd': morningEnd,
    'eveningStart': eveningStart,
    'eveningEnd': eveningEnd,
  });

  factory MeasurementWindows.decode(String encoded) {
    final Object? decoded;
    try {
      decoded = jsonDecode(encoded);
    } on FormatException {
      throw const FormatException('Ungültige Messzeitfenster');
    }
    if (decoded is! Map<String, dynamic> ||
        decoded.keys.toSet().difference(_persistedKeys).isNotEmpty ||
        _persistedKeys.difference(decoded.keys.toSet()).isNotEmpty ||
        decoded['version'] != 1 ||
        decoded['morningStart'] is! int ||
        decoded['morningEnd'] is! int ||
        decoded['eveningStart'] is! int ||
        decoded['eveningEnd'] is! int) {
      throw const FormatException('Ungültige Messzeitfenster');
    }
    try {
      return MeasurementWindows(
        morningStart: decoded['morningStart'] as int,
        morningEnd: decoded['morningEnd'] as int,
        eveningStart: decoded['eveningStart'] as int,
        eveningEnd: decoded['eveningEnd'] as int,
      );
    } on ArgumentError {
      throw const FormatException('Ungültige Messzeitfenster');
    }
  }

  static int _minuteOfDay(DateTime value) => value.hour * 60 + value.minute;

  static bool _contains(int minute, int start, int end) => start < end
      ? minute >= start && minute < end
      : minute >= start || minute < end;

  static String _format(int minute) {
    final hour = (minute ~/ 60).toString().padLeft(2, '0');
    final rest = (minute % 60).toString().padLeft(2, '0');
    return '$hour:$rest';
  }
}
