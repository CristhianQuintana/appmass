import 'package:flutter/material.dart';

import 'mass_colors.dart';

abstract final class MassTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: MassColors.yellow,
          brightness: Brightness.light,
        ).copyWith(
          primary: MassColors.ink,
          onPrimary: Colors.white,
          primaryContainer: MassColors.yellow,
          onPrimaryContainer: MassColors.ink,
          secondary: MassColors.yellowDim,
          onSecondary: MassColors.ink,
          surface: MassColors.background,
          onSurface: MassColors.ink,
          error: MassColors.danger,
          errorContainer: MassColors.dangerContainer,
          onErrorContainer: MassColors.onDanger,
          outline: MassColors.outline,
          outlineVariant: MassColors.outline,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: MassColors.background,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: MassColors.surface,
        foregroundColor: MassColors.ink,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MassColors.yellow,
          foregroundColor: MassColors.ink,
          disabledBackgroundColor: MassColors.yellow.withValues(alpha: 0.45),
          disabledForegroundColor: MassColors.ink.withValues(alpha: 0.45),
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MassColors.inkSoft,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: MassColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: MassColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: MassColors.outline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MassColors.surface,
        indicatorColor: MassColors.yellowSoft,
        height: 70,
        elevation: 8,
        shadowColor: MassColors.shadow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: MassColors.ink,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? MassColors.ink : MassColors.muted,
            size: 24,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: MassColors.surfaceLow,
        selectedColor: MassColors.yellowSoft,
        side: const BorderSide(color: MassColors.outline),
        labelStyle: const TextStyle(
          color: MassColors.ink,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MassColors.ink,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MassColors.surface,
        labelStyle: const TextStyle(
          color: MassColors.ink,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: MassColors.muted.withValues(alpha: 0.75)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MassColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MassColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MassColors.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MassColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MassColors.danger, width: 1.5),
        ),
      ),
    );
  }
}
