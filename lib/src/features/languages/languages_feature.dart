// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-A. Language picker panel (space-bar long press: hooks.onLanguagePicker), per-language extras.
// keyboard_main.dart calls createLanguagesFeature(); keep that signature. Stub from the orchestrator.
import '../../keyboard/keyboard_app.dart';
import '../../keyboard/keyboard_session.dart';

KeyboardFeature createLanguagesFeature() => _Feature();

class _Feature extends KeyboardFeature {
  @override
  KeyboardHooks attach(KeyboardSession session) => const KeyboardHooks();
}
