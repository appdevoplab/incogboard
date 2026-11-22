// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. Translate feature: the translate panel (toolbar button, hooks.onTranslate), the
// selection chips, and the installed-pack pairs (re-read when the settings app installs or deletes a pack).
// keyboard_main.dart calls createTranslateFeature(); keep that signature.
import 'dart:async';

import '../../core/data_sections.dart';
import '../../keyboard/keyboard_app.dart';
import '../../keyboard/keyboard_session.dart';
import 'selection_translate.dart';
import 'translate_languages.dart';
import 'translate_panel.dart';

KeyboardFeature createTranslateFeature() => _TranslateFeature();

class _TranslateFeature extends KeyboardFeature {
  KeyboardSession? _session;
  SelectionTranslator? _selection;
  StreamSubscription<List<String>>? _dataSub;

  /// Pair keys of the installed packs; null until read, and again after a pack changed.
  Set<String>? _installed;

  @override
  KeyboardHooks attach(KeyboardSession session) {
    _session = session;
    final services = session.services;
    final selection = SelectionTranslator(
      session: session,
      translate: (text, from, to) => services.host.translate(text, from, to),
      enabled: () => services.settings.value.translate.enabled,
    )..attach();
    _selection = selection;
    _dataSub = services.events.settingsChanged.listen(_onDataChanged);
    if (!services.settings.value.translate.enabled) return const KeyboardHooks();
    return KeyboardHooks(onTranslate: () => _open(session));
  }

  void _open(KeyboardSession session) {
    final translate = session.services.settings.value.translate;
    if (!translate.enabled || session.input.isIncognito) return;
    session.openPanel(
      TranslatePanel(session: session, from: translate.from, to: translate.to, installedPairs: _installedPairs),
    );
  }

  Future<Set<String>> _installedPairs() async {
    final cached = _installed;
    if (cached != null) return cached;
    final session = _session;
    if (session == null) return const {};
    final keys = installedPairKeys(await session.services.platform.listPacks());
    _installed = keys;
    return keys;
  }

  void _onDataChanged(List<String> sections) {
    if (DataSections.affects(sections, DataSections.packs)) _installed = null;
  }

  @override
  void detach() {
    unawaited(_dataSub?.cancel());
    _selection?.detach();
    _session = null;
  }
}
