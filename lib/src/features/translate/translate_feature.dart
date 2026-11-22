// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. Translate panel (hooks.onTranslate) and the "Translate" selection chip.
// keyboard_main.dart calls createTranslateFeature(); keep that signature. Stub from the orchestrator.
import '../../keyboard/keyboard_app.dart';
import '../../keyboard/keyboard_session.dart';

KeyboardFeature createTranslateFeature() => _Feature();

class _Feature extends KeyboardFeature {
  @override
  KeyboardHooks attach(KeyboardSession session) => const KeyboardHooks();
}
