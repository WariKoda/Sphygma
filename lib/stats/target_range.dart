// Der Zielbereich für die Selbstmessung zu Hause.
//
// Für die Heimmessung gilt eine niedrigere Schwelle als in der Sprechstunde:
// 135/85 statt 140/90. Wer zu Hause misst, ist entspannter, und die Leitlinien
// tragen dem Rechnung. Die beiden Schwellen zu verwechseln hieße, jemanden
// fälschlich zu beruhigen.
//
// Das ist etwas anderes als die ESC-Klassifikation in esc_classification.dart:
// Die stuft in sechs Kategorien ein und liegt hinter einem Compile-Time-Flag,
// weil sie die App zum Medizinprodukt machen kann. Hier geht es nur um die
// drei Tonstufen, mit denen die Konzepte ihre Messfelder einfärben.
library;

/// Wo ein Messwert gegenüber dem Zielbereich steht.
enum TargetZone {
  imZielbereich('Im Zielbereich'),
  grenzwertig('Grenzwertig'),
  darueber('Darüber');

  const TargetZone(this.label);

  final String label;
}

/// Ein Schwellenpaar mit der Einordnung, die daraus folgt.
class TargetRange {
  /// Prüft mit echten Fehlern statt mit `assert`: Zusicherungen sind im
  /// Release-Modus abgeschaltet, und eine unsinnige Schwelle wäre dort still
  /// durchgegangen. Das schließt einen const-Konstruktor aus — die Prüfung
  /// wiegt schwerer.
  TargetRange({required this.systolicLimit, required this.diastolicLimit}) {
    if (systolicLimit <= 0) {
      throw ArgumentError.value(
          systolicLimit, 'systolicLimit', 'muss positiv sein');
    }
    if (diastolicLimit <= 0) {
      throw ArgumentError.value(
          diastolicLimit, 'diastolicLimit', 'muss positiv sein');
    }
    if (diastolicLimit >= systolicLimit) {
      throw ArgumentError.value(
        diastolicLimit,
        'diastolicLimit',
        'liegt nicht unter der systolischen Schwelle ($systolicLimit)',
      );
    }
    if (systolicLimit < 90) {
      throw ArgumentError.value(
        systolicLimit,
        'systolicLimit',
        'unter 90 mmHg ist keine sinnvolle Schwelle für Bluthochdruck',
      );
    }
  }

  /// Die Schwellen der Selbstmessung: 135/85.
  static final TargetRange heim =
      TargetRange(systolicLimit: 135, diastolicLimit: 85);

  /// Die Schwellen der Sprechstunde: 140/90. Nicht für Heimwerte verwenden.
  static final TargetRange praxis =
      TargetRange(systolicLimit: 140, diastolicLimit: 90);

  final int systolicLimit;
  final int diastolicLimit;

  /// Wie weit unter der Schwelle es noch „grenzwertig" heißt.
  ///
  /// Fünf mmHg: eng genug, dass die Stufe etwas bedeutet, weit genug, dass sie
  /// vorkommt. Ein Wert knapp unter der Grenze ist keine Entwarnung.
  static const int _grenzbereich = 5;

  /// Die Einordnung eines Messwerts.
  ///
  /// **Der schlechtere der beiden Werte entscheidet.** Ein tadelloser
  /// systolischer Wert macht einen zu hohen diastolischen nicht wett; gemittelt
  /// wird hier nichts.
  TargetZone classify({required int systolic, required int diastolic}) {
    if (systolic <= 0) {
      throw ArgumentError.value(systolic, 'systolic', 'muss positiv sein');
    }
    if (diastolic <= 0) {
      throw ArgumentError.value(diastolic, 'diastolic', 'muss positiv sein');
    }
    if (diastolic >= systolic) {
      throw ArgumentError.value(
        diastolic,
        'diastolic',
        'liegt nicht unter dem systolischen Wert ($systolic) — das ist kein '
            'Blutdruck, sondern ein Fehler beim Einlesen',
      );
    }

    if (systolic >= systolicLimit || diastolic >= diastolicLimit) {
      return TargetZone.darueber;
    }
    if (systolic >= systolicLimit - _grenzbereich ||
        diastolic >= diastolicLimit - _grenzbereich) {
      return TargetZone.grenzwertig;
    }
    return TargetZone.imZielbereich;
  }
}
