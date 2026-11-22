// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 4-B. Japanese typing: sets InputController.composer to a romaji/kana TextComposer
// with kana-kanji conversion while the active language is 'ja', and clears it otherwise.
// keyboard_main.dart calls createJapaneseFeature(); keep that signature. Stub from the orchestrator.
import '../../keyboard/keyboard_app.dart';
import '../../keyboard/keyboard_session.dart';

KeyboardFeature createJapaneseFeature() => _Feature();

class _Feature extends KeyboardFeature {
  @override
  KeyboardHooks attach(KeyboardSession session) => const KeyboardHooks();
}
