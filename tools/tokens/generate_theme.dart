#!/usr/bin/env dart
// tools/tokens/generate_theme.dart
//
// Reads tools/tokens/tokens.json, resolves all {reference} values,
// and writes packages/design_system/lib/src/tokens/app_tokens.g.dart
//
// Run: dart tools/tokens/generate_theme.dart
// Or via melos: melos tokens

import 'dart:convert';
import 'dart:io';

void main() {
  final tokensFile = File('tools/tokens/tokens.json');
  if (!tokensFile.existsSync()) {
    stderr.writeln('ERROR: tools/tokens/tokens.json not found. Run from repo root.');
    exit(1);
  }

  final raw = jsonDecode(tokensFile.readAsStringSync()) as Map<String, dynamic>;
  final resolver = _TokenResolver(raw);

  final primitiveColors = _flattenColors(
    raw['primitive']['color'] as Map<String, dynamic>,
    resolver,
    prefix: 'primitive.color',
  );

  final lightSemanticColors = _flattenColors(
    raw['semantic']['light']['color'] as Map<String, dynamic>,
    resolver,
    prefix: 'semantic.light.color',
  );

  final darkSemanticColors = _flattenColors(
    raw['semantic']['dark']['color'] as Map<String, dynamic>,
    resolver,
    prefix: 'semantic.dark.color',
  );

  final spaces = _flattenNumbers(
    raw['semantic']['shared']['space'] as Map<String, dynamic>,
    resolver,
  );

  final radii = _flattenNumbers(
    raw['semantic']['shared']['radius'] as Map<String, dynamic>,
    resolver,
  );

  final durations = _flattenNumbers(
    raw['semantic']['shared']['motion']['duration'] as Map<String, dynamic>,
    resolver,
  );

  final minTouchTarget = resolver.resolveNumber(
    raw['semantic']['shared']['minTouchTarget']['${'$'}value'] as String,
  );

  final primitiveSpaces = _flattenNumbers(
    raw['primitive']['space'] as Map<String, dynamic>,
    resolver,
  );

  final primitiveRadii = _flattenNumbers(
    raw['primitive']['radius'] as Map<String, dynamic>,
    resolver,
  );

  final out = StringBuffer();
  out.writeln(_header);

  // ── Primitive colours (used only for contrast gate and codegen; UI uses semantic) ──
  out.writeln('/// Raw brand palette — do NOT use in UI code. Use [SplitboColors] instead.');
  out.writeln('abstract final class _Palette {');
  for (final e in primitiveColors.entries) {
    out.writeln('  static const Color ${_dartName(e.key)} = Color(${_hexToArgb(e.value)});');
  }
  out.writeln('}');
  out.writeln();

  // ── Primitive spacing ──
  out.writeln('/// Raw spacing scale — do NOT use in UI code. Use [SplitboSpacing] instead.');
  out.writeln('abstract final class _SpaceScale {');
  for (final e in primitiveSpaces.entries) {
    out.writeln('  static const double s${_normaliseKey(e.key)} = ${e.value.toStringAsFixed(1)};');
  }
  out.writeln('}');
  out.writeln();

  // ── Primitive radii ──
  out.writeln('/// Raw radius scale — do NOT use in UI code. Use [SplitboRadius] instead.');
  out.writeln('abstract final class _RadiusScale {');
  for (final e in primitiveRadii.entries) {
    out.writeln('  static const double r${_normaliseKey(e.key)} = ${e.value.toStringAsFixed(1)};');
  }
  out.writeln('}');
  out.writeln();

  // ── Semantic colour class ──
  out.writeln('/// Semantic colour tokens — the ONLY colour API for UI code.');
  out.writeln('/// Obtain via: Theme.of(context).extension<SplitboColors>()!');
  out.writeln('@immutable');
  out.writeln('class SplitboColors extends ThemeExtension<SplitboColors> {');
  out.writeln('  const SplitboColors({');
  for (final e in lightSemanticColors.entries) {
    out.writeln('    required this.${_dartName(e.key)},');
  }
  out.writeln('  });');
  out.writeln();
  for (final e in lightSemanticColors.entries) {
    out.writeln('  final Color ${_dartName(e.key)};');
  }
  out.writeln();

  // light factory
  out.writeln('  static const light = SplitboColors(');
  for (final e in lightSemanticColors.entries) {
    out.writeln('    ${_dartName(e.key)}: Color(${_hexToArgb(e.value)}),');
  }
  out.writeln('  );');
  out.writeln();

  // dark factory
  out.writeln('  static const dark = SplitboColors(');
  for (final e in darkSemanticColors.entries) {
    out.writeln('    ${_dartName(e.key)}: Color(${_hexToArgb(e.value)}),');
  }
  out.writeln('  );');
  out.writeln();

  // copyWith
  out.writeln('  @override');
  out.writeln('  SplitboColors copyWith({');
  for (final e in lightSemanticColors.entries) {
    out.writeln('    Color? ${_dartName(e.key)},');
  }
  out.writeln('  }) => SplitboColors(');
  for (final e in lightSemanticColors.entries) {
    final n = _dartName(e.key);
    out.writeln('    $n: $n ?? this.$n,');
  }
  out.writeln('  );');
  out.writeln();

  // lerp
  out.writeln('  @override');
  out.writeln('  SplitboColors lerp(SplitboColors? other, double t) {');
  out.writeln('    if (other == null) return this;');
  out.writeln('    return SplitboColors(');
  for (final e in lightSemanticColors.entries) {
    final n = _dartName(e.key);
    out.writeln('      $n: Color.lerp($n, other.$n, t)!,');
  }
  out.writeln('    );');
  out.writeln('  }');
  out.writeln('}');
  out.writeln();

  // ── Spacing ──
  out.writeln('/// Semantic spacing tokens. Obtain via: Theme.of(context).extension<SplitboSpacing>()!');
  out.writeln('@immutable');
  out.writeln('class SplitboSpacing extends ThemeExtension<SplitboSpacing> {');
  out.writeln('  const SplitboSpacing({');
  for (final e in spaces.entries) {
    out.writeln('    required this.${_dartName(e.key)},');
  }
  out.writeln('    required this.minTouchTarget,');
  out.writeln('  });');
  out.writeln();
  for (final e in spaces.entries) {
    out.writeln('  final double ${_dartName(e.key)};');
  }
  out.writeln('  /// WCAG 2.2 AA minimum interactive target size.');
  out.writeln('  final double minTouchTarget;');
  out.writeln();

  out.writeln('  static const defaults = SplitboSpacing(');
  for (final e in spaces.entries) {
    out.writeln('    ${_dartName(e.key)}: ${e.value.toStringAsFixed(1)},');
  }
  out.writeln('    minTouchTarget: ${minTouchTarget.toStringAsFixed(1)},');
  out.writeln('  );');
  out.writeln();

  out.writeln('  @override');
  out.writeln('  SplitboSpacing copyWith({');
  for (final e in spaces.entries) {
    out.writeln('    double? ${_dartName(e.key)},');
  }
  out.writeln('    double? minTouchTarget,');
  out.writeln('  }) => SplitboSpacing(');
  for (final e in spaces.entries) {
    final n = _dartName(e.key);
    out.writeln('    $n: $n ?? this.$n,');
  }
  out.writeln('    minTouchTarget: minTouchTarget ?? this.minTouchTarget,');
  out.writeln('  );');
  out.writeln();

  out.writeln('  @override');
  out.writeln('  SplitboSpacing lerp(SplitboSpacing? other, double t) {');
  out.writeln('    if (other == null) return this;');
  out.writeln('    return SplitboSpacing(');
  for (final e in spaces.entries) {
    final n = _dartName(e.key);
    out.writeln('      $n: lerpDouble($n, other.$n, t)!,');
  }
  out.writeln('      minTouchTarget: lerpDouble(minTouchTarget, other.minTouchTarget, t)!,');
  out.writeln('    );');
  out.writeln('  }');
  out.writeln('}');
  out.writeln();

  // ── Radius ──
  out.writeln('/// Semantic radius tokens. Obtain via: Theme.of(context).extension<SplitboRadius>()!');
  out.writeln('@immutable');
  out.writeln('class SplitboRadius extends ThemeExtension<SplitboRadius> {');
  out.writeln('  const SplitboRadius({');
  for (final e in radii.entries) {
    out.writeln('    required this.${_dartName(e.key)},');
  }
  out.writeln('  });');
  out.writeln();
  for (final e in radii.entries) {
    out.writeln('  final double ${_dartName(e.key)};');
  }
  out.writeln();

  out.writeln('  static const defaults = SplitboRadius(');
  for (final e in radii.entries) {
    out.writeln('    ${_dartName(e.key)}: ${e.value.toStringAsFixed(1)},');
  }
  out.writeln('  );');
  out.writeln();

  out.writeln('  @override');
  out.writeln('  SplitboRadius copyWith({');
  for (final e in radii.entries) {
    out.writeln('    double? ${_dartName(e.key)},');
  }
  out.writeln('  }) => SplitboRadius(');
  for (final e in radii.entries) {
    final n = _dartName(e.key);
    out.writeln('    $n: $n ?? this.$n,');
  }
  out.writeln('  );');
  out.writeln();

  out.writeln('  @override');
  out.writeln('  SplitboRadius lerp(SplitboRadius? other, double t) {');
  out.writeln('    if (other == null) return this;');
  out.writeln('    return SplitboRadius(');
  for (final e in radii.entries) {
    final n = _dartName(e.key);
    out.writeln('      $n: lerpDouble($n, other.$n, t)!,');
  }
  out.writeln('    );');
  out.writeln('  }');
  out.writeln('}');
  out.writeln();

  // ── Motion ──
  out.writeln('/// Animation duration tokens. Obtain via: Theme.of(context).extension<SplitboMotion>()!');
  out.writeln('@immutable');
  out.writeln('class SplitboMotion extends ThemeExtension<SplitboMotion> {');
  out.writeln('  const SplitboMotion({');
  for (final e in durations.entries) {
    out.writeln('    required this.${_dartName(e.key)},');
  }
  out.writeln('  });');
  out.writeln();
  for (final e in durations.entries) {
    out.writeln('  final Duration ${_dartName(e.key)};');
  }
  out.writeln();

  out.writeln('  static const defaults = SplitboMotion(');
  for (final e in durations.entries) {
    out.writeln('    ${_dartName(e.key)}: Duration(milliseconds: ${e.value.toInt()}),');
  }
  out.writeln('  );');
  out.writeln();

  out.writeln('  @override');
  out.writeln('  SplitboMotion copyWith({');
  for (final e in durations.entries) {
    out.writeln('    Duration? ${_dartName(e.key)},');
  }
  out.writeln('  }) => SplitboMotion(');
  for (final e in durations.entries) {
    final n = _dartName(e.key);
    out.writeln('    $n: $n ?? this.$n,');
  }
  out.writeln('  );');
  out.writeln();

  out.writeln('  @override');
  out.writeln('  SplitboMotion lerp(SplitboMotion? other, double t) => t < 0.5 ? this : (other ?? this);');
  out.writeln('}');
  out.writeln();

  // ── BuildContext extension for ergonomic access ──
  out.writeln('/// Ergonomic token accessors: context.colors, context.spacing, context.radius, context.motion');
  out.writeln('extension SplitboTokensX on BuildContext {');
  out.writeln('  SplitboColors  get colors  => Theme.of(this).extension<SplitboColors>()!;');
  out.writeln('  SplitboSpacing get spacing => Theme.of(this).extension<SplitboSpacing>()!;');
  out.writeln('  SplitboRadius  get radius  => Theme.of(this).extension<SplitboRadius>()!;');
  out.writeln('  SplitboMotion  get motion  => Theme.of(this).extension<SplitboMotion>()!;');
  out.writeln('}');

  // Write output
  final outDir = Directory('packages/design_system/lib/src/tokens');
  outDir.createSync(recursive: true);
  final outFile = File('packages/design_system/lib/src/tokens/app_tokens.g.dart');
  outFile.writeAsStringSync(out.toString());

  stdout.writeln('✓ Generated ${outFile.path}');
  stdout.writeln('  Colors:   ${lightSemanticColors.length} semantic (${primitiveColors.length} primitive)');
  stdout.writeln('  Spacing:  ${spaces.length} tokens');
  stdout.writeln('  Radius:   ${radii.length} tokens');
  stdout.writeln('  Motion:   ${durations.length} tokens');
}

// ── Helpers ───────────────────────────────────────────────────

const _header = '''
// GENERATED FILE — DO NOT EDIT MANUALLY.
// Regenerate with: dart tools/tokens/generate_theme.dart  (or: melos tokens)
// Source: tools/tokens/tokens.json

// ignore_for_file: lines_longer_than_80_chars

import 'dart:ui' show lerpDouble;
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';

''';

class _TokenResolver {
  _TokenResolver(this._root);
  final Map<String, dynamic> _root;

  String resolveColor(String value) {
    if (value.startsWith('{') && value.endsWith('}')) {
      final path = value.substring(1, value.length - 1).split('.');
      dynamic node = _root;
      for (final segment in path) {
        node = (node as Map<String, dynamic>)[segment];
      }
      final resolved = (node as Map<String, dynamic>)[r'$value'] as String;
      return resolveColor(resolved);
    }
    return value;
  }

  double resolveNumber(String value) {
    if (value.startsWith('{') && value.endsWith('}')) {
      final path = value.substring(1, value.length - 1).split('.');
      dynamic node = _root;
      for (final segment in path) {
        node = (node as Map<String, dynamic>)[segment];
      }
      final resolved = (node as Map<String, dynamic>)[r'$value'];
      if (resolved is String) return resolveNumber(resolved);
      return (resolved as num).toDouble();
    }
    return double.parse(value);
  }
}

Map<String, String> _flattenColors(
  Map<String, dynamic> node,
  _TokenResolver resolver, {
  required String prefix,
  String path = '',
}) {
  final result = <String, String>{};
  for (final entry in node.entries) {
    if (entry.key.startsWith(r'$')) continue;
    final fullPath = path.isEmpty ? entry.key : '$path.${entry.key}';
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      if (value.containsKey(r'$value')) {
        result[fullPath] = resolver.resolveColor(value[r'$value'] as String);
      } else {
        result.addAll(_flattenColors(value, resolver, prefix: prefix, path: fullPath));
      }
    }
  }
  return result;
}

Map<String, double> _flattenNumbers(
  Map<String, dynamic> node,
  _TokenResolver resolver, {
  String path = '',
}) {
  final result = <String, double>{};
  for (final entry in node.entries) {
    if (entry.key.startsWith(r'$')) continue;
    final fullPath = path.isEmpty ? entry.key : '$path.${entry.key}';
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      if (value.containsKey(r'$value')) {
        final raw = value[r'$value'];
        if (raw is num) {
          result[fullPath] = raw.toDouble();
        } else {
          result[fullPath] = resolver.resolveNumber(raw as String);
        }
      } else {
        result.addAll(_flattenNumbers(value, resolver, path: fullPath));
      }
    }
  }
  return result;
}

String _dartName(String tokenPath) {
  // 'background.default' → 'backgroundDefault'
  // 'inset.xs' → 'insetXs'
  return tokenPath
      .split('.')
      .map((s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''))
      .indexed
      .map((e) => e.$1 == 0 ? e.$2.toLowerCase() : _capitalise(e.$2))
      .join();
}

String _normaliseKey(String key) {
  // '1' → '1', 'none' → 'None', 'full' → 'Full'
  return key[0].toUpperCase() + key.substring(1);
}

String _capitalise(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _hexToArgb(String hex) {
  // '#9CD246' → '0xFF9CD246'
  final clean = hex.replaceAll('#', '').toUpperCase();
  return '0xFF$clean';
}
