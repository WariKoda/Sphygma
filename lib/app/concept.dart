// Das Konzept: wie die App organisiert ist.
//
// Zwei freie Achsen tragen die Oberfläche. Die **Gestaltung**
// (lib/ui/theme/variants.dart) bestimmt, wie es aussieht — Farben, Formen,
// Abstände. Das **Konzept** bestimmt, wie es geordnet ist: welche Bildschirme
// es gibt und worüber man an die Messungen herankommt.
//
// Beide sind frei kombinierbar. Jedes Konzept deckt denselben Funktionsumfang
// ab (docs/design/funktionsraster.md); es unterscheidet sich darin, wo eine
// Funktion sitzt und über welches Objekt man sie erreicht — nicht darin, ob
// es sie gibt. Ein Konzept, das etwas weglässt, wäre kein Konzept, sondern
// ein Ausschnitt.
library;

/// Die Ordnungen, in denen die App dieselben Daten zeigen kann.
enum AppConcept {
  /// Einheit: die einzelne Messung. Drei Bereiche, Zeitraumfilter darüber.
  /// So ist die App gewachsen — nie ausgesprochen, aber vorhanden.
  klassisch(
    'Messung und Filter',
    'Die einzelne Messung',
    'Heute, Verlauf und Gerät. Der Zeitraum filtert alle Messungen.',
  ),

  /// Einheit: die Messwoche. Sieben Tage, morgens und abends, erster Tag
  /// verworfen — so verlangt es die Leitlinie für die Selbstmessung.
  siebenTage(
    'Sieben Tage',
    'Die Messwoche',
    'Vierzehn Felder je Woche. Eine Woche ist vollständig oder nicht, und '
        'ihr Wert gilt in der Sprechstunde.',
  ),

  /// Einheit: die Tageszeit. Alle Messungen liegen auf einer Tagesachse,
  /// die Chronologie ist nicht mehr die Zugangsachse.
  tagesprofil(
    'Tagesprofil',
    'Die Tageszeit',
    'Wann ist der Druck hoch — morgens, abends, nachts? Die Antwort, die '
        'kein anderes Konzept gibt.',
  ),

  /// Einheit: das einzelne Messen. Wer zweimal hintereinander misst, hat
  /// ein Ergebnis mit mehreren Rohwerten, nicht zwei Einträge.
  messanlass(
    'Messanlass',
    'Das einzelne Messen',
    'Mehrere Messungen kurz hintereinander sind ein Anlass mit einem '
        'Ergebnis. Die Rohwerte bleiben nachlesbar.',
  ),

  /// Einheit: der benannte Lebensabschnitt. „Ramipril 5 mg", „Urlaub".
  phase(
    'Phase',
    'Der benannte Lebensabschnitt',
    'Hat die Umstellung etwas bewirkt? Phasen werden benannt und '
        'gegeneinander gestellt.',
  );

  const AppConcept(this.label, this.unit, this.description);

  /// Der Name, unter dem das Konzept in der Auswahl steht.
  final String label;

  /// Die Einheit, um die es gebaut ist — in drei Worten.
  final String unit;

  /// Ein Satz dazu, was es beantwortet und was die anderen nicht können.
  final String description;
}

/// Alle Konzepte in der Reihenfolge, in der sie zur Wahl stehen.
const List<AppConcept> allConcepts = AppConcept.values;
