import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/low_blood_pressure.dart';
import 'package:sphygma/stats/esc_classification.dart';

void main() {
  test(
    'jede niedrige Komponente bleibt unabhängig von der anderen sichtbar',
    () {
      expect(
        lowBloodPressure(systolic: 89, diastolic: 70),
        LowBloodPressure.systolic,
      );
      expect(
        lowBloodPressure(systolic: 140, diastolic: 59),
        LowBloodPressure.diastolic,
      );
      expect(
        lowBloodPressure(systolic: 85, diastolic: 55),
        LowBloodPressure.both,
      );
      expect(
        lowBloodPressure(systolic: 90, diastolic: 60),
        LowBloodPressure.none,
      );
    },
  );
  test('ungültige Messungen erhalten keine plausible Einordnung', () {
    for (final (sys, dia) in [(0, 60), (90, 0), (-1, 60), (60, 90), (60, 60)]) {
      expect(
        () => lowBloodPressure(systolic: sys, diastolic: dia),
        throwsArgumentError,
      );
      expect(
        () => classifyOffice(systolic: sys, diastolic: dia),
        throwsArgumentError,
      );
    }
    expect(() => LowBloodPressure.none.label, throwsStateError);
  });
}
