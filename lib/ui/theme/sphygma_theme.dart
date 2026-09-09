// Die komponierte Gestaltung bleibt ein gemeinsamer Vertrag für Widgets;
// die Herkunft ihrer Werte müssen die Bildschirme nicht kennen.
import 'package:flutter/widgets.dart';

import '../../stats/esc_classification.dart';
import 'characteristic.dart';

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
    this.fontFamily,
    this.readingLayout = ReadingLayout.bruch,
    required this.showDividers,
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

  /// Null erhält die Systemschrift, ohne eine Familie einzubetten.
  final String? fontFamily;

  /// Wie der große Messwert gebaut ist — Bruch oder zwei Blöcke.
  ///
  /// Ein **Aufbau**-Merkmal, kein Maß: Es steht hier, damit `ReadingHeadline`
  /// es kennt und kein Bildschirm nach der Form verzweigen muss.
  final ReadingLayout readingLayout;

  /// Ob Listenzeilen durch eine Haarlinie getrennt werden.
  ///
  /// „Aura" und „Pegel" gliedern nicht durch Striche, sondern durch Luft
  /// beziehungsweise durch Flächen, die ihren Ton wechseln. Das ist kein
  /// Farbunterschied, sondern ein struktureller — und ohne dieses Feld wären
  /// die beiden Handschriften nur andere Farben auf derselben Zeichnung.
  final bool showDividers;

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

  /// Das Randpolster einer Liste — außen um die Flächen herum.
  EdgeInsets get listPadding => EdgeInsets.all(gapLarge);

  /// Der Radius kleiner Elemente: Rasterzellen, Chips, Marken.
  ///
  /// Eigenes Maß statt `radius / 2` im Bildschirm: Eine Zelle von 34 Pixeln
  /// verträgt nicht denselben Radius wie eine Karte, und die Rechnung dafür
  /// gehört in die Gestaltung. Sonst rechnet jeder Bildschirm anders, und
  /// eine Handschrift sieht an einer Stelle richtig aus und an der nächsten
  /// nicht.
  double get chipRadius => radius / 2;

  /// Das Polster **innerhalb** einer Fläche.
  ///
  /// Eigenes Maß statt einer Rechnung an jeder Fläche: Sonst polstert eine
  /// Karte anders als die daneben, sobald jemand die Rechnung an einer Stelle
  /// anpasst.
  double get panelPadding => gapLarge * 0.7;

  /// Die Fläche einer Tonstufe. Zwei Stufen genügen; ein Index kann deshalb
  /// nicht danebengreifen.
  Color panel(int tone) => tone <= 0 ? panelBase : panelRaised;

  /// Der Abschluss einer Listenzeile: eine Haarlinie, oder nichts.
  ///
  /// Zentral hier, damit nicht jeder Bildschirm die Entscheidung erneut
  /// trifft — und eine neue Handschrift nicht an einer vergessenen Stelle
  /// doch wieder Striche zieht.
  BoxDecoration get rowDivider => showDividers
      ? BoxDecoration(
          border: Border(bottom: BorderSide(color: line)),
        )
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
    final scope = context
        .dependOnInheritedWidgetOfExactType<_SphygmaThemeScope>();
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
