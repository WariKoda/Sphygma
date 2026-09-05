import 'package:flutter_test/flutter_test.dart';
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
}
