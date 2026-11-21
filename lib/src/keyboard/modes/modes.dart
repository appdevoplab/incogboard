// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-E. Keyboard modes: one-handed, floating, height handle,
// space-bar cursor control, backspace swipe-to-delete, tablet and landscape
// layouts. keyboard_main.dart calls createModesFeature(); keep that signature.
import '../keyboard_app.dart';
import '../keyboard_session.dart';

KeyboardFeature createModesFeature() => _ModesFeature();

class _ModesFeature extends KeyboardFeature {
  @override
  KeyboardHooks attach(KeyboardSession session) => const KeyboardHooks();

  /// Null keeps the default docked, full-width frame.
  @override
  KeyboardFrame? get frame => null;
}
