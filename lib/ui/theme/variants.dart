// Drei Handschriften für dieselbe Struktur. Der Nutzer wählt unter
// "Gerät"; die Wahl liegt in SettingsRepository.
import 'package:flutter/widgets.dart';

import '../../stats/esc_classification.dart';
import 'sphygma_theme.dart';

enum ThemeVariant { instrument, diary, material, aura, pulseGrid, pegel }

const List<ThemeVariant> allVariants = ThemeVariant.values;

/// Gruen fuer unauffaellig, Gelb fuer Grenzbereich, Rot fuer erhoeht.
/// Zurueckhaltend gewaehlt: Es geht um Einordnung, nicht um Alarm.
///
/// `optimal` und `normal` teilen absichtlich eine Farbe: Die Leitlinie
/// trennt sie, fuer den Nutzer ist beides unauffaellig. Eine eigene Farbe
/// wuerde eine Bedeutung suggerieren, die es nicht gibt.
/// Für den dunklen Grund von „Aura": gedämpfte Töne, die auf #14181F noch
/// tragen. Grün und Bernstein stammen aus dem Entwurf; der Ton für erhöhte
/// Werte ist daraus abgeleitet — der Entwurf zeigt keinen.
const Map<EscCategory, Color> _duskScale = {
  EscCategory.optimal: Color(0xFF8FB89A),
  EscCategory.normal: Color(0xFF8FB89A),
  EscCategory.highNormal: Color(0xFFE2C08A),
  EscCategory.grade1: Color(0xFFD98C7A),
  EscCategory.grade2: Color(0xFFC9705E),
  EscCategory.grade3: Color(0xFFB85B4C),
};

/// „Pegel" färbt Flächen, nicht Punkte — deshalb helle Tonflächen aus dem
/// Entwurf statt kräftiger Signalfarben.
const Map<EscCategory, Color> _bandScale = {
  EscCategory.optimal: Color(0xFFD9E5E0),
  EscCategory.normal: Color(0xFFD9E5E0),
  EscCategory.highNormal: Color(0xFFEFE1C9),
  EscCategory.grade1: Color(0xFFF3E4CB),
  EscCategory.grade2: Color(0xFFE8C9A8),
  EscCategory.grade3: Color(0xFFDCB08A),
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

SphygmaTheme themeFor(ThemeVariant variant) => switch (variant) {
      ThemeVariant.instrument => const SphygmaTheme(
          name: 'Messinstrument',
          surface: Color(0xFFFAF9F7),
          onSurface: Color(0xFF1B1B1A),
          muted: Color(0x8A1B1B1A),
          line: Color(0xFFE4E1DB),
          accent: Color(0xFF1B1B1A),
          categoryColors: _calmScale,
          radius: 3,
          gapSmall: 8,
          gapLarge: 22,
          headlineSize: 58,
          // Entwurf: 58px/300
          headlineWeight: FontWeight.w300,
          useRoundedCards: false,
          showDividers: true,
        ),
      ThemeVariant.diary => const SphygmaTheme(
          name: 'Tagebuch',
          surface: Color(0xFFF2F5FB),
          onSurface: Color(0xFF182034),
          muted: Color(0x8A182034),
          line: Color(0xFFE2E8F3),
          accent: Color(0xFF4F7FD8),
          categoryColors: _vividScale,
          radius: 18,
          gapSmall: 10,
          gapLarge: 18,
          headlineSize: 48,
          // Entwurf: 48px/700 auf der Verlaufskarte
          headlineWeight: FontWeight.w700,
          useRoundedCards: true,
          showDividers: true,
        ),
      ThemeVariant.material => const SphygmaTheme(
          name: 'Material',
          surface: Color(0xFFFEF7FF),
          onSurface: Color(0xFF1D1B20),
          muted: Color(0xFF49454F),
          line: Color(0xFFE7E0EC),
          accent: Color(0xFF6750A4),
          categoryColors: _vividScale,
          radius: 12,
          gapSmall: 8,
          gapLarge: 16,
          headlineSize: 42,
          // Entwurf: 42px/400
          headlineWeight: FontWeight.w400,
          useRoundedCards: true,
          showDividers: true,
        ),
      // Aus dem Entwurf docs/design/handschriften.html übernommen, nicht
      // erfunden: Grundfarben und Maße stehen dort im CSS je Handschrift.
      //
      // Die einzige dunkle Handschrift. Der Entwurf hält fest, dass sie fest
      // dunkel bleibt — dem Systemmodus zu folgen bräuchte eine zweite
      // Farbtafel, die die Theme-Schicht heute nicht kennt.
      ThemeVariant.aura => const SphygmaTheme(
          name: 'Aura',
          surface: Color(0xFF14181F),
          onSurface: Color(0xFFE8ECF2),
          muted: Color(0xFF94A0B0),
          // 7 % Weiß: die feine Kante, der einzige Rest von Glas.
          line: Color(0x12FFFFFF),
          accent: Color(0xFF6C5CE7),
          categoryColors: _duskScale,
          radius: 18,
          gapSmall: 11,
          gapLarge: 20,
          headlineSize: 58,
          // Entwurf: 58px/200, ExtraLight
          headlineWeight: FontWeight.w200,
          useRoundedCards: true,
          // „Zeilen ohne Trennstrich; Luft gliedert, nicht der Strich."
          showDividers: false,
        ),
      ThemeVariant.pulseGrid => const SphygmaTheme(
          name: 'Pulse Grid',
          surface: Color(0xFFF5F6F4),
          onSurface: Color(0xFF171A1C),
          muted: Color(0xFF6C7377),
          line: Color(0xFFDEE0DC),
          accent: Color(0xFF087F78),
          categoryColors: _calmScale,
          // „Radius nur an Bedienelementen, keine Schatten."
          radius: 2,
          gapSmall: 8,
          gapLarge: 22,
          headlineSize: 52,
          // Datentabelle — normal, nicht dünn
          headlineWeight: FontWeight.w400,
          useRoundedCards: false,
          showDividers: true,
        ),
      ThemeVariant.pegel => const SphygmaTheme(
          name: 'Pegel',
          surface: Color(0xFFECEEEB),
          onSurface: Color(0xFF16211F),
          muted: Color(0xFF6B7671),
          line: Color(0xFFE3E6E3),
          accent: Color(0xFF0E5C4C),
          categoryColors: _bandScale,
          // „Ganzflächige Bänder ohne Rand, Schatten, Radius oder Abstand."
          radius: 0,
          gapSmall: 10,
          gapLarge: 18,
          headlineSize: 50,
          // Bänder tragen kräftigere Ziffern
          headlineWeight: FontWeight.w500,
          useRoundedCards: false,
          // „Ein Abschnitt endet, wo die Fläche ihren Ton wechselt."
          showDividers: false,
        ),
    };
