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
    flaecheGehoben: Color(0xFFF3F1EC),
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
    flaecheGehoben: Color(0xFFE9EEF8),
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
    flaecheGehoben: Color(0xFFF6EDFA),
    shadow: Color(0x266750A4),
    markierung: _vividScale,
  ),

  /// Nach Masataka Okabe und Kei Ito, „Color Universal Design".
  ///
  /// Die acht Farben sind so gewählt, dass sie auch bei den häufigen Formen
  /// der Farbenblindheit unterscheidbar bleiben — Rot ist Zinnober, weil
  /// Protanope es noch erkennen; Töne zwischen Gelb und Grün sind gemieden.
  /// Für ein Blutdrucktagebuch ist das kein Zierrat: Die Tonleiter der
  /// Einordnung **trägt Bedeutung**, und wer sie nicht unterscheiden kann,
  /// verliert eine Aussage.
  ///
  /// Werte aus dem R-Quelltext (`grDevices/colorstuff.R`, Tabelle
  /// „Okabe-Ito"), der sie seinerseits auf die Veröffentlichung von Okabe und
  /// Ito zurückführt.
  okabeItoHell(
    label: 'Okabe-Ito hell',
    grund: Color(0xFFFAFAFA),
    // Reines Schwarz aus der Palette — der stärkste Kontrast, den es gibt.
    onSurface: Color(0xFF000000),
    muted: Color(0xFF6B6B6B),
    line: Color(0xFFDCDCDC),
    // Blau statt Zinnober als Akzent: Zinnober trägt in der Tonleiter
    // Bedeutung und wäre als Schmuckfarbe daneben missverständlich.
    accent: Color(0xFF0072B2),
    flaeche: Color(0xFFFFFFFF),
    flaecheGehoben: Color(0xFFF0F0F0),
    shadow: Color(0x1A000000),
    markierung: _okabeItoScale,
  ),
  okabeItoDunkel(
    label: 'Okabe-Ito dunkel',
    grund: Color(0xFF0E0E0E),
    onSurface: Color(0xFFFAFAFA),
    // Das Grau der Palette, aufgehellt: Auf schwarzem Grund trägt #999999
    // als Nebentext gerade noch, darunter wird es unlesbar.
    muted: Color(0xFFA8A8A8),
    line: Color(0xFF2E2E2E),
    // Himmelblau statt Blau: Auf dunklem Grund ist #0072B2 zu dunkel.
    accent: Color(0xFF56B4E9),
    flaeche: Color(0xFF1C1C1C),
    flaecheGehoben: Color(0xFF262626),
    shadow: Color(0x66000000),
    markierung: _okabeItoScale,
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
/// Die Einordnung in den Farben von Okabe und Ito.
///
/// Grün, Gelb, Orange, Zinnober, Purpurrot — eine Folge, die auch ohne
/// Rot-Grün-Unterscheidung als Reihe lesbar bleibt. Purpurrot steht am
/// oberen Ende, weil die Palette kein dunkleres Rot führt und ein
/// erfundener Ton die Barrierefreiheit gerade aufheben würde.
const Map<EscCategory, Color> _okabeItoScale = {
  EscCategory.optimal: Color(0xFF009E73),
  EscCategory.normal: Color(0xFF009E73),
  EscCategory.highNormal: Color(0xFFF0E442),
  EscCategory.grade1: Color(0xFFE69F00),
  EscCategory.grade2: Color(0xFFD55E00),
  EscCategory.grade3: Color(0xFFCC79A7),
};

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
