import 'package:flutter/material.dart';

import 'mass_colors.dart';

abstract final class MassTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: MassColors.yellow,
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF745B00),
          onPrimary: Colors.white,
          primaryContainer: MassColors.yellow,
          onPrimaryContainer: const Color(0xFF241A00),
          surface: MassColors.background,
          error: MassColors.danger,
          errorContainer: MassColors.dangerContainer,
          onErrorContainer: MassColors.onDanger,
          outline: const Color(0xFF80765F),
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
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MassColors.yellow,
          foregroundColor: MassColors.ink,
          disabledBackgroundColor: MassColors.yellow.withValues(alpha: 0.45),
          disabledForegroundColor: MassColors.ink.withValues(alpha: 0.45),
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MassColors.ink,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: MassColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: MassColors.outline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MassColors.surface,
        indicatorColor: MassColors.yellow,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: MassColors.ink,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MassColors.surface,
        labelStyle: const TextStyle(
          color: MassColors.ink,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: MassColors.muted.withValues(alpha: 0.7)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MassColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MassColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MassColors.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MassColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MassColors.danger, width: 1.5),
        ),
      ),
    );
  }
}
