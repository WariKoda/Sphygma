import 'typeface.dart';

enum CategoryRole { markierung, flaeche }

// Die Namen der Diagonale bleiben für das bestehende Einstellungsblatt erhalten.
/// Die Form: wie getrennt, geordnet und gebaut wird.
///
/// **Die Namen sind bewusst andere als die der alten Gestaltungen.** „Aura"
/// war keine Form, sondern eine ganze Gestaltung — sie ist in die Form
/// **Luft** und die Farbwelt **Nacht** zerfallen. Stünde hier weiter „Aura",
/// verspräche das Auswahlfeld eine Farbwelt, die es nicht liefert; bei „Pulse
/// Grid" und „Pegel" käme dazu, dass ihre Farbwelten (Petrol und Salbei) am
/// 09.09.2026 gestrichen wurden. Ein Formname nennt die Form, sonst nichts.
/// Wie der große Messwert gebaut ist.
///
/// Das ist kein Farbunterschied und keine Maßfrage, sondern **Aufbau** — der
/// Punkt, an dem sich die Formen unterscheiden sollen. Bis zum 09.09.2026
/// zeigten alle sechs denselben Bruch und trennten sich nur in Radius,
/// Abstand und Gewicht; genau deshalb sahen vier von ihnen gleich aus.
enum ReadingLayout {
  /// „144/92" — ein Wert, zwei Zahlen, ein Schrägstrich.
  bruch,

  /// SYS und DIA als zwei gleichwertige Blöcke mit Beschriftung darunter.
  ///
  /// Der Entwurf zu „Pulse Grid" verlangt es ausdrücklich: *„SYS und DIA als
  /// zwei gleichwertige Zahlenblöcke mit Beschriftung darunter — nicht als
  /// 124/85."* Der Bruch stellt den systolischen Wert voran; nebeneinander
  /// sind beide gleich wichtig.
  bloecke,
}

enum Characteristic {
  messinstrument(
    label: 'Messinstrument',
    radius: 3,
    gapSmall: 8,
    gapLarge: 22,
    headlineSize: 58,
    showDividers: true,
    headlineWeight: WeightRole.leicht,
    hatKante: true,
    erhebung: 0,
    nutztAkzent: false,
    categoryRole: CategoryRole.markierung,
  ),
  tagebuch(
    label: 'Tagebuch',
    radius: 18,
    gapSmall: 10,
    gapLarge: 18,
    headlineSize: 48,
    showDividers: true,
    headlineWeight: WeightRole.fett,
    hatKante: false,
    erhebung: 8,
    nutztAkzent: true,
    categoryRole: CategoryRole.markierung,
  ),
  material(
    label: 'Material',
    radius: 12,
    gapSmall: 8,
    gapLarge: 16,
    headlineSize: 42,
    showDividers: true,
    headlineWeight: WeightRole.normal,
    hatKante: false,
    erhebung: 0,
    nutztAkzent: true,
    categoryRole: CategoryRole.markierung,
  ),
  luft(
    label: 'Luft',
    radius: 18,
    gapSmall: 11,
    gapLarge: 20,
    headlineSize: 58,
    showDividers: false,
    headlineWeight: WeightRole.sehrLeicht,
    hatKante: true,
    erhebung: 0,
    nutztAkzent: true,
    categoryRole: CategoryRole.markierung,
  ),
  raster(
    label: 'Raster',
    radius: 2,
    gapSmall: 8,
    gapLarge: 22,
    headlineSize: 52,
    showDividers: true,
    headlineWeight: WeightRole.normal,
    hatKante: true,
    erhebung: 0,
    nutztAkzent: true,
    categoryRole: CategoryRole.markierung,
    readingLayout: ReadingLayout.bloecke,
  ),
  band(
    label: 'Band',
    radius: 0,
    gapSmall: 10,
    gapLarge: 18,
    headlineSize: 50,
    showDividers: false,
    headlineWeight: WeightRole.halbfett,
    hatKante: false,
    erhebung: 0,
    nutztAkzent: true,
    categoryRole: CategoryRole.flaeche,
  );

  const Characteristic({
    required this.label,
    required this.radius,
    required this.gapSmall,
    required this.gapLarge,
    required this.headlineSize,
    required this.headlineWeight,
    required this.showDividers,
    required this.hatKante,
    required this.erhebung,
    required this.nutztAkzent,
    required this.categoryRole,
    this.readingLayout = ReadingLayout.bruch,
  });

  final String label;
  final double radius;
  final double gapSmall;
  final double gapLarge;
  final double headlineSize;
  final WeightRole headlineWeight;
  final bool showDividers;
  final bool hatKante;
  final double erhebung;
  final bool nutztAkzent;
  final CategoryRole categoryRole;

  /// Wie der große Messwert gebaut ist. Standard ist der Bruch — abweichen
  /// muss eine Form begründen, nicht umgekehrt.
  final ReadingLayout readingLayout;
}
