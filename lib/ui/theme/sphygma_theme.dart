// Gestaltung als Daten, nicht als fest verdrahtete Werte. Drei Varianten
// sind umschaltbar (Spezifikation vom 2026-09-05); kein Widget greift auf
// feste Farben zu, sonst waere der Wechsel ein Umbau.
import 'package:flutter/widgets.dart';

import '../../stats/esc_classification.dart';
import 'surface_style.dart';

@immutable
class SphygmaTheme {
  const SphygmaTheme({
    required this.name,
    required this.surface,
    required this.onSurface,
    required this.muted,
    required this.line,
    required this.accent,
    required this.categoryColors,
    required this.radius,
    required this.gapSmall,
    required this.gapLarge,
    required this.headlineSize,
    required this.headlineWeight,
    required this.useRoundedCards,
    required this.showDividers,
    required this.surfaceStyle,
    required this.panelBase,
    required this.panelRaised,
    required this.panelBorder,
    required this.panelShadow,
  });

  /// Sichtbarer Name in der Auswahl.
  final String name;

  final Color surface;
  final Color onSurface;

  /// Fuer Nebensaechliches: Einheiten, Zeitangaben, Beschriftungen.
  final Color muted;

  /// Trennlinien.
  final Color line;

  /// Betonung, etwa der Zeiger auf der Skala.
  final Color accent;

  /// Farbe je Einordnung. Hier traegt Farbe Bedeutung, nirgends sonst.
  final Map<EscCategory, Color> categoryColors;

  final double radius;
  final double gapSmall;
  final double gapLarge;
  final double headlineSize;

  /// Das Gewicht der großen Zahl.
  ///
  /// Der Entwurf gibt es je Handschrift vor — 300 beim Messinstrument, 700
  /// im Tagebuch, 200 bei Aura. Bis zum 06.09.2026 stand in allen
  /// Bildschirmen fest `FontWeight.w300`: Die Handschriften unterschieden
  /// sich damit in der Größe der Zahl, nie in ihrem Gewicht.
  final FontWeight headlineWeight;
  final bool useRoundedCards;

  /// Ob Listenzeilen durch eine Haarlinie getrennt werden.
  ///
  /// „Aura" und „Pegel" gliedern nicht durch Striche, sondern durch Luft
  /// beziehungsweise durch Flächen, die ihren Ton wechseln. Das ist kein
  /// Farbunterschied, sondern ein struktureller — und ohne dieses Feld wären
  /// die beiden Handschriften nur andere Farben auf derselben Zeichnung.
  final bool showDividers;

  /// Die dritte Achse: Karte, Band oder gar keine Fläche.
  ///
  /// Sie steht hier und nicht in [ThemeVariant], weil sie frei wählbar ist —
  /// jede Handschrift lässt sich in jeder Form zeigen. Die Vorgabe liefert
  /// [defaultSurfaceFor].
  final SurfaceStyle surfaceStyle;

  /// Die Grundfläche, auf der Inhalt steht.
  final Color panelBase;

  /// Eine Tonstufe darüber — „Aura" trägt zwei, „Pegel" wechselt damit den
  /// Abschnitt.
  final Color panelRaised;

  /// Kante einer Fläche, oder null. „Aura" hat eine aus 7 % Weiß, die
  /// Kartenhandschriften kommen ohne aus.
  final Color? panelBorder;

  /// Schatten einer Fläche, oder null. Nur „Tagebuch" wirft einen.
  final List<BoxShadow>? panelShadow;

  /// Das Randpolster einer Liste.
  ///
  /// Bänder laufen bis an den Rand — dort polstert die Fläche selbst, sonst
  /// entstünde ein Streifen Grund neben dem Band, und die Zäsur durch den
  /// Tonwechsel ginge verloren.
  EdgeInsets get listPadding => surfaceStyle == SurfaceStyle.band
      ? EdgeInsets.symmetric(vertical: gapSmall)
      : EdgeInsets.all(gapLarge);

  /// Die Fläche einer Tonstufe. Zwei Stufen genügen; ein Index kann deshalb
  /// nicht danebengreifen.
  Color panel(int tone) => tone <= 0 ? panelBase : panelRaised;

  /// Der Abschluss einer Listenzeile: eine Haarlinie, oder nichts.
  ///
  /// Zentral hier, damit nicht jeder Bildschirm die Entscheidung erneut
  /// trifft — und eine neue Handschrift nicht an einer vergessenen Stelle
  /// doch wieder Striche zieht.
  BoxDecoration get rowDivider => showDividers
      ? BoxDecoration(border: Border(bottom: BorderSide(color: line)))
      : const BoxDecoration();

  /// Was ohne Trennstrich an Luft dazukommt, damit die Zeilen nicht kleben.
  ///
  /// Nimmt den Abstand entgegen, den die Zeile sonst hätte: Nicht jede Zeile
  /// misst [gapSmall] — manche stehen enger, manche weiter. Ein fester Wert
  /// hier hätte die Unterschiede zwischen den Zeilen eingeebnet, ein fester
  /// Wert dort hätte Aura und Pegel ihre Zeilen zusammenkleben lassen.
  double rowSpacing(double base) => showDividers ? base : base * 1.6;

  /// Der Regelfall: eine Zeile mit [gapSmall] Abstand.
  double get rowGap => rowSpacing(gapSmall);

  /// Wirft, wenn kein [SphygmaThemeScope] darueber liegt. Ein stiller
  /// Ersatzwert wuerde die Gestaltung unbemerkt zerfallen lassen.
  static SphygmaTheme of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SphygmaThemeScope>();
    if (scope == null) {
      throw FlutterError(
        'SphygmaTheme.of() ohne SphygmaThemeScope aufgerufen. '
        'Der Scope gehört oberhalb jedes Bildschirms in den Baum.',
      );
    }
    return scope.theme;
  }
}

class SphygmaThemeScope extends StatelessWidget {
  const SphygmaThemeScope({
    super.key,
    required this.theme,
    required this.child,
  });

  final SphygmaTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _SphygmaThemeScope(theme: theme, child: child);
}

class _SphygmaThemeScope extends InheritedWidget {
  const _SphygmaThemeScope({required this.theme, required super.child});

  final SphygmaTheme theme;

  @override
  bool updateShouldNotify(_SphygmaThemeScope old) => old.theme != theme;
}
