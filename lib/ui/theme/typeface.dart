import 'package:flutter/widgets.dart';

enum Typeface {
  /// Die Schrift des Telefons. Kostet nichts und bettet nichts ein — der
  /// richtige Standard, solange keine eigene Familie ausgewählt ist
  /// (docs/design/gestaltung-drei-achsen.md, „Schriften").
  system('System'),

  /// Eine technische Grotesk. Schmale Ziffern, klare Grundformen — sie trägt
  /// die großen Messwerte, ohne sie zu schmücken.
  grotesk('Grotesk'),

  /// Eine Serif für ruhiges Lesen. Sie macht aus dem Verlauf eher ein
  /// Tagebuch als eine Tabelle.
  serif('Serif');

  const Typeface(this.label);

  /// Sichtbarer Name in der Auswahl.
  final String label;
}

enum WeightRole { sehrLeicht, leicht, normal, halbfett, fett }

@immutable
class TypefaceStyle {
  TypefaceStyle({
    required this.fontFamily,
    required Set<FontWeight> availableWeights,
    required this.hasTabularFigures,
  }) : availableWeights = Set.unmodifiable(availableWeights) {
    if (availableWeights.isEmpty) {
      throw ArgumentError.value(
        availableWeights,
        'availableWeights',
        'Eine Schrift braucht mindestens einen Schnitt.',
      );
    }
    if (!hasTabularFigures) {
      throw ArgumentError('Messwerte brauchen tabellarische Ziffern.');
    }
  }

  /// Null überlässt die Familie wie bisher der Plattform.
  final String? fontFamily;
  final Set<FontWeight> availableWeights;
  final bool hasTabularFigures;

  FontWeight weightFor(WeightRole role) {
    final target = switch (role) {
      WeightRole.sehrLeicht => FontWeight.w200,
      WeightRole.leicht => FontWeight.w300,
      WeightRole.normal => FontWeight.w400,
      WeightRole.halbfett => FontWeight.w500,
      WeightRole.fett => FontWeight.w700,
    };
    // Bei gleichem Abstand gewinnt der leichtere Schnitt: Die Abbildung
    // darf nicht von der Reihenfolge einer Menge abhängen.
    return availableWeights.reduce((a, b) {
      final da = (a.value - target.value).abs();
      final db = (b.value - target.value).abs();
      return db < da || (db == da && b.value < a.value) ? b : a;
    });
  }
}

// System bleibt der bisherige Plattformvertrag. Die tatsächlich installierte
// Familie bestimmt das Gerät; eigene Familien müssen ihre Schnitte und
// tabellarischen Ziffern ausdrücklich deklarieren.
final _system = TypefaceStyle(
  fontFamily: null,
  availableWeights: {
    FontWeight.w200,
    FontWeight.w300,
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w700,
  },
  hasTabularFigures: true,
);

/// Archivo, variabel von 100 bis 900 — an der eingebetteten Datei geprüft.
///
/// Bei einer variablen Schrift genügt **eine** Datei für alle Schnitte; die
/// Gewichtsrolle wird über die wght-Achse gestellt, nicht über getrennte
/// Dateien. Deshalb gilt hier jedes Gewicht als vorhanden.
final _grotesk = TypefaceStyle(
  fontFamily: 'Archivo',
  availableWeights: {
    FontWeight.w200,
    FontWeight.w300,
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w700,
  },
  hasTabularFigures: true,
);

/// Source Serif 4, variabel von 200 bis 900.
///
/// Ihre Achse beginnt bei 200 — ExtraLight gibt es nicht darunter. Für die
/// Rolle `sehrLeicht` ist das genau der Grenzfall, den die Rollen abfangen.
final _serif = TypefaceStyle(
  fontFamily: 'SourceSerif4',
  availableWeights: {
    FontWeight.w200,
    FontWeight.w300,
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w700,
  },
  hasTabularFigures: true,
);

TypefaceStyle typefaceStyleFor(Typeface typeface) => switch (typeface) {
  Typeface.system => _system,
  Typeface.grotesk => _grotesk,
  Typeface.serif => _serif,
};
