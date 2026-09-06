// Datums- und Zeitformat an einer Stelle. Deutsche Schreibweise, ohne
// intl-Abhaengigkeit: Die App zeigt nur diese eine Sprache.
String _two(int n) => n.toString().padLeft(2, '0');

String formatDay(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';

String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String formatDayAndTime(DateTime d) => '${formatDay(d)}, ${formatTime(d)}';

const List<String> _monate = [
  'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
  'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
];

/// Der Zeitraum einer Messwoche, so wie man ihn ausspricht:
/// „25. bis 31. August", über den Monatswechsel „29. September bis 5. Oktober".
String formatWeekRange(DateTime monday) {
  // Kalenderarithmetik wie in mondayOf: In der Woche der Herbstumstellung
  // umfassen sechs Kalendertage 145 Stunden, und ein Zuschlag in Stunden
  // landet am Samstag um 23 Uhr — der Zeitraum nennte dann den falschen Tag.
  final sonntag = DateTime(monday.year, monday.month, monday.day + 6);
  final bis = '${sonntag.day}. ${_monate[sonntag.month - 1]}';
  if (monday.month == sonntag.month) {
    return '${monday.day}. bis $bis';
  }
  return '${monday.day}. ${_monate[monday.month - 1]} bis $bis';
}
