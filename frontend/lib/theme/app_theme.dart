import 'package:flutter/material.dart';

/// Central, cohesive theme for the app (light + dark) built on Material 3.
class AppTheme {
  AppTheme._();

  static const _seed = Color(0xFF4F46E5); // indigo

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor:
          isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? scheme.surface : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? scheme.surfaceContainerHigh : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.7),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerHigh : Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? scheme.surface : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? scheme.surface : Colors.white,
        indicatorColor: scheme.primaryContainer,
        selectedLabelTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        unselectedLabelTextStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
    );
  }
}

/// Small helpers for consistent success/error feedback.
extension Feedback on BuildContext {
  void showSuccess(String message) => _snack(message, isError: false);
  void showError(String message) => _snack(message, isError: true);

  void _snack(String message, {required bool isError}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
        duration: Duration(seconds: isError ? 5 : 2),
      ));
  }
}
