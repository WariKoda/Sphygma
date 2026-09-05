// Datums- und Zeitformat an einer Stelle. Deutsche Schreibweise, ohne
// intl-Abhaengigkeit: Die App zeigt nur diese eine Sprache.
String _two(int n) => n.toString().padLeft(2, '0');

String formatDay(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';

String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String formatDayAndTime(DateTime d) => '${formatDay(d)}, ${formatTime(d)}';
