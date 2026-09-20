import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders the Splitbo logo mark from the canonical SVG asset.
/// Use [size] to control width/height (square). Color defaults to brand green.
class SplitboLogoMark extends StatelessWidget {
  const SplitboLogoMark({
    super.key,
    this.size = 32,
    this.color,
  });

  final double size;
  final Color? color;

  static const _assetPath =
      'packages/design_system/assets/images/logo_mark.svg';

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFFC3FD00);
    return SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}
