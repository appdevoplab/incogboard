// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-D. Entry point for the emoji, clipboard and editing panels.
// keyboard_main.dart calls createPanelsFeature(); keep that signature.
import '../keyboard/keyboard_app.dart';
import '../keyboard/keyboard_session.dart';

/// Emoji, clipboard and editing panels, emoji suggestions and clipboard chips.
KeyboardFeature createPanelsFeature() => _PanelsFeature();

class _PanelsFeature extends KeyboardFeature {
  @override
  KeyboardHooks attach(KeyboardSession session) => const KeyboardHooks();
}
