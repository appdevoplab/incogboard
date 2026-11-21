// SPDX-License-Identifier: GPL-3.0-or-later
//
// Built-in themes, defined in Dart so resolution stays synchronous. Every
// preset has light, dark and pure-black variants and three contrast levels,
// all derived from the same spec (see theme_resolver.dart).
import 'theme_spec.dart';

/// Brand yellow (Myna mascot icon) and brand dark brown.
const int mynaYellow = 0xFFF5B700;
const int mynaBrown = 0xFF3E2723;

const String defaultThemeId = 'myna_dynamic';

abstract final class ThemePresets {
  /// Wallpaper colours on Android 12+, brand seed otherwise.
  static const ThemeSpec mynaDynamic = ThemeSpec(
    id: 'myna_dynamic',
    name: 'Myna Dynamic',
    colorSource: ThemeColorSource.dynamic,
    seedColor: mynaYellow,
    variant: ThemeSchemeVariant.fidelity,
  );

  /// The brand look: warm yellow primary with dark-brown accents.
  static const ThemeSpec mynaGold = ThemeSpec(
    id: 'myna_gold',
    name: 'Myna Gold',
    colorSource: ThemeColorSource.custom,
    seedColor: mynaYellow,
    variant: ThemeSchemeVariant.fidelity,
    customRoles: {
      'primary': mynaYellow,
      'onPrimary': mynaBrown,
      'primaryContainer': 0xFFFFE08C,
      'onPrimaryContainer': mynaBrown,
      'secondary': 0xFF8D6E63,
      'onSecondary': 0xFFFFFFFF,
      'secondaryContainer': 0xFFF1DFC4,
      'onSecondaryContainer': mynaBrown,
      'tertiary': 0xFF6D4C41,
      'onTertiary': 0xFFFFFFFF,
      'tertiaryContainer': 0xFFFFDBC8,
      'onTertiaryContainer': mynaBrown,
      'surface': 0xFFFFF8EA,
      'onSurface': 0xFF2A1F1B,
      'onSurfaceVariant': 0xFF5D4A42,
      'surfaceContainer': 0xFFFFF0CC,
      'surfaceContainerHigh': 0xFFFFF6E3,
      'surfaceContainerHighest': 0xFFFFFBF0,
      'outline': 0xFF8A7468,
      'outlineVariant': 0xFFE3D2B5,
    },
    customRolesDark: {
      'primary': mynaYellow,
      'onPrimary': mynaBrown,
      'primaryContainer': 0xFF5C4400,
      'onPrimaryContainer': 0xFFFFE08C,
      'secondary': 0xFFD7BFA8,
      'onSecondary': mynaBrown,
      'secondaryContainer': 0xFF4F4130,
      'onSecondaryContainer': 0xFFF1DFC4,
      'tertiary': 0xFFE0B9A4,
      'onTertiary': mynaBrown,
      'tertiaryContainer': 0xFF5D4037,
      'onTertiaryContainer': 0xFFFFDBC8,
      'surface': 0xFF1F1A12,
      'onSurface': 0xFFEDE1CF,
      'onSurfaceVariant': 0xFFD3C4B0,
      'surfaceContainer': 0xFF251F16,
      'surfaceContainerHigh': 0xFF30291D,
      'surfaceContainerHighest': 0xFF3B3326,
      'outline': 0xFF9C8E7C,
      'outlineVariant': 0xFF4D4435,
    },
  );

  static const ThemeSpec lavender = ThemeSpec(id: 'lavender', name: 'Lavender', seedColor: 0xFF8F6FD8);

  static const ThemeSpec ocean = ThemeSpec(id: 'ocean', name: 'Ocean', seedColor: 0xFF0B79C4);

  static const ThemeSpec mint = ThemeSpec(
    id: 'mint',
    name: 'Mint',
    seedColor: 0xFF2FA67F,
    variant: ThemeSchemeVariant.vibrant,
  );

  static const ThemeSpec coral = ThemeSpec(
    id: 'coral',
    name: 'Coral',
    seedColor: 0xFFFF6F61,
    variant: ThemeSchemeVariant.vibrant,
  );

  static const ThemeSpec rose = ThemeSpec(
    id: 'rose',
    name: 'Rose',
    seedColor: 0xFFD6336C,
    variant: ThemeSchemeVariant.expressive,
  );

  /// Monochrome; slightly squarer keys than the others.
  static const ThemeSpec graphite = ThemeSpec(
    id: 'graphite',
    name: 'Graphite',
    seedColor: 0xFF616161,
    variant: ThemeSchemeVariant.monochrome,
    keyRadius: 0.32,
  );

  /// Gallery order.
  static const List<ThemeSpec> all = [mynaDynamic, mynaGold, lavender, ocean, mint, coral, rose, graphite];

  /// The preset with [id], or [mynaDynamic] if unknown.
  static ThemeSpec byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return mynaDynamic;
  }

  static bool isPresetId(String id) => all.any((p) => p.id == id);
}
