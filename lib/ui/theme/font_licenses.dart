// Die Lizenztexte der eingebetteten Schriften — mitgeliefert, nicht nur
// mitgedacht.
//
// Die SIL Open Font License verlangt es wörtlich: Jede Kopie der Software
// „contains the above copyright notice and this license". Eine Datei im
// Git-Repository genügt dafür nicht, denn ausgeliefert wird das APK. Bis zum
// 09.09.2026 lagen die Texte nur daneben — aufgefallen im Codex-Gegenblick.
//
// Sichtbar werden sie über `showLicensePage`, wo sie neben den Lizenzen der
// verwendeten Pakete stehen.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Die eingebetteten Familien und ihr Lizenztext.
///
/// Der Schlüssel ist der Name, unter dem die Lizenz erscheint; der Wert der
/// Pfad zum Text. Wer eine Schrift hinzufügt, trägt sie hier ein — sonst
/// wird sie ohne ihre Lizenz ausgeliefert.
const Map<String, String> fontLicenseAssets = {
  'Archivo': 'assets/fonts/OFL-Archivo.txt',
  'Source Serif 4': 'assets/fonts/OFL-SourceSerif4.txt',
  'Source Code Pro': 'assets/fonts/OFL-SourceCodePro.txt',
};

/// Meldet die Schriftlizenzen bei Flutters Lizenzregister an.
///
/// Einmal beim Start aufzurufen. Schlägt das Lesen fehl, wirft es: Eine App,
/// die Schriften ohne ihre Lizenz ausliefert, verletzt sie — das darf nicht
/// stillschweigend passieren.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final entry in fontLicenseAssets.entries) {
      final text = await rootBundle.loadString(entry.value);
      if (text.trim().isEmpty) {
        throw StateError(
          'Der Lizenztext für ${entry.key} (${entry.value}) ist leer. '
          'Die Schrift darf so nicht ausgeliefert werden.',
        );
      }
      yield LicenseEntryWithLineBreaks(<String>[entry.key], text);
    }
  });
}
