import 'package:material_ui/material_ui.dart';
import 'package:incogboard/src/bridge/messages.g.dart';
import 'package:incogboard/src/design/design.dart';
import 'package:incogboard/src/theme/keyboard_theme_data.dart';

/// Synthetic Material You palettes: 5 palettes x 13 tones, tinted greys with a
/// distinct hue per palette. Android tone N has lightness 100 - N/10.
List<int> syntheticPalettes({List<double> hues = const [210, 260, 330, 200, 250]}) {
  final out = <int>[];
  for (var p = 0; p < 5; p++) {
    final sat = p < 3 ? 0.55 : 0.08;
    for (final tone in androidTones) {
      final lightness = (100 - tone / 10) / 100;
      final c = HSLColor.fromAHSL(1, hues[p], sat, lightness).toColor();
      out.add(c.toARGB32());
    }
  }
  return out;
}

SystemColorsMessage syntheticSystemColors({bool night = false}) =>
    SystemColorsMessage(palettes: syntheticPalettes(), isNightMode: night);

/// Every (label, fill) pair the keyboard paints, with a description.
List<(String, Color, Color)> labelFillPairs(KeyboardThemeData t) => [
  ('letter label', t.letterKey.label, t.letterKey.fill),
  ('letter hint', t.letterKey.hint, t.letterKey.fill),
  ('letter label pressed', t.letterKey.label, t.letterKey.pressedFill),
  ('function label', t.functionKey.label, t.functionKey.fill),
  ('function hint', t.functionKey.hint, t.functionKey.fill),
  ('function label pressed', t.functionKey.label, t.functionKey.pressedFill),
  ('action label', t.actionKey.label, t.actionKey.fill),
  ('action label pressed', t.actionKey.label, t.actionKey.pressedFill),
  ('space label', t.spaceKey.label, t.spaceKey.fill),
  ('space label pressed', t.spaceKey.label, t.spaceKey.pressedFill),
  ('popup', t.popupLabel, t.popupFill),
  ('popup selected', t.popupSelectedLabel, t.popupSelectedFill),
  ('suggestion text', t.suggestionText, t.background),
  ('suggestion highlight', t.suggestionHighlightText, t.suggestionHighlightFill),
  ('toolbar icon', t.toolbarIcon, t.background),
];
