// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-B. Indic typing in English letters: sets InputController.transform / swipeTransform and KeyboardSession.gestureWordSources for the active language.
// keyboard_main.dart calls createIndicFeature(); keep that signature. Stub from the orchestrator.
import '../../keyboard/keyboard_app.dart';
import '../../keyboard/keyboard_session.dart';

KeyboardFeature createIndicFeature() => _Feature();

class _Feature extends KeyboardFeature {
  @override
  KeyboardHooks attach(KeyboardSession session) => const KeyboardHooks();
}
