// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:flutter_test/flutter_test.dart';
import 'package:kosha/src/bridge/messages.g.dart';
import 'package:kosha/src/core/input_field_info.dart';
import 'package:kosha/src/engine/lang/japanese/japanese_composer.dart';
import 'package:kosha/src/features/japanese/japanese_feature.dart';
import 'package:kosha/src/keyboard/keyboard_app.dart';
import 'package:kosha/src/keyboard/keyboard_session.dart';
import 'package:kosha/src/settings/kosha_settings.dart';
import 'package:mocktail/mocktail.dart';

import '../../keyboard/support/app_harness.dart';

class _Probe extends KeyboardFeature {
  KeyboardSession? session;

  @override
  KeyboardHooks attach(KeyboardSession s) {
    session = s;
    return const KeyboardHooks();
  }
}

const _romaji = KoshaSettings(
  languages: LanguageSettings(enabled: ['ja'], active: 'ja', layouts: {'ja': 'romaji_ja'}),
);

void main() {
  Future<(AppHarness, KeyboardSession)> boot(
    WidgetTester tester,
    KoshaSettings settings, {
    EditorInfoMessage? info,
  }) async {
    final h = AppHarness(settings: settings);
    when(() => h.platform.listPacks()).thenAnswer((_) async => []);
    final probe = _Probe();
    await h.pump(tester, features: [createJapaneseFeature(), probe]);
    await h.focus(tester, info);
    return (h, probe.session!);
  }

  testWidgets('Japanese sets the composer', (tester) async {
    final (_, s) = await boot(tester, _romaji);
    expect(s.input.composer.value, isA<JapaneseComposer>());
  });

  testWidgets('English leaves the composer unset', (tester) async {
    final (_, s) = await boot(tester, const KoshaSettings());
    expect(s.input.composer.value, isNull);
  });

  testWidgets('romaji letters compose in the field; space shows the no-pack chip', (tester) async {
    final (h, s) = await boot(tester, _romaji);
    for (final ch in 'nihongo'.split('')) {
      s.input.onText(ch);
    }
    await tester.pump();
    expect(s.input.composerState.value.preedit, 'にほんご');
    s.input.onSpace();
    await tester.pump();
    expect(h.editor.debugView, contains('にほんご'));
    expect(s.stripChips.value.map((c) => c.id), contains('japanese.pack'));
  });

  testWidgets('no composer in password fields', (tester) async {
    final (h, s) = await boot(
      tester,
      _romaji,
      info: editorInfo(inputType: AndroidInputType.classText | AndroidInputType.textVariationPassword),
    );
    expect(s.input.composer.value, isA<JapaneseComposer>(), reason: 'set, but not active here');
    expect(s.input.composerActive, isFalse);
    s.input.onText('n');
    s.input.onText('i');
    await tester.pump();
    expect(h.editor.text, 'ni', reason: 'typed as plain letters in a password field');
  });
}
