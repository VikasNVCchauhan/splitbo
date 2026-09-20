#!/usr/bin/env dart
// tools/contrast_check/check_contrast.dart
//
// WCAG 2.2 AA contrast gate — run via: melos contrast
// Fails with exit code 1 if any semantic fg/bg pair falls below AA thresholds:
//   • Normal text (< 18pt / < 14pt bold): ratio ≥ 4.5
//   • Large text (≥ 18pt or ≥ 14pt bold): ratio ≥ 3.0
//   • UI components / icons: ratio ≥ 3.0
//
// Add new pairs to _pairsToCheck below when adding new semantic tokens.

import 'dart:io';

void main() {
  final failures = <String>[];
  var checked = 0;

  for (final pair in _pairsToCheck) {
    checked++;
    final ratio = _contrastRatio(pair.fg, pair.bg);
    final required = pair.isLargeText ? 3.0 : 4.5;
    if (ratio < required) {
      failures.add(
        '  FAIL  ${pair.name.padRight(40)} '
        'ratio=${ratio.toStringAsFixed(2)} (need ≥$required)',
      );
    }
  }

  if (failures.isEmpty) {
    stdout.writeln('✓ Contrast check passed — $checked pairs verified (WCAG 2.2 AA)');
    exit(0);
  } else {
    stderr.writeln('✗ Contrast check FAILED — ${failures.length}/$checked pairs below threshold:\n');
    for (final f in failures) {
      stderr.writeln(f);
    }
    stderr.writeln(
      '\nFix: adjust the failing token values in tools/tokens/tokens.json '
      'then re-run: melos tokens && melos contrast',
    );
    exit(1);
  }
}

// ── Pairs to check ────────────────────────────────────────────────────────────
// Format: _Pair(name, fg hex, bg hex, isLargeText)
// Hex values must match the RESOLVED values in tokens.json (not references).

const _pairsToCheck = [
  // ── Light theme ─────────────────────────────────────────────────────────────
  _Pair('light / text.primary on bg.default',          '#0D0D0D', '#FFFFFF'),
  _Pair('light / text.secondary on bg.default',        '#666666', '#FFFFFF'),
  _Pair('light / text.primary on surface.raised',      '#0D0D0D', '#F5F5F5'),
  _Pair('light / text.onPrimary on brand.primary',     '#000000', '#9CD246'),
  _Pair('light / text.inverse on semantic.error',      '#FFFFFF', '#DC2626'),
  _Pair('light / brand.primary on bg.default (UI)',    '#9CD246', '#FFFFFF', true),
  _Pair('light / semantic.positive on bg.default (UI)','#22C55E', '#FFFFFF', true),
  _Pair('light / semantic.negative on bg.default (UI)','#F97316', '#FFFFFF', true),
  _Pair('light / semantic.error on bg.default',        '#DC2626', '#FFFFFF'),
  _Pair('light / text.primary on surface.overlay',     '#0D0D0D', '#FFFFFF'),

  // ── Dark theme ──────────────────────────────────────────────────────────────
  _Pair('dark / text.primary on bg.default',           '#FFFFFF', '#000000'),
  _Pair('dark / text.secondary on bg.default',         '#9E9E9E', '#000000'),
  _Pair('dark / text.primary on surface.default',      '#FFFFFF', '#141414'),
  _Pair('dark / text.primary on surface.raised',       '#FFFFFF', '#1A1A1A'),
  _Pair('dark / text.onPrimary on brand.primary',      '#000000', '#9CD246'),
  _Pair('dark / text.inverse on semantic.error',       '#0D0D0D', '#DC2626'),
  _Pair('dark / brand.primary on bg.default (UI)',     '#9CD246', '#000000', true),
  _Pair('dark / semantic.positive on bg.default (UI)', '#22C55E', '#000000', true),
  _Pair('dark / semantic.negative on bg.default (UI)', '#F97316', '#000000', true),
  _Pair('dark / semantic.error on surface.default',    '#DC2626', '#141414'),
  _Pair('dark / text.primary on surface.overlay',      '#FFFFFF', '#1E1E1E'),
];

// ── WCAG contrast math ────────────────────────────────────────────────────────

class _Pair {
  const _Pair(this.name, this.fg, this.bg, [this.isLargeText = false]);
  final String name;
  final String fg;
  final String bg;
  final bool isLargeText;
}

double _contrastRatio(String fg, String bg) {
  final l1 = _relativeLuminance(_parseHex(fg));
  final l2 = _relativeLuminance(_parseHex(bg));
  final lighter = l1 > l2 ? l1 : l2;
  final darker  = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

(int, int, int) _parseHex(String hex) {
  final h = hex.replaceAll('#', '');
  return (
    int.parse(h.substring(0, 2), radix: 16),
    int.parse(h.substring(2, 4), radix: 16),
    int.parse(h.substring(4, 6), radix: 16),
  );
}

double _relativeLuminance((int, int, int) rgb) {
  double linearise(int v) {
    final s = v / 255.0;
    return s <= 0.04045 ? s / 12.92 : ((s + 0.055) / 1.055) * ((s + 0.055) / 1.055);
  }

  final r = linearise(rgb.$1);
  final g = linearise(rgb.$2);
  final b = linearise(rgb.$3);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}
