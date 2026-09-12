import '../stats/measurement_metadata.dart';

class PlannedOccurrence {
  PlannedOccurrence({
    required this.key,
    required this.userSlot,
    required this.revisionId,
    required this.dueAt,
    required this.localDate,
    required this.minuteOfDay,
    required this.zoneId,
    required this.timeAmbiguous,
  }) {
    if (key.isEmpty) {
      throw ArgumentError.value(key, 'key', 'darf nicht leer sein');
    }
    _validateUserSlot(userSlot, 'userSlot');
    if (revisionId <= 0) {
      throw ArgumentError.value(revisionId, 'revisionId', 'muss positiv sein');
    }
    if (minuteOfDay < 0 || minuteOfDay >= minutesPerDay) {
      throw ArgumentError.value(
        minuteOfDay,
        'minuteOfDay',
        'muss zwischen 0 und 1439 liegen',
      );
    }
    parseLocalDate(localDate);

    final hasDueAt = dueAt != null;
    final hasZoneId = zoneId != null;
    if (hasDueAt != hasZoneId) {
      throw ArgumentError(
        'dueAt und zoneId müssen entweder beide gesetzt oder beide null sein',
      );
    }
    if (!hasDueAt && !timeAmbiguous) {
      throw ArgumentError(
        'Ein Termin ohne belegten Zeitpunkt und Zone muss mehrdeutig sein',
      );
    }
    if (dueAt != null && !dueAt!.isUtc) {
      throw ArgumentError.value(dueAt, 'dueAt', 'muss ein UTC-Zeitpunkt sein');
    }
    if (zoneId != null && zoneId!.trim().isEmpty) {
      throw ArgumentError.value(zoneId, 'zoneId', 'darf nicht leer sein');
    }
  }

  final String key;
  final int userSlot;
  final int revisionId;
  final DateTime? dueAt;
  final String localDate;
  final int minuteOfDay;
  final String? zoneId;
  final bool timeAmbiguous;
}

class TimedMeasurement {
  TimedMeasurement({
    required this.key,
    required this.localTime,
    required this.plausible,
  }) {
    _validateUserSlot(key.userSlot, 'key.userSlot');
  }

  final MeasurementKey key;

  /// Behälter für die zivilen Kalenderkomponenten der Geräteaufzeichnung.
  /// Seine UTC-/Lokalsemantik wird beim Matching absichtlich nicht verwendet.
  final DateTime localTime;
  final bool plausible;
}

const int minutesPerDay = 24 * 60;

DateTime parseLocalDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) {
    throw ArgumentError.value(value, 'localDate', 'erwartet YYYY-MM-DD');
  }

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final parsed = DateTime.utc(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    throw ArgumentError.value(value, 'localDate', 'ist kein gültiges Datum');
  }
  return parsed;
}

void _validateUserSlot(int userSlot, String name) {
  if (userSlot != 1 && userSlot != 2) {
    throw ArgumentError.value(userSlot, name, 'muss 1 oder 2 sein');
  }
}
