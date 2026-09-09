// Die Lizenzen der eingebetteten Schriften müssen im Paket landen.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/theme/font_licenses.dart';
import 'package:sphygma/ui/theme/typeface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('jede eingebettete Familie bringt einen Lizenztext mit', () {
    // Wer eine Schrift hinzufügt, ohne ihre Lizenz einzutragen, liefert sie
    // ohne aus — und verletzt die OFL. Der Test knüpft beides aneinander.
    final familien = Typeface.values
        .map((t) => typefaceStyleFor(t).fontFamily)
        .whereType<String>()
        .toSet();
    expect(familien, isNotEmpty);
    expect(
      fontLicenseAssets.length,
      familien.length,
      reason:
          'Eingebettete Familien: $familien, hinterlegte Lizenzen: '
          '${fontLicenseAssets.keys}',
    );
  });

  test('die Lizenztexte sind im Paket und nennen die OFL', () async {
    for (final entry in fontLicenseAssets.entries) {
      final text = await rootBundle.loadString(entry.value);
      expect(
        text,
        contains('SIL OPEN FONT LICENSE'),
        reason: '${entry.key}: ${entry.value} ist kein OFL-Text',
      );
      expect(text, contains('Copyright'), reason: entry.key);
    }
  });
}
