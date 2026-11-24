// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-D. Voice typing: hooks.onVoice opens the mic panel (the toolbar's mic button and a
// KeyType.voice key). Never opens in password fields or while incognito. keyboard_main.dart calls
// createVoiceFeature(); keep that signature.
import 'dart:async';

import '../../app/routes.dart';
import '../../keyboard/keyboard_app.dart';
import '../../keyboard/keyboard_session.dart';
import 'voice_controller.dart';
import 'voice_panel.dart';

KeyboardFeature createVoiceFeature() => _VoiceFeature();

class _VoiceFeature extends KeyboardFeature {
  @override
  KeyboardHooks attach(KeyboardSession session) => KeyboardHooks(onVoice: () => _open(session));

  void _open(KeyboardSession session) {
    final input = session.input;
    // Voice is off in password fields and in incognito: nothing is opened and nothing is recorded.
    if (input.currentField.isSensitive || input.isIncognito) return;

    final services = session.services;
    final settings = services.settings.value;
    final host = services.host;

    late final VoicePanel panel;
    final controller = VoiceController(
      host: host,
      events: services.events.voice,
      text: InputVoiceTextSink(
        editor: input.editor,
        finish: input.finishComposing,
        resync: input.resyncAfterExternalEdit,
      ),
      packId: settings.voice.modelId,
      enabled: settings.voice.enabled,
      languages: settings.languages.enabled,
      defaultLanguage: session.activeLanguage.value,
      autoDetect: settings.voice.autoDetectLanguage,
    );
    controller.onFinished = () {
      if (identical(session.panel.value, panel)) session.closePanel();
    };
    panel = VoicePanel(
      controller: controller,
      openSettings: () => _openRoute(session, IncogBoardRoutes.voice),
      openPacks: () => _openRoute(session, IncogBoardRoutes.packs),
    );
    session.openPanel(panel);
    unawaited(controller.begin());
  }

  void _openRoute(KeyboardSession session, String route) {
    unawaited(
      session.services.host.openSettings(route).catchError((Object _) {
        // The settings app could not be opened: the panel keeps its message.
      }),
    );
  }
}
