import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/measurement_week.dart';
import 'package:sphygma/ui/format.dart';

void main() {
  test('Tag mit fuehrenden Nullen', () {
    expect(formatDay(DateTime(2026, 9, 5)), '05.09.2026');
  });

  test('Uhrzeit mit fuehrenden Nullen', () {
    expect(formatTime(DateTime(2026, 9, 5, 7, 4)), '07:04');
  });

  test('Tag und Uhrzeit zusammen', () {
    expect(
      formatDayAndTime(DateTime(2026, 9, 5, 23, 57)),
      '05.09.2026, 23:57',
    );
  });

  group('Der Wochenzeitraum', () {
    test('nennt Montag und Sonntag, auch in Umstellungswochen', () {
      // Sechs Kalendertage sind in der Herbstwoche 145 Stunden. Ein Zuschlag
      // in Stunden landete am Samstag — die Prüfung gilt in jeder Zeitzone,
      // in der umgestellt wird.
      for (var tag = DateTime(2026); tag.year == 2026;
          tag = DateTime(tag.year, tag.month, tag.day + 1)) {
        final montag = mondayOf(tag);
        final sonntag = DateTime(montag.year, montag.month, montag.day + 6);
        expect(sonntag.weekday, DateTime.sunday, reason: '$tag');
        expect(formatWeekRange(montag), contains('${sonntag.day}.'),
            reason: '$tag');
      }
    });

    test('nennt den Monat nur einmal, wenn die Woche in einem liegt', () {
      expect(formatWeekRange(DateTime(2026, 8, 24)), '24. bis 30. August');
    });

    test('über den Monatswechsel stehen beide Monate', () {
      expect(
        formatWeekRange(DateTime(2026, 9, 28)),
        '28. September bis 4. Oktober',
      );
    });
  });
}
