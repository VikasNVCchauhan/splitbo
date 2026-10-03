import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _green = Color(0xFF739800);
const _charcoal = Color(0xFF141414);
const _charcoalHome = Color(0xFF090A0D);

/// The Splitbo icon mark only (S-shaped diagonal bar + circles).
/// Pass [color] to override the default brand green.
class SplitboLogoMark extends StatelessWidget {
  const SplitboLogoMark({super.key, this.size = 32, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'packages/design_system/assets/images/logo_icon.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color ?? _green, BlendMode.srcIn),
    );
  }
}

/// Full "SplitBo" wordmark (icon + letter-forms).
/// Text letters are charcoal in light mode, white in dark mode.
/// The icon and "Bo" circle stay brand green regardless.
class SplitboWordmark extends StatelessWidget {
  const SplitboWordmark({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SvgPicture.asset(
      'packages/design_system/assets/images/logo_wordmark.svg',
      height: height,
      colorMapper: _WordmarkColorMapper(isDark: isDark),
    );
  }
}

class _WordmarkColorMapper implements ColorMapper {
  const _WordmarkColorMapper({required this.isDark});
  final bool isDark;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (isDark && color == _charcoal) return Colors.white;
    return color;
  }
}

/// Full "SplitBo" wordmark for the home/post-login screens.
/// Uses the home variant SVG — icon in brand green, text adapts to dark/light mode.
class SplitboHomeLogo extends StatelessWidget {
  const SplitboHomeLogo({super.key, this.height = 40});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SvgPicture.asset(
      'packages/design_system/assets/images/logo_home.svg',
      height: height,
      colorMapper: _HomeLogoColorMapper(isDark: isDark),
    );
  }
}

class _HomeLogoColorMapper implements ColorMapper {
  const _HomeLogoColorMapper({required this.isDark});
  final bool isDark;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (isDark && color == _charcoalHome) return Colors.white;
    return color;
  }
}
