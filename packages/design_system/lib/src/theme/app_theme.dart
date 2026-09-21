// packages/design_system/lib/src/theme/app_theme.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/app_tokens.g.dart';
import '../typography/app_text_styles.dart';

/// Factory for Splitbo light and dark ThemeData.
///
/// Both themes use Material 3 with a tightly-controlled colour scheme derived
/// from our semantic tokens — nothing is left to Flutter's auto-generation.
abstract final class AppTheme {
  static ThemeData light() => _build(
        colors: SplitboColors.light,
        brightness: Brightness.light,
        systemOverlay: SystemUiOverlayStyle.dark,
      );

  static ThemeData dark() => _build(
        colors: SplitboColors.dark,
        brightness: Brightness.dark,
        systemOverlay: SystemUiOverlayStyle.light,
      );

  static ThemeData _build({
    required SplitboColors colors,
    required Brightness brightness,
    required SystemUiOverlayStyle systemOverlay,
  }) {
    final cs = ColorScheme(
      brightness: brightness,
      primary: colors.brandPrimary,
      onPrimary: colors.textOnPrimary,
      primaryContainer: colors.brandPrimaryLt,
      onPrimaryContainer: colors.textPrimary,
      secondary: colors.brandPrimary,
      onSecondary: colors.textOnPrimary,
      secondaryContainer: colors.brandPrimaryLt,
      onSecondaryContainer: colors.textPrimary,
      error: colors.semanticError,
      onError: colors.textInverse,
      surface: colors.surfaceDefault,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.borderDefault,
      outlineVariant: colors.borderDefault,
      scrim: Colors.black54,
      inverseSurface: brightness == Brightness.dark
          ? const Color(0xFFE0E0E0)
          : const Color(0xFF1E1E1E),
      onInverseSurface: brightness == Brightness.dark
          ? const Color(0xFF000000)
          : const Color(0xFFFFFFFF),
    );

    final spacing = SplitboSpacing.defaults;
    final radii = SplitboRadius.defaults;
    final motion = SplitboMotion.defaults;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: colors.backgroundDefault,
      extensions: [colors, spacing, radii, motion],

      // ── Typography ──────────────────────────────────────────
      fontFamily: GoogleFonts.sora().fontFamily,
      textTheme: GoogleFonts.soraTextTheme(_buildTextTheme(colors)),

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: colors.backgroundDefault,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: colors.borderDefault,
        systemOverlayStyle: systemOverlay,
        titleTextStyle: AppTextStyles.h2.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),

      // ── Card ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: colors.surfaceRaised,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.card),
          side: BorderSide(color: colors.borderDefault),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Bottom Navigation ───────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.backgroundDefault,
        selectedItemColor: colors.brandPrimary,
        unselectedItemColor: colors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── NavigationBar (Material 3) ──────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.backgroundDefault,
        indicatorColor: colors.brandPrimaryLt,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.brandPrimary);
          }
          return IconThemeData(color: colors.textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.label.copyWith(
              color: colors.brandPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTextStyles.label.copyWith(color: colors.textSecondary);
        }),
        elevation: 0,
      ),

      // ── Dialog ──────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceOverlay,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.modal),
        ),
        titleTextStyle: AppTextStyles.h2.copyWith(color: colors.textPrimary),
        contentTextStyle: AppTextStyles.bodyM.copyWith(color: colors.textSecondary),
      ),

      // ── Bottom Sheet ─────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceDefault,
        modalBackgroundColor: colors.surfaceDefault,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radii.card),
          ),
        ),
        elevation: 0,
        dragHandleColor: colors.borderDefault,
      ),

      // ── Input / TextField ───────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceRaised,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.insetMd,
          vertical: spacing.insetSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.control),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.control),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.control),
          borderSide: BorderSide(color: colors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.control),
          borderSide: BorderSide(color: colors.borderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.control),
          borderSide: BorderSide(color: colors.borderError, width: 2),
        ),
        hintStyle: AppTextStyles.bodyM.copyWith(color: colors.textSecondary),
        labelStyle: AppTextStyles.label.copyWith(color: colors.textSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: colors.semanticError),
      ),

      // ── Divider ─────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colors.borderDefault,
        thickness: 1,
        space: 1,
      ),

      // ── Icon ────────────────────────────────────────────────
      iconTheme: IconThemeData(color: colors.textSecondary),

      // ── Switch ──────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.textOnPrimary;
          return colors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.brandPrimary;
          return colors.borderDefault;
        }),
      ),

      // ── Chip ────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceRaised,
        selectedColor: colors.brandPrimaryLt,
        labelStyle: AppTextStyles.label.copyWith(color: colors.textPrimary),
        side: BorderSide(color: colors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.pill),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.inlineLg,
          vertical: spacing.inlineXs,
        ),
      ),

      // ── Snack Bar ───────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: AppTextStyles.bodyM.copyWith(color: colors.textInverse),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.control),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Page transitions ─────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _buildTextTheme(SplitboColors colors) {
    return TextTheme(
      displayLarge:   AppTextStyles.displayXl.copyWith(color: colors.textPrimary),
      displayMedium:  AppTextStyles.displayL.copyWith(color: colors.textPrimary),
      headlineLarge:  AppTextStyles.h1.copyWith(color: colors.textPrimary),
      headlineMedium: AppTextStyles.h2.copyWith(color: colors.textPrimary),
      headlineSmall:  AppTextStyles.h3.copyWith(color: colors.textPrimary),
      bodyLarge:      AppTextStyles.bodyL.copyWith(color: colors.textPrimary),
      bodyMedium:     AppTextStyles.bodyM.copyWith(color: colors.textPrimary),
      bodySmall:      AppTextStyles.caption.copyWith(color: colors.textSecondary),
      labelLarge:     AppTextStyles.button.copyWith(color: colors.textPrimary),
      labelMedium:    AppTextStyles.label.copyWith(color: colors.textPrimary),
      labelSmall:     AppTextStyles.caption.copyWith(color: colors.textSecondary),
    );
  }
}
