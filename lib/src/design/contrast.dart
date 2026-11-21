// SPDX-License-Identifier: GPL-3.0-or-later
//
// WCAG 2.x contrast helpers.
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

const Color _white = Color(0xFFFFFFFF);
const Color _black = Color(0xFF000000);

/// WCAG relative luminance of an opaque color.
double relativeLuminance(Color c) {
  double lin(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

/// WCAG contrast ratio between two colors (1..21). Alpha is ignored.
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Returns [foreground] if it already reaches [minRatio] against [background];
/// otherwise the nearest tint of it (moved toward black or white, whichever
/// contrasts more with the background) that does. Keeps the hue where possible.
Color ensureContrast(Color foreground, Color background, double minRatio) {
  if (contrastRatio(foreground, background) >= minRatio) return foreground;
  final target = contrastRatio(_white, background) >= contrastRatio(_black, background) ? _white : _black;
  var lo = 0.0;
  var hi = 1.0;
  for (var i = 0; i < 20; i++) {
    final mid = (lo + hi) / 2;
    if (contrastRatio(Color.lerp(foreground, target, mid)!, background) >= minRatio) {
      hi = mid;
    } else {
      lo = mid;
    }
  }
  final result = Color.lerp(foreground, target, hi)!;
  return contrastRatio(result, background) >= minRatio ? result : target;
}

/// Opaque blend of [top] (with its alpha) over [bottom].
Color blend(Color top, Color bottom) => Color.alphaBlend(top, bottom);
