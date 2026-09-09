import 'package:flutter/widgets.dart';

import '../../stats/esc_classification.dart';

enum Palette {
  papier(
    label: 'Papier',
    grund: Color(0xFFFAF9F7),
    onSurface: Color(0xFF1B1B1A),
    muted: Color(0x8A1B1B1A),
    line: Color(0xFFE4E1DB),
    // Schieferblau trägt Papier auch mit farbiger Form; Messinstrument
    // lehnt den Akzent unabhängig davon ab.
    accent: Color(0xFF465C78),
    flaeche: Color(0xFFFFFFFF),
    flaecheGehoben: Color(0xFFFAF9F7),
    shadow: Color(0x26465C78),
    markierung: _calmScale,
  ),
  himmel(
    label: 'Himmel',
    grund: Color(0xFFF2F5FB),
    onSurface: Color(0xFF182034),
    muted: Color(0x8A182034),
    line: Color(0xFFE2E8F3),
    accent: Color(0xFF4F7FD8),
    flaeche: Color(0xFFFFFFFF),
    flaecheGehoben: Color(0xFFF2F5FB),
    shadow: Color(0x264F7FD8),
    markierung: _vividScale,
  ),
  flieder(
    label: 'Flieder',
    grund: Color(0xFFFEF7FF),
    onSurface: Color(0xFF1D1B20),
    muted: Color(0xFF49454F),
    line: Color(0xFFE7E0EC),
    accent: Color(0xFF6750A4),
    // Der Sekundärcontainer ist farbiger, nicht bloß heller als der Grund.
    flaeche: Color(0xFFE8DEF8),
    flaecheGehoben: Color(0xFFFEF7FF),
    shadow: Color(0x266750A4),
    markierung: _vividScale,
  ),
  nacht(
    label: 'Nacht',
    grund: Color(0xFF14181F),
    onSurface: Color(0xFFE8ECF2),
    muted: Color(0xFF94A0B0),
    line: Color(0x12FFFFFF),
    accent: Color(0xFF6C5CE7),
    // Die bisherigen Weißauflagen über #14181F, hier als fertige Töne:
    // So hängt die Aufhellung nicht vom Untergrund des Widgets ab.
    flaeche: Color(0xFF1E2229),
    flaecheGehoben: Color(0xFF191D24),
    shadow: Color(0x66000000),
    markierung: _duskScale,
  );

  const Palette({
    required this.label,
    required this.grund,
    required this.onSurface,
    required this.muted,
    required this.line,
    required this.accent,
    required this.flaeche,
    required this.flaecheGehoben,
    required this.shadow,
    required this.markierung,
  });

  /// Sichtbarer Name in der Auswahl.
  final String label;

  final Color grund;
  final Color onSurface;
  final Color muted;
  final Color line;
  final Color accent;
  final Color flaeche;
  final Color flaecheGehoben;
  final Color shadow;
  final Map<EscCategory, Color> markierung;

  /// 18 % Markierung im eigenen Grund hält die Kategorienfamilie erkennbar,
  /// ohne große Flächen zum Signal zu machen. Bei Nacht wird die Fläche
  /// entsprechend dunkel und entsättigt: Eine helle Pastellfläche würde
  /// den Kontrast zum hellen Text verlieren.
  Map<EscCategory, Color> get categoryFlaeche => Map.unmodifiable({
    for (final entry in markierung.entries)
      entry.key: Color.alphaBlend(entry.value.withValues(alpha: .18), grund),
  });
}

// Optimal und normal teilen Grün: Beide sind unauffällig; eine zusätzliche
// Farbe würde eine Bedeutung suggerieren, die es für den Nutzer nicht gibt.
// Auf dunklem Grund tragen die gedämpften Töne der Nacht besser.
const Map<EscCategory, Color> _duskScale = {
  EscCategory.optimal: Color(0xFF8FB89A),
  EscCategory.normal: Color(0xFF8FB89A),
  EscCategory.highNormal: Color(0xFFE2C08A),
  EscCategory.grade1: Color(0xFFD98C7A),
  EscCategory.grade2: Color(0xFFC9705E),
  EscCategory.grade3: Color(0xFFB85B4C),
};

const Map<EscCategory, Color> _calmScale = {
  EscCategory.optimal: Color(0xFF7EA77E),
  EscCategory.normal: Color(0xFF7EA77E),
  EscCategory.highNormal: Color(0xFFC9B45E),
  EscCategory.grade1: Color(0xFFC07D5A),
  EscCategory.grade2: Color(0xFFB05F42),
  EscCategory.grade3: Color(0xFFA84C3A),
};

const Map<EscCategory, Color> _vividScale = {
  EscCategory.optimal: Color(0xFF3FA35F),
  EscCategory.normal: Color(0xFF3FA35F),
  EscCategory.highNormal: Color(0xFFE0A93B),
  EscCategory.grade1: Color(0xFFE07A3B),
  EscCategory.grade2: Color(0xFFD9553C),
  EscCategory.grade3: Color(0xFFC33A2E),
};
