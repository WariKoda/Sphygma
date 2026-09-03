// ESC/ESH-Klassifikation. Liegt in der UI hinter dem Compile-Time-Flag
// [escClassificationEnabled] (feature_flags.dart): eine Einordnung in
// Hypertonie-Grade ist eine Interpretation zum Nutzen des Einzelnen und
// kann die App nach MDCG 2019-11 zum Medizinprodukt machen (PLAN.md §3.2).
//
// Schwellen: 2018 ESC/ESH Guidelines for the management of arterial
// hypertension, Eur Heart J 2018;39:3021-3104 -
// Tabelle 3 (Praxisblutdruck-Kategorien) und Tabelle 9 (Heimblutdruck:
// Hypertonie ab 135/85 mmHg). Die Kategorie richtet sich nach dem
// hoeheren der beiden Werte.

enum EscCategory { optimal, normal, highNormal, grade1, grade2, grade3 }

EscCategory classifyOffice({required int systolic, required int diastolic}) {
  final bySystolic = switch (systolic) {
    >= 180 => EscCategory.grade3,
    >= 160 => EscCategory.grade2,
    >= 140 => EscCategory.grade1,
    >= 130 => EscCategory.highNormal,
    >= 120 => EscCategory.normal,
    _ => EscCategory.optimal,
  };
  final byDiastolic = switch (diastolic) {
    >= 110 => EscCategory.grade3,
    >= 100 => EscCategory.grade2,
    >= 90 => EscCategory.grade1,
    >= 85 => EscCategory.highNormal,
    >= 80 => EscCategory.normal,
    _ => EscCategory.optimal,
  };
  return bySystolic.index >= byDiastolic.index ? bySystolic : byDiastolic;
}

/// Heimblutdruck-Schwelle der Leitlinie (Tabelle 9): >= 135 und/oder >= 85.
/// Dieselbe Schwelle nutzt das Geraet fuer sein Hypertonie-Symbol.
bool isHomeHypertension({required int systolic, required int diastolic}) =>
    systolic >= 135 || diastolic >= 85;
