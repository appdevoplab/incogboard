// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 1-D (theme system). Wave 0 placeholder: system light/dark
// fallback theme. Keep this function signature stable.
import 'package:material_ui/material_ui.dart';

import '../bridge/messages.g.dart';
import '../settings/sections/appearance_settings.dart';
import 'keyboard_theme_data.dart';

/// Resolves the keyboard theme to paint.
///
/// [systemColors] is null on Android < 12 (no Material You palette).
/// [systemDark] is the system night mode.
/// [disableAnimations] reflects the system "Remove animations" setting.
KeyboardThemeData resolveKeyboardTheme({
  required AppearanceSettings appearance,
  required SystemColorsMessage? systemColors,
  required bool systemDark,
  required bool disableAnimations,
}) {
  final dark =
      appearance.darkMode == DarkModePreference.dark ||
      (appearance.darkMode == DarkModePreference.system && systemDark);
  return KeyboardThemeData.fallback(dark ? Brightness.dark : Brightness.light);
}
