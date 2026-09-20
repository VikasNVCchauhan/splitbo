// packages/design_system/lib/src/typography/app_text_styles.dart
//
// All type styles reference semantic tokens via BuildContext, except
// the static constants used inside ThemeData construction (which happen
// before a context exists).

import 'package:flutter/material.dart';

/// Font family constants — mirrors pubspec.yaml font declarations.
abstract final class AppFonts {
  static const sora  = 'Sora';
  static const inter = 'Inter';
}

/// Static text styles for use inside ThemeData (pre-context).
/// UI code should use [AppTextStylesX] extension on BuildContext instead.
abstract final class AppTextStyles {
  // ── Display ────────────────────────────────────────────────
  static const displayXl = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -1.0,
  );

  static const displayL = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // ── Headings ───────────────────────────────────────────────
  static const h1 = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const h2 = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static const h3 = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ── Body ───────────────────────────────────────────────────
  static const bodyL = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyM = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── UI ─────────────────────────────────────────────────────
  static const label = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const caption = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // ── Button ─────────────────────────────────────────────────
  static const button = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.1,
  );

  // ── Amount / numeral (monospaced feel) ─────────────────────
  static const amountL = TextStyle(
    fontFamily: AppFonts.sora,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const amountM = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const amountS = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
