// Gestaltung als Daten, nicht als fest verdrahtete Werte. Drei Varianten
// sind umschaltbar (Spezifikation vom 2026-09-05); kein Widget greift auf
// feste Farben zu, sonst waere der Wechsel ein Umbau.
import 'package:flutter/widgets.dart';

import '../../stats/esc_classification.dart';

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
    required this.useRoundedCards,
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
  final bool useRoundedCards;

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
