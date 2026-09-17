/// Niedrige Komponenten werden getrennt erfasst: Eine hohe Systole darf eine
/// niedrige Diastole nicht verdecken (und umgekehrt).
enum LowBloodPressure {
  none,
  systolic,
  diastolic,
  both;

  String get label => switch (this) {
    none => throw StateError(
      'Ohne niedrige Komponente gibt es keinen Hinweis.',
    ),
    systolic => 'Systolisch niedrig',
    diastolic => 'Diastolisch niedrig',
    both => 'Systolisch und diastolisch niedrig',
  };
}

/// Referenz unter 90/60 nach NHS/NHLBI; jede Komponente wird einzeln geprüft.
/// Keine individuelle Diagnose und keine zusätzliche ESC/ESH-Hypertoniestufe.
/// Quellen und Abgrenzung: docs/research/niedriger-blutdruck.md.
LowBloodPressure lowBloodPressure({
  required int systolic,
  required int diastolic,
}) {
  if (systolic <= 0 || diastolic <= 0 || diastolic >= systolic) {
    throw ArgumentError('Ungültiger Blutdruck: $systolic/$diastolic');
  }
  return switch ((systolic < 90, diastolic < 60)) {
    (true, true) => LowBloodPressure.both,
    (true, false) => LowBloodPressure.systolic,
    (false, true) => LowBloodPressure.diastolic,
    (false, false) => LowBloodPressure.none,
  };
}
