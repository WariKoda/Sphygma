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
  final sonntag = monday.add(const Duration(days: 6));
  final bis = '${sonntag.day}. ${_monate[sonntag.month - 1]}';
  if (monday.month == sonntag.month) {
    return '${monday.day}. bis $bis';
  }
  return '${monday.day}. ${_monate[monday.month - 1]} bis $bis';
}
