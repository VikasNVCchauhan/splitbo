// packages/design_system/lib/src/components/app_button.dart
//
// AppButton is the canonical component exemplar for the Splitbo design system.
// All future components must follow the same pattern:
//   • Consumes tokens exclusively via context.colors / context.spacing / context.radius
//   • Exposes a sealed variant enum (no bool flags for mutually-exclusive states)
//   • AnimatedContainer for state transitions (uses context.motion)
//   • minTouchTarget enforcement (44 dp WCAG 2.2 AA)
//   • isLoading replaces onPressed nullability for disabled during async work
//   • No hardcoded colors, radii, or spacing

import 'package:flutter/material.dart';

import '../tokens/app_tokens.g.dart';
import '../typography/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDestructiveConfirm = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isLoading;

  /// When true, pulses a subtle danger colour ring — use for "are you sure?" confirmations.
  final bool isDestructiveConfirm;

  /// When true, the button stretches to fill its parent (replaces wrapping in Expanded).
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radius;
    final motion = context.motion;

    final disabled = widget.onPressed == null || widget.isLoading;
    final (bg, fg, border) = _resolveColors(colors, disabled);
    final (hPad, vPad, iconSz, textStyle) = _resolveSize(spacing);

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled
            ? null
            : (_) {
                setState(() => _pressed = false);
                widget.onPressed?.call();
              },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: motion.fast,
          curve: Curves.easeOut,
          constraints: BoxConstraints(
            minHeight: spacing.minTouchTarget,
            minWidth: widget.expand ? double.infinity : spacing.minTouchTarget,
          ),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: _pressed && !disabled ? _pressedBg(bg, colors) : bg,
            borderRadius: BorderRadius.circular(radii.control),
            border: border != null ? Border.all(color: border, width: 1.5) : null,
            boxShadow: widget.isDestructiveConfirm
                ? [
                    BoxShadow(
                      color: colors.semanticError.withValues(alpha: 0.35),
                      blurRadius: 0,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: _buildContent(fg, textStyle, iconSz, spacing, disabled),
        ),
      ),
    );
  }

  Widget _buildContent(
    Color fg,
    TextStyle textStyle,
    double iconSz,
    SplitboSpacing spacing,
    bool disabled,
  ) {
    if (widget.isLoading) {
      return SizedBox(
        width: iconSz,
        height: iconSz,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: fg,
        ),
      );
    }

    final children = <Widget>[];
    if (widget.leadingIcon != null) {
      children.add(
        IconTheme(
          data: IconThemeData(color: fg, size: iconSz),
          child: widget.leadingIcon!,
        ),
      );
      children.add(SizedBox(width: spacing.inlineSm));
    }

    children.add(
      Text(
        widget.label,
        style: textStyle.copyWith(color: fg),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (widget.trailingIcon != null) {
      children.add(SizedBox(width: spacing.inlineSm));
      children.add(
        IconTheme(
          data: IconThemeData(color: fg, size: iconSz),
          child: widget.trailingIcon!,
        ),
      );
    }

    return Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  /// Returns (backgroundColor, foregroundColor, borderColor)
  (Color, Color, Color?) _resolveColors(SplitboColors c, bool disabled) {
    if (disabled) {
      return (c.backgroundSubtle, c.textDisabled, null);
    }
    return switch (widget.variant) {
      AppButtonVariant.primary => (c.brandPrimary, c.textOnPrimary, null),
      AppButtonVariant.secondary => (
        c.brandPrimaryLt,
        c.brandPrimary,
        c.brandPrimary,
      ),
      AppButtonVariant.ghost => (
        Colors.transparent,
        c.brandPrimary,
        Colors.transparent,
      ),
      AppButtonVariant.danger => (c.semanticError, c.textInverse, null),
    };
  }

  /// Returns (horizontalPadding, verticalPadding, iconSize, textStyle)
  (double, double, double, TextStyle) _resolveSize(SplitboSpacing s) {
    return switch (widget.size) {
      AppButtonSize.small => (
        s.inlineLg,
        s.stackSm,
        16.0,
        AppTextStyles.label,
      ),
      AppButtonSize.medium => (
        s.insetMd,
        s.stackMd,
        18.0,
        AppTextStyles.button,
      ),
      AppButtonSize.large => (
        s.insetLg,
        s.stackMd,
        20.0,
        AppTextStyles.button.copyWith(fontSize: 16),
      ),
    };
  }

  Color _pressedBg(Color bg, SplitboColors c) {
    return switch (widget.variant) {
      AppButtonVariant.primary => c.brandPrimaryDk,
      AppButtonVariant.danger =>
        c.semanticError.withValues(alpha: 0.85),
      _ => bg.withValues(alpha: 0.75),
    };
  }
}
