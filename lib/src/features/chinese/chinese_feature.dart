// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 4-A. Chinese pinyin typing: sets InputController.composer to a pinyin TextComposer
// while the active language is 'zh' and its layout composes, and clears it otherwise.
// keyboard_main.dart calls createChineseFeature(); keep that signature. Stub from the orchestrator.
import '../../keyboard/keyboard_app.dart';
import '../../keyboard/keyboard_session.dart';

KeyboardFeature createChineseFeature() => _Feature();

class _Feature extends KeyboardFeature {
  @override
  KeyboardHooks attach(KeyboardSession session) => const KeyboardHooks();
}
