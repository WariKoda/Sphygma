// Drei Handschriften fuer dieselbe Struktur. Der Nutzer waehlt unter
// "Geraet"; die Wahl liegt in SettingsRepository.
import 'package:flutter/widgets.dart';

import '../../stats/esc_classification.dart';
import 'sphygma_theme.dart';

enum ThemeVariant { instrument, diary, material }

const List<ThemeVariant> allVariants = ThemeVariant.values;

/// Gruen fuer unauffaellig, Gelb fuer Grenzbereich, Rot fuer erhoeht.
/// Zurueckhaltend gewaehlt: Es geht um Einordnung, nicht um Alarm.
///
/// `optimal` und `normal` teilen absichtlich eine Farbe: Die Leitlinie
/// trennt sie, fuer den Nutzer ist beides unauffaellig. Eine eigene Farbe
/// wuerde eine Bedeutung suggerieren, die es nicht gibt.
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
          radius: 4,
          gapSmall: 8,
          gapLarge: 22,
          headlineSize: 56,
          useRoundedCards: false,
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
          useRoundedCards: true,
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
          headlineSize: 44,
          useRoundedCards: true,
        ),
    };
