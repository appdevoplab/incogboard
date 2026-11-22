// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-D. Voice typing: hooks.onVoice opens the mic panel; events from ImeEvents.voice.
// keyboard_main.dart calls createVoiceFeature(); keep that signature. Stub from the orchestrator.
import '../../keyboard/keyboard_app.dart';
import '../../keyboard/keyboard_session.dart';

KeyboardFeature createVoiceFeature() => _Feature();

class _Feature extends KeyboardFeature {
  @override
  KeyboardHooks attach(KeyboardSession session) => const KeyboardHooks();
}
