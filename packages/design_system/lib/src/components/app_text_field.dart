// packages/design_system/lib/src/components/app_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_tokens.g.dart';
import '../typography/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.prefix,
    this.suffix,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingTap,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final String? prefix;
  final String? suffix;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? onTrailingTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focus;
  bool _focused = false;
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _obscured = widget.obscureText;
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() => _focused = _focus.hasFocus);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    final hasError = widget.error != null && widget.error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.label.copyWith(
              color: hasError
                  ? colors.semanticError
                  : _focused
                      ? colors.brandPrimary
                      : colors.textSecondary,
            ),
          ),
          SizedBox(height: spacing.stackXs),
        ],
        TextField(
          controller: widget.controller,
          focusNode: _focus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          style: AppTextStyles.bodyM.copyWith(color: colors.textPrimary),
          cursorColor: colors.brandPrimary,
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            prefixText: widget.prefix,
            suffixText: widget.suffix,
            prefixIcon: widget.leadingIcon != null
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.insetSm),
                    child: IconTheme(
                      data: IconThemeData(
                        color: _focused ? colors.brandPrimary : colors.textSecondary,
                        size: 20,
                      ),
                      child: widget.leadingIcon!,
                    ),
                  )
                : null,
            suffixIcon: _buildSuffix(colors, spacing),
            // Error colour override — InputDecorationTheme in AppTheme sets
            // everything else; we only override when there's an active error.
            enabledBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.radius.control),
                    borderSide: BorderSide(color: colors.borderError),
                  )
                : null,
          ),
        ),
        if (hasError) ...[
          SizedBox(height: spacing.stackXs),
          Row(
            children: [
              Icon(Icons.error_outline, size: 12, color: colors.semanticError),
              SizedBox(width: spacing.inlineXs),
              Expanded(
                child: Text(
                  widget.error!,
                  style: AppTextStyles.caption
                      .copyWith(color: colors.semanticError),
                ),
              ),
            ],
          ),
        ] else if (widget.helper != null) ...[
          SizedBox(height: spacing.stackXs),
          Text(
            widget.helper!,
            style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffix(SplitboColors colors, SplitboSpacing spacing) {
    final widgets = <Widget>[];

    if (widget.obscureText) {
      widgets.add(
        GestureDetector(
          onTap: () => setState(() => _obscured = !_obscured),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.insetSm),
            child: Icon(
              _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: colors.textSecondary,
            ),
          ),
        ),
      );
    } else if (widget.trailingIcon != null) {
      widgets.add(
        GestureDetector(
          onTap: widget.onTrailingTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.insetSm),
            child: IconTheme(
              data: IconThemeData(color: colors.textSecondary, size: 20),
              child: widget.trailingIcon!,
            ),
          ),
        ),
      );
    }

    if (widgets.isEmpty) return null;
    return Row(mainAxisSize: MainAxisSize.min, children: widgets);
  }
}
