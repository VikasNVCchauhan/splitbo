// GENERATED FILE — DO NOT EDIT MANUALLY.
// Regenerate with: dart tools/tokens/generate_theme.dart  (or: melos tokens)
// Source: tools/tokens/tokens.json

// ignore_for_file: lines_longer_than_80_chars

import 'dart:ui' show lerpDouble;
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';

/// Raw brand palette — do NOT use in UI code. Use [SplitboColors] instead.
abstract final class _Palette {
  static const Color green50   = Color(0xFFF5FFD4);
  static const Color green100  = Color(0xFFEAFFAA);
  static const Color green200  = Color(0xFFDAFF70);
  static const Color green300  = Color(0xFFCBFF2A);
  static const Color green400  = Color(0xFFC7FE06);
  static const Color green500  = Color(0xFFC3FD00); // brand primary #C3FD00
  static const Color green600  = Color(0xFF9BCB00); // pressed/hover
  static const Color green700  = Color(0xFF739800);
  static const Color green800  = Color(0xFF4C6600);
  static const Color green900  = Color(0xFF263300);

  static const Color neutral0    = Color(0xFFFFFFFF);
  static const Color neutral50   = Color(0xFFF5F5F5);
  static const Color neutral100  = Color(0xFFE0E0E0);
  static const Color neutral200  = Color(0xFFBDBDBD);
  static const Color neutral300  = Color(0xFF9E9E9E);
  static const Color neutral400  = Color(0xFF757575);
  static const Color neutral500  = Color(0xFF666666);
  static const Color neutral600  = Color(0xFF424242);
  static const Color neutral700  = Color(0xFF2A2A2A);
  static const Color neutral800  = Color(0xFF1E1E1E);
  static const Color neutral850  = Color(0xFF1A1A1A);
  static const Color neutral900  = Color(0xFF141414);
  static const Color neutral950  = Color(0xFF0D0D0D);
  static const Color neutral1000 = Color(0xFF000000);

  static const Color positive50  = Color(0xFFD1FAE5);
  static const Color positive500 = Color(0xFF22C55E);
  static const Color negative50  = Color(0xFFFFEDD5);
  static const Color negative500 = Color(0xFFF97316);
  static const Color warning50   = Color(0xFFFEF3C7);
  static const Color warning500  = Color(0xFFF59E0B);
  static const Color error50     = Color(0xFFFEE2E2);
  static const Color error500    = Color(0xFFDC2626);
}

/// Semantic colour tokens — the ONLY colour API for UI code.
/// Obtain via: `context.colors` (see [SplitboTokensX]).
@immutable
class SplitboColors extends ThemeExtension<SplitboColors> {
  const SplitboColors({
    required this.backgroundDefault,
    required this.backgroundSubtle,
    required this.backgroundEmphasis,
    required this.surfaceDefault,
    required this.surfaceRaised,
    required this.surfaceOverlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.textInverse,
    required this.borderDefault,
    required this.borderFocus,
    required this.borderError,
    required this.brandPrimary,
    required this.brandPrimaryDk,
    required this.brandPrimaryLt,
    required this.semanticPositive,
    required this.semanticPositiveBg,
    required this.semanticNegative,
    required this.semanticNegativeBg,
    required this.semanticWarning,
    required this.semanticWarningBg,
    required this.semanticError,
    required this.semanticErrorBg,
  });

  final Color backgroundDefault;
  final Color backgroundSubtle;
  final Color backgroundEmphasis;
  final Color surfaceDefault;
  final Color surfaceRaised;
  final Color surfaceOverlay;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color textOnPrimary;
  final Color textInverse;
  final Color borderDefault;
  final Color borderFocus;
  final Color borderError;
  final Color brandPrimary;
  final Color brandPrimaryDk;
  final Color brandPrimaryLt;
  final Color semanticPositive;
  final Color semanticPositiveBg;
  final Color semanticNegative;
  final Color semanticNegativeBg;
  final Color semanticWarning;
  final Color semanticWarningBg;
  final Color semanticError;
  final Color semanticErrorBg;

  static const light = SplitboColors(
    backgroundDefault:   _Palette.neutral0,
    backgroundSubtle:    _Palette.neutral50,
    backgroundEmphasis:  _Palette.green500,
    surfaceDefault:      _Palette.neutral0,
    surfaceRaised:       _Palette.neutral50,
    surfaceOverlay:      _Palette.neutral0,
    textPrimary:         _Palette.neutral950,
    textSecondary:       _Palette.neutral500,
    textDisabled:        _Palette.neutral300,
    textOnPrimary:       _Palette.neutral1000,
    textInverse:         _Palette.neutral0,
    borderDefault:       _Palette.neutral100,
    borderFocus:         _Palette.green500,
    borderError:         _Palette.error500,
    brandPrimary:        _Palette.green500,
    brandPrimaryDk:      _Palette.green600,
    brandPrimaryLt:      _Palette.green100,
    semanticPositive:    _Palette.positive500,
    semanticPositiveBg:  _Palette.positive50,
    semanticNegative:    _Palette.negative500,
    semanticNegativeBg:  _Palette.negative50,
    semanticWarning:     _Palette.warning500,
    semanticWarningBg:   _Palette.warning50,
    semanticError:       _Palette.error500,
    semanticErrorBg:     _Palette.error50,
  );

  static const dark = SplitboColors(
    backgroundDefault:   _Palette.neutral1000,
    backgroundSubtle:    _Palette.neutral900,
    backgroundEmphasis:  _Palette.green500,
    surfaceDefault:      _Palette.neutral900,
    surfaceRaised:       _Palette.neutral850,
    surfaceOverlay:      _Palette.neutral800,
    textPrimary:         _Palette.neutral0,
    textSecondary:       _Palette.neutral300,
    textDisabled:        _Palette.neutral600,
    textOnPrimary:       _Palette.neutral1000,
    textInverse:         _Palette.neutral950,
    borderDefault:       _Palette.neutral700,
    borderFocus:         _Palette.green500,
    borderError:         _Palette.error500,
    brandPrimary:        _Palette.green500,
    brandPrimaryDk:      _Palette.green600,
    brandPrimaryLt:      _Palette.green900,
    semanticPositive:    _Palette.positive500,
    semanticPositiveBg:  _Palette.positive50,
    semanticNegative:    _Palette.negative500,
    semanticNegativeBg:  _Palette.negative50,
    semanticWarning:     _Palette.warning500,
    semanticWarningBg:   _Palette.warning50,
    semanticError:       _Palette.error500,
    semanticErrorBg:     _Palette.error50,
  );

  @override
  SplitboColors copyWith({
    Color? backgroundDefault, Color? backgroundSubtle, Color? backgroundEmphasis,
    Color? surfaceDefault, Color? surfaceRaised, Color? surfaceOverlay,
    Color? textPrimary, Color? textSecondary, Color? textDisabled,
    Color? textOnPrimary, Color? textInverse,
    Color? borderDefault, Color? borderFocus, Color? borderError,
    Color? brandPrimary, Color? brandPrimaryDk, Color? brandPrimaryLt,
    Color? semanticPositive, Color? semanticPositiveBg,
    Color? semanticNegative, Color? semanticNegativeBg,
    Color? semanticWarning, Color? semanticWarningBg,
    Color? semanticError, Color? semanticErrorBg,
  }) => SplitboColors(
    backgroundDefault:   backgroundDefault   ?? this.backgroundDefault,
    backgroundSubtle:    backgroundSubtle    ?? this.backgroundSubtle,
    backgroundEmphasis:  backgroundEmphasis  ?? this.backgroundEmphasis,
    surfaceDefault:      surfaceDefault      ?? this.surfaceDefault,
    surfaceRaised:       surfaceRaised       ?? this.surfaceRaised,
    surfaceOverlay:      surfaceOverlay      ?? this.surfaceOverlay,
    textPrimary:         textPrimary         ?? this.textPrimary,
    textSecondary:       textSecondary       ?? this.textSecondary,
    textDisabled:        textDisabled        ?? this.textDisabled,
    textOnPrimary:       textOnPrimary       ?? this.textOnPrimary,
    textInverse:         textInverse         ?? this.textInverse,
    borderDefault:       borderDefault       ?? this.borderDefault,
    borderFocus:         borderFocus         ?? this.borderFocus,
    borderError:         borderError         ?? this.borderError,
    brandPrimary:        brandPrimary        ?? this.brandPrimary,
    brandPrimaryDk:      brandPrimaryDk      ?? this.brandPrimaryDk,
    brandPrimaryLt:      brandPrimaryLt      ?? this.brandPrimaryLt,
    semanticPositive:    semanticPositive    ?? this.semanticPositive,
    semanticPositiveBg:  semanticPositiveBg  ?? this.semanticPositiveBg,
    semanticNegative:    semanticNegative    ?? this.semanticNegative,
    semanticNegativeBg:  semanticNegativeBg  ?? this.semanticNegativeBg,
    semanticWarning:     semanticWarning     ?? this.semanticWarning,
    semanticWarningBg:   semanticWarningBg   ?? this.semanticWarningBg,
    semanticError:       semanticError       ?? this.semanticError,
    semanticErrorBg:     semanticErrorBg     ?? this.semanticErrorBg,
  );

  @override
  SplitboColors lerp(SplitboColors? other, double t) {
    if (other == null) return this;
    return SplitboColors(
      backgroundDefault:   Color.lerp(backgroundDefault,   other.backgroundDefault,   t)!,
      backgroundSubtle:    Color.lerp(backgroundSubtle,    other.backgroundSubtle,    t)!,
      backgroundEmphasis:  Color.lerp(backgroundEmphasis,  other.backgroundEmphasis,  t)!,
      surfaceDefault:      Color.lerp(surfaceDefault,      other.surfaceDefault,      t)!,
      surfaceRaised:       Color.lerp(surfaceRaised,       other.surfaceRaised,       t)!,
      surfaceOverlay:      Color.lerp(surfaceOverlay,      other.surfaceOverlay,      t)!,
      textPrimary:         Color.lerp(textPrimary,         other.textPrimary,         t)!,
      textSecondary:       Color.lerp(textSecondary,       other.textSecondary,       t)!,
      textDisabled:        Color.lerp(textDisabled,        other.textDisabled,        t)!,
      textOnPrimary:       Color.lerp(textOnPrimary,       other.textOnPrimary,       t)!,
      textInverse:         Color.lerp(textInverse,         other.textInverse,         t)!,
      borderDefault:       Color.lerp(borderDefault,       other.borderDefault,       t)!,
      borderFocus:         Color.lerp(borderFocus,         other.borderFocus,         t)!,
      borderError:         Color.lerp(borderError,         other.borderError,         t)!,
      brandPrimary:        Color.lerp(brandPrimary,        other.brandPrimary,        t)!,
      brandPrimaryDk:      Color.lerp(brandPrimaryDk,      other.brandPrimaryDk,      t)!,
      brandPrimaryLt:      Color.lerp(brandPrimaryLt,      other.brandPrimaryLt,      t)!,
      semanticPositive:    Color.lerp(semanticPositive,    other.semanticPositive,    t)!,
      semanticPositiveBg:  Color.lerp(semanticPositiveBg,  other.semanticPositiveBg,  t)!,
      semanticNegative:    Color.lerp(semanticNegative,    other.semanticNegative,    t)!,
      semanticNegativeBg:  Color.lerp(semanticNegativeBg,  other.semanticNegativeBg,  t)!,
      semanticWarning:     Color.lerp(semanticWarning,     other.semanticWarning,     t)!,
      semanticWarningBg:   Color.lerp(semanticWarningBg,   other.semanticWarningBg,   t)!,
      semanticError:       Color.lerp(semanticError,       other.semanticError,       t)!,
      semanticErrorBg:     Color.lerp(semanticErrorBg,     other.semanticErrorBg,     t)!,
    );
  }
}

/// Semantic spacing tokens.
/// Obtain via: `context.spacing`
@immutable
class SplitboSpacing extends ThemeExtension<SplitboSpacing> {
  const SplitboSpacing({
    required this.insetXs,
    required this.insetSm,
    required this.insetMd,
    required this.insetLg,
    required this.insetXl,
    required this.stackXs,
    required this.stackSm,
    required this.stackMd,
    required this.stackLg,
    required this.stackXl,
    required this.inlineXs,
    required this.inlineSm,
    required this.inlineMd,
    required this.inlineLg,
    required this.inlineXl,
    required this.minTouchTarget,
  });

  final double insetXs;          // 8
  final double insetSm;          // 12
  final double insetMd;          // 16
  final double insetLg;          // 24
  final double insetXl;          // 32
  final double stackXs;          // 4
  final double stackSm;          // 8
  final double stackMd;          // 16
  final double stackLg;          // 24
  final double stackXl;          // 40
  final double inlineXs;         // 4
  final double inlineSm;         // 8
  final double inlineMd;         // 12
  final double inlineLg;         // 16
  final double inlineXl;         // 24
  /// WCAG 2.2 AA minimum interactive target size (dp).
  final double minTouchTarget;   // 44

  static const defaults = SplitboSpacing(
    insetXs: 8.0,  insetSm: 12.0, insetMd: 16.0, insetLg: 24.0, insetXl: 32.0,
    stackXs: 4.0,  stackSm: 8.0,  stackMd: 16.0, stackLg: 24.0, stackXl: 40.0,
    inlineXs: 4.0, inlineSm: 8.0, inlineMd: 12.0, inlineLg: 16.0, inlineXl: 24.0,
    minTouchTarget: 44.0,
  );

  @override
  SplitboSpacing copyWith({
    double? insetXs, double? insetSm, double? insetMd, double? insetLg, double? insetXl,
    double? stackXs, double? stackSm, double? stackMd, double? stackLg, double? stackXl,
    double? inlineXs, double? inlineSm, double? inlineMd, double? inlineLg, double? inlineXl,
    double? minTouchTarget,
  }) => SplitboSpacing(
    insetXs: insetXs ?? this.insetXs, insetSm: insetSm ?? this.insetSm,
    insetMd: insetMd ?? this.insetMd, insetLg: insetLg ?? this.insetLg,
    insetXl: insetXl ?? this.insetXl, stackXs: stackXs ?? this.stackXs,
    stackSm: stackSm ?? this.stackSm, stackMd: stackMd ?? this.stackMd,
    stackLg: stackLg ?? this.stackLg, stackXl: stackXl ?? this.stackXl,
    inlineXs: inlineXs ?? this.inlineXs, inlineSm: inlineSm ?? this.inlineSm,
    inlineMd: inlineMd ?? this.inlineMd, inlineLg: inlineLg ?? this.inlineLg,
    inlineXl: inlineXl ?? this.inlineXl,
    minTouchTarget: minTouchTarget ?? this.minTouchTarget,
  );

  @override
  SplitboSpacing lerp(SplitboSpacing? other, double t) {
    if (other == null) return this;
    return SplitboSpacing(
      insetXs: lerpDouble(insetXs, other.insetXs, t)!,
      insetSm: lerpDouble(insetSm, other.insetSm, t)!,
      insetMd: lerpDouble(insetMd, other.insetMd, t)!,
      insetLg: lerpDouble(insetLg, other.insetLg, t)!,
      insetXl: lerpDouble(insetXl, other.insetXl, t)!,
      stackXs: lerpDouble(stackXs, other.stackXs, t)!,
      stackSm: lerpDouble(stackSm, other.stackSm, t)!,
      stackMd: lerpDouble(stackMd, other.stackMd, t)!,
      stackLg: lerpDouble(stackLg, other.stackLg, t)!,
      stackXl: lerpDouble(stackXl, other.stackXl, t)!,
      inlineXs: lerpDouble(inlineXs, other.inlineXs, t)!,
      inlineSm: lerpDouble(inlineSm, other.inlineSm, t)!,
      inlineMd: lerpDouble(inlineMd, other.inlineMd, t)!,
      inlineLg: lerpDouble(inlineLg, other.inlineLg, t)!,
      inlineXl: lerpDouble(inlineXl, other.inlineXl, t)!,
      minTouchTarget: lerpDouble(minTouchTarget, other.minTouchTarget, t)!,
    );
  }
}

/// Semantic border-radius tokens.
/// Obtain via: `context.radius`
@immutable
class SplitboRadius extends ThemeExtension<SplitboRadius> {
  const SplitboRadius({
    required this.control,
    required this.card,
    required this.modal,
    required this.pill,
  });

  final double control;  // 12 — buttons, inputs, chips
  final double card;     // 16 — cards, bottom sheets
  final double modal;    // 24 — modals, dialogs
  final double pill;     // 999 — pills, badges, FAB

  static const defaults = SplitboRadius(
    control: 12.0,
    card: 16.0,
    modal: 24.0,
    pill: 999.0,
  );

  @override
  SplitboRadius copyWith({
    double? control, double? card, double? modal, double? pill,
  }) => SplitboRadius(
    control: control ?? this.control,
    card: card ?? this.card,
    modal: modal ?? this.modal,
    pill: pill ?? this.pill,
  );

  @override
  SplitboRadius lerp(SplitboRadius? other, double t) {
    if (other == null) return this;
    return SplitboRadius(
      control: lerpDouble(control, other.control, t)!,
      card:    lerpDouble(card,    other.card,    t)!,
      modal:   lerpDouble(modal,   other.modal,   t)!,
      pill:    lerpDouble(pill,    other.pill,    t)!,
    );
  }
}

/// Animation duration tokens.
/// Obtain via: `context.motion`
@immutable
class SplitboMotion extends ThemeExtension<SplitboMotion> {
  const SplitboMotion({
    required this.fast,
    required this.normal,
    required this.slow,
  });

  final Duration fast;    // 150ms — micro-interactions
  final Duration normal;  // 250ms — transitions
  final Duration slow;    // 400ms — entrances / complex

  static const defaults = SplitboMotion(
    fast:   Duration(milliseconds: 150),
    normal: Duration(milliseconds: 250),
    slow:   Duration(milliseconds: 400),
  );

  @override
  SplitboMotion copyWith({Duration? fast, Duration? normal, Duration? slow}) =>
      SplitboMotion(
        fast:   fast   ?? this.fast,
        normal: normal ?? this.normal,
        slow:   slow   ?? this.slow,
      );

  @override
  // Duration lerp is discrete — use midpoint.
  SplitboMotion lerp(SplitboMotion? other, double t) => t < 0.5 ? this : (other ?? this);
}

/// Ergonomic token accessors on BuildContext.
///
/// Usage:
/// ```dart
/// Container(color: context.colors.backgroundDefault)
/// SizedBox(height: context.spacing.stackMd)
/// BorderRadius.circular(context.radius.card)
/// AnimatedOpacity(duration: context.motion.fast)
/// ```
extension SplitboTokensX on BuildContext {
  SplitboColors  get colors  => Theme.of(this).extension<SplitboColors>()!;
  SplitboSpacing get spacing => Theme.of(this).extension<SplitboSpacing>()!;
  SplitboRadius  get radius  => Theme.of(this).extension<SplitboRadius>()!;
  SplitboMotion  get motion  => Theme.of(this).extension<SplitboMotion>()!;
}
