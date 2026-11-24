// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. Themes for the settings app: the IncogBoard brand scheme, Material You
// colours from the wallpaper when the platform gives them, and the contrast preference.
import 'package:material_ui/material_ui.dart';

import '../../settings/incogboard_settings.dart';
import '../../theme/material_you.dart';
import '../../theme/presets.dart';

/// Contrast preference as the level `ColorScheme.fromSeed` and [materialYouScheme] expect.
double contrastLevelOf(ContrastPreference contrast) => switch (contrast) {
  ContrastPreference.standard => 0,
  ContrastPreference.medium => 0.5,
  ContrastPreference.high => 1.0,
};

/// The brand scheme, used when no wallpaper colours are available: seeded from IncogBoard yellow, with
/// dark brown for emphasis.
ColorScheme incogboardBrandScheme(Brightness brightness, {double contrastLevel = 0}) {
  final light = brightness == Brightness.light;
  final base = ColorScheme.fromSeed(
    seedColor: const Color(incogboardYellow),
    brightness: brightness,
    contrastLevel: contrastLevel,
  );
  return base.copyWith(
    tertiary: light ? const Color(incogboardBrown) : const Color(0xFFE6CCC4),
    onTertiary: light ? const Color(0xFFFFFFFF) : const Color(incogboardBrown),
  );
}

/// Material You scheme from [palettes] (Android 12+), else the brand scheme.
ColorScheme incogboardSchemeFor(Brightness brightness, {List<int>? palettes, double contrastLevel = 0}) {
  if (palettes != null) {
    final wallpaper = materialYouScheme(palettes, brightness, contrastLevel: contrastLevel);
    if (wallpaper != null) return wallpaper;
  }
  return incogboardBrandScheme(brightness, contrastLevel: contrastLevel);
}

ThemeData incogboardThemeData(ColorScheme scheme) => ThemeData(
  useMaterial3: true,
  colorScheme: scheme,
  fontFamily: 'GoogleSansFlex',
  scaffoldBackgroundColor: scheme.surface,
  appBarTheme: AppBarTheme(backgroundColor: scheme.surface, foregroundColor: scheme.onSurface),
);
