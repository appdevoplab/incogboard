// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-B. Personal shortcuts ("omw" -> "on my way") offered in the
// suggestion strip. keyboard_main.dart calls createShortcutsFeature(); keep
// that signature.
import '../../keyboard/keyboard_app.dart';
import '../../keyboard/keyboard_session.dart';

KeyboardFeature createShortcutsFeature() => _ShortcutsFeature();

class _ShortcutsFeature extends KeyboardFeature {
  @override
  KeyboardHooks attach(KeyboardSession session) => const KeyboardHooks();
}
