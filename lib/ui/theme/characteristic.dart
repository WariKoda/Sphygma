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
}
