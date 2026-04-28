import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOR TOKENS - Edit these to retheme the entire app.
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppColors {
  // Backgrounds
  static const LinearGradient scaffoldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 244, 239, 230), // #F4EFE6 linen
      Color.fromARGB(255, 232, 224, 210), // slightly deeper linen
    ],
  );
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF0EAE0);
  static const Color inputFill = Color(0xFFF7F3ED);

  // Primary
  static Color primary = Color.fromARGB(255, 46, 125, 107); // muted teal
  static Color primaryDim = Color.fromARGB(255, 28, 75, 64); // darkened teal

  static Color secondary = Color.fromARGB(255, 192, 122, 47); // warm copper
  static Color secondaryDim = Color.fromARGB(
    255,
    115,
    73,
    28,
  ); // darkened copper

  // Status
  static const Color error = Color.fromARGB(255, 211, 54, 54);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF3D3D3D);
  static const Color textMuted = Color(0xFF7A7A7A);
  static const Color textDisabled = Color(0xFFB0B0B0);

  // Borders and Divider
  static const Color border = Color(0xFFD8CFBF);
  static const Color divider = Color.fromARGB(255, 212, 205, 193);
}

// ─────────────────────────────────────────────────────────────────────────────
// TEXT STYLES
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppTextStyles {
  static TextStyle get font10 =>
      TextStyle(fontFamily: 'UbuntuCondensed', fontSize: Layout.size10);
  static TextStyle get font12 =>
      TextStyle(fontFamily: 'UbuntuCondensed', fontSize: Layout.size12);
  static TextStyle get font14 =>
      TextStyle(fontFamily: 'UbuntuCondensed', fontSize: Layout.size14);
  static TextStyle get font16 =>
      TextStyle(fontFamily: 'UbuntuCondensed', fontSize: Layout.size16);
  static TextStyle get font18 =>
      TextStyle(fontFamily: 'UbuntuCondensed', fontSize: Layout.size18);
  static TextStyle get font20 =>
      TextStyle(fontFamily: 'UbuntuCondensed', fontSize: Layout.size20);
  static TextStyle get font22 =>
      TextStyle(fontFamily: 'UbuntuCondensed', fontSize: Layout.size22);
}

// ─────────────────────────────────────────────────────────────────────────────
// BUTTON STYLES
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppButtonStyles {
  // Major CTAs / Primary Buttons
  static ButtonStyle get primaryFilled => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.font18.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        padding: EdgeInsets.symmetric(vertical: Layout.v(12)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Layout.v(8))),
        ),
        elevation: 10,
      );

  /// Ghost / Text Button
  static ButtonStyle get ghostPrimary => TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.surfaceElevated,
        textStyle: AppTextStyles.font18.copyWith(fontWeight: FontWeight.w600),
        padding: Layout.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Layout.v(8))),
        ),
      );

  // Outlined Primary
  static ButtonStyle get primaryOutlined => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: AppTextStyles.font18.copyWith(fontWeight: FontWeight.w600),
        padding: EdgeInsets.symmetric(
          vertical: Layout.v(8),
          horizontal: Layout.v(16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Layout.v(8))),
        ),
      );

  /// Outlined Grey
  static ButtonStyle get outlinedGrey => OutlinedButton.styleFrom(
        foregroundColor: AppColors.textMuted,
        side: const BorderSide(color: AppColors.border),
        textStyle: AppTextStyles.font18.copyWith(fontWeight: FontWeight.w600),
        padding: EdgeInsets.symmetric(vertical: Layout.v(10), horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Layout.v(8))),
        ),
      );

  /// Outlined Destructive - 'Cancel', 'Error' etc..
  static ButtonStyle get outlinedDestructive => OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error, width: 1.5),
        textStyle: AppTextStyles.font18.copyWith(fontWeight: FontWeight.w600),
        padding: EdgeInsets.symmetric(vertical: Layout.v(12)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Layout.v(8))),
        ),
      );

  /// Modal Save (Bottom Sheets)
  static ButtonStyle get modalSave => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.font16.copyWith(fontWeight: FontWeight.w600),
        padding: Layout.symmetric(vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        elevation: 0,
      );

  /// Modal Cancel (Bottom Sheets)
  static ButtonStyle get modalCancel => OutlinedButton.styleFrom(
        foregroundColor: AppColors.textMuted,
        side: const BorderSide(color: AppColors.border),
        textStyle: AppTextStyles.font16.copyWith(fontWeight: FontWeight.w600),
        padding: Layout.symmetric(vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME DATA
// ─────────────────────────────────────────────────────────────────────────────

ThemeData buildAppTheme() => ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        primaryContainer: AppColors.primaryDim,
        onPrimaryContainer: Colors.white,
      ),

      // ── AppBar ────────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        toolbarHeight: Layout.v(60),
        titleTextStyle: AppTextStyles.font22.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme:
            IconThemeData(color: AppColors.textPrimary, size: Layout.v(22)),
      ),

      // ── Buttons ───────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.primaryFilled,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlinedGrey,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.font18.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ── Input fields ──────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        hintStyle: const TextStyle(color: AppColors.textDisabled),
        contentPadding: Layout.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      // ── Cards ─────────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // ── Dialogs ───────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        titleTextStyle: AppTextStyles.font22.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppTextStyles.font16.copyWith(
          color: AppColors.textSecondary,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // ── Floating Action Button ───────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // ── Divider ───────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Switch ────────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
    );
