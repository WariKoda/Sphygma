import 'package:flutter/material.dart';

import 'sphygma_theme.dart';

/// Auch Navigator-Routen und Material-Controls tragen die drei Gestaltungsachsen.
ThemeData materialThemeFor(SphygmaTheme t) {
  final brightness = ThemeData.estimateBrightnessForColor(t.surface);
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(t.radius),
  );
  final controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(t.chipRadius),
  );
  final accentLuminance = t.accent.computeLuminance();
  final surfaceLuminance = t.panelBase.computeLuminance();
  final contrast = accentLuminance > surfaceLuminance
      ? (accentLuminance + 0.05) / (surfaceLuminance + 0.05)
      : (surfaceLuminance + 0.05) / (accentLuminance + 0.05);
  // Kleine Aktionsbeschriftungen brauchen mehr Kontrast als dekorative Akzente.
  final action = contrast >= 4.5 ? t.accent : t.onSurface;
  final onAction = action.computeLuminance() > 0.179
      ? Colors.black
      : Colors.white;
  final scheme = ColorScheme.fromSeed(
    seedColor: t.accent,
    brightness: brightness,
    primary: action,
    onPrimary: onAction,
    secondary: action,
    onSecondary: onAction,
    surface: t.panelBase,
    onSurface: t.onSurface,
    onSurfaceVariant: Color.alphaBlend(t.muted, t.panelBase),
    surfaceContainerLowest: t.surface,
    surfaceContainerLow: t.panelBase,
    surfaceContainer: t.panelBase,
    surfaceContainerHigh: t.panelRaised,
    surfaceContainerHighest: t.panelRaised,
    secondaryContainer: t.panelRaised,
    onSecondaryContainer: t.onSurface,
    outline: Color.alphaBlend(t.muted, t.panelBase),
    outlineVariant: t.line,
    surfaceTint: Colors.transparent,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: t.surface,
    useMaterial3: true,
    fontFamily: t.fontFamily,
    appBarTheme: AppBarThemeData(
      backgroundColor: t.surface,
      foregroundColor: t.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.panelBase,
      surfaceTintColor: Colors.transparent,
      shape: shape,
      titleTextStyle: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: t.onSurface,
      ),
      contentTextStyle: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: 14,
        color: t.onSurface,
        height: 1.5,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.panelBase,
      modalBackgroundColor: t.panelBase,
      surfaceTintColor: Colors.transparent,
      shape: shape,
      showDragHandle: true,
      dragHandleColor: t.muted,
    ),
    chipTheme: ChipThemeData(
      shape: controlShape,
      side: BorderSide(color: t.line),
      padding: EdgeInsets.symmetric(horizontal: t.gapSmall, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: t.panelRaised,
      contentPadding: EdgeInsets.all(t.gapSmall + 4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.chipRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.chipRadius),
        borderSide: BorderSide(color: scheme.outline),
      ),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: controlShape,
        minimumSize: const Size(48, 48),
        padding: EdgeInsets.symmetric(horizontal: t.gapLarge, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: controlShape,
        minimumSize: const Size(48, 48),
        padding: EdgeInsets.symmetric(horizontal: t.gapLarge, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: controlShape,
        minimumSize: const Size(48, 48),
      ),
    ),
    listTileTheme: ListTileThemeData(
      textColor: t.onSurface,
      iconColor: t.onSurface,
      contentPadding: EdgeInsets.symmetric(horizontal: t.gapSmall, vertical: 4),
      titleTextStyle: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: 15,
        color: t.onSurface,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: 13,
        color: scheme.onSurfaceVariant,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: t.panelBase,
      shape: shape,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: t.panelBase,
      shape: shape,
    ),
    dividerTheme: DividerThemeData(color: t.line, space: t.gapLarge),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.surface,
      indicatorColor: Color.alphaBlend(
        t.accent.withValues(alpha: 0.16),
        t.surface,
      ),
      indicatorShape: controlShape,
    ),
  );
}
