// SPDX-License-Identifier: GPL-3.0-or-later
//
// The translate panel and its pair picker inside the real keyboard view, with the fake editor and host.
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incogboard/src/bridge/messages.g.dart';
import 'package:incogboard/src/core/input_field_info.dart';
import 'package:incogboard/src/features/translate/translate_feature.dart';
import 'package:incogboard/src/features/translate/translate_panel.dart';
import 'package:incogboard/src/keyboard/keyboard_app.dart';
import 'package:incogboard/src/keyboard/keyboard_session.dart';
import 'package:incogboard/src/settings/incogboard_settings.dart';

import '../../keyboard/support/app_harness.dart';

/// Captures the session so tests can reach the input controller and the open panel.
class _Probe extends KeyboardFeature {
  KeyboardSession? session;

  @override
  KeyboardHooks attach(KeyboardSession s) {
    session = s;
    return const KeyboardHooks();
  }
}

/// Settings that keep the strip on the toolbar, with translation on for en -> es.
IncogBoardSettings _settings({bool enabled = true, String from = 'en', String to = 'es'}) => IncogBoardSettings(
  typing: const TypingSettings(nextWordPrediction: false),
  translate: TranslateSettings(enabled: enabled, from: from, to: to),
);

Future<(AppHarness, _Probe)> boot(
  WidgetTester tester, {
  IncogBoardSettings? settings,
  EditorInfoMessage? field,
  String text = '',
}) async {
  final h = AppHarness(settings: settings ?? _settings(), text: text);
  final probe = _Probe();
  await h.pump(tester, features: [probe, createTranslateFeature()]);
  when(() => h.platform.listPacks()).thenAnswer((_) async => const []);
  when(() => h.host.releaseTranslator()).thenAnswer((_) async {});
  when(() => h.host.translate(any(), any(), any()))
      .thenAnswer((inv) async => 'EN:${inv.positionalArguments[0] as String}');
  await h.focus(tester, field);
  return (h, probe);
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 20));
}

/// Scrolls the picker until [finder] is on screen, then taps it.
Future<void> tapScrolling(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tap(tester, finder);
}

/// Lets the debounce (300 ms) and the fake engine finish.
Future<void> waitForTranslation(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();
}

void main() {
  group('translate panel', () {
    testWidgets('opens from the toolbar, translates the typed keys, and Insert commits only the translation', (
      tester,
    ) async {
      final (h, probe) = await boot(tester);
      await tap(tester, find.bySemanticsLabel('Translate'));
      expect(probe.session!.panel.value, isA<TranslatePanel>());

      final redirect = probe.session!.input.redirect.value!;
      redirect
        ..onText('w')
        ..onText('here');
      await waitForTranslation(tester);
      expect(find.text('EN:where'), findsOneWidget);

      await tap(tester, find.bySemanticsLabel('Insert translation'));
      expect(h.editor.text, 'EN:where', reason: 'the typed source never reaches the app');
      expect(find.text('Type to translate'), findsOneWidget, reason: 'the source box is cleared');
      expect(h.predictor.committed, isEmpty, reason: 'nothing is learned from the panel');
    });

    testWidgets('the close button returns to the normal strip and keys', (tester) async {
      final (h, probe) = await boot(tester);
      await tap(tester, find.bySemanticsLabel('Translate'));
      expect(probe.session!.panel.value, isA<TranslatePanel>());
      await tap(tester, find.bySemanticsLabel('Close translation'));
      expect(probe.session!.panel.value, isNull);
      expect(probe.session!.input.redirect.value, isNull, reason: 'keys type into the app again');
      verify(() => h.host.releaseTranslator()).called(1);
    });

    testWidgets('Enter inserts the translation too, and backspace edits the source', (tester) async {
      final (h, probe) = await boot(tester);
      await tap(tester, find.bySemanticsLabel('Translate'));
      final redirect = probe.session!.input.redirect.value!;
      redirect
        ..onText('x')
        ..onText('yz')
        ..onBackspace();
      await waitForTranslation(tester);
      expect(find.text('EN:xy'), findsOneWidget);
      redirect.onEnter();
      expect(h.editor.text, 'EN:xy');
    });

    testWidgets('Insert puts a space between existing text and the translation', (tester) async {
      final (h, probe) = await boot(tester, text: 'where is the station');
      await tap(tester, find.bySemanticsLabel('Translate'));
      probe.session!.input.redirect.value!.onText('hi');
      await waitForTranslation(tester);
      await tap(tester, find.bySemanticsLabel('Insert translation'));
      expect(h.editor.text, 'where is the station EN:hi');
    });

    testWidgets('a missing pack says which pack to get, privately, and Get opens Model packs', (tester) async {
      final (h, probe) = await boot(tester);
      when(() => h.host.translate(any(), any(), any()))
          .thenAnswer((_) async => throw PlatformException(code: 'no_pack'));
      await tap(tester, find.bySemanticsLabel('Translate'));
      probe.session!.input.redirect.value!.onText('hi');
      await waitForTranslation(tester);
      expect(find.textContaining('No English → Spanish pack yet'), findsOneWidget);
      expect(find.textContaining('your browser downloads it'), findsOneWidget);
      await tap(tester, find.bySemanticsLabel('Get the translation pack'));
      verify(() => h.host.openSettings('packs')).called(1);
    });

    testWidgets('a pair whose pack is not published says so and offers no Get', (tester) async {
      final (h, probe) = await boot(tester, settings: _settings(to: 'de'));
      when(() => h.host.translate(any(), any(), any()))
          .thenAnswer((_) async => throw PlatformException(code: 'no_pack'));
      await tap(tester, find.bySemanticsLabel('Translate'));
      probe.session!.input.redirect.value!.onText('hi');
      await waitForTranslation(tester);
      expect(find.textContaining('not published yet'), findsOneWidget);
      expect(find.bySemanticsLabel('Get the translation pack'), findsNothing);
    });

    testWidgets('the pair picker lists pairs, installed first, and one tap picks and saves a pair', (tester) async {
      final (h, probe) = await boot(tester);
      when(() => h.platform.listPacks()).thenAnswer(
        (_) async => [
          PackInfoMessage(
            id: 'translate-en-fr',
            kind: PackKind.translation,
            name: 'English → French',
            version: 1,
            languages: const ['en', 'fr'],
            sizeBytes: 100,
            engine: 'opus-mt-onnx',
            license: 'Apache-2.0',
          ),
        ],
      );
      await tap(tester, find.bySemanticsLabel('Translate'));
      await tap(tester, find.bySemanticsLabel('Language pair English to Spanish. Change languages'));
      await tester.pump();
      final french = find.bySemanticsLabel('English to French, pack installed');
      final spanish = find.bySemanticsLabel('English to Spanish, pack not installed, selected');
      expect(french, findsOneWidget, reason: 'the installed pair is marked');
      expect(spanish, findsOneWidget, reason: 'the current pair is marked');
      expect(tester.getTopLeft(french).dy, lessThan(tester.getTopLeft(spanish).dy), reason: 'installed first');
      expect(find.text('English → Français'), findsOneWidget, reason: 'rows use the language\'s own name');

      await tapScrolling(tester, french);
      await tester.pump(const Duration(milliseconds: 20));
      expect(h.store.value.translate.to, 'fr');
      expect(h.store.value.translate.from, 'en');
      expect(find.text('EN → FR'), findsOneWidget, reason: 'the translate panel is back with the new pair');
      expect(probe.session!.panel.value, isA<TranslatePanel>());
    });

    testWidgets('the picker turns direction, Get only shows for published packs and opens Model packs', (tester) async {
      final (h, _) = await boot(tester);
      await tap(tester, find.bySemanticsLabel('Translate'));
      await tap(tester, find.bySemanticsLabel('Language pair English to Spanish. Change languages'));
      await tester.pump();
      expect(find.bySemanticsLabel('Get the English to German pack'), findsNothing, reason: 'not published');
      expect(find.bySemanticsLabel('English to German, pack not published yet'), findsOneWidget);
      await tapScrolling(tester, find.bySemanticsLabel('Get the English to Spanish pack'));
      verify(() => h.host.openSettings('packs')).called(1);

      await tap(tester, find.bySemanticsLabel('To English'));
      await tapScrolling(tester, find.bySemanticsLabel('German to English, pack not published yet'));
      await tester.pump(const Duration(milliseconds: 20));
      expect(h.store.value.translate.from, 'de');
      expect(h.store.value.translate.to, 'en');
    });

    testWidgets('nothing opens while translation is off', (tester) async {
      await boot(tester, settings: _settings(enabled: false));
      expect(find.bySemanticsLabel('Translate'), findsNothing);
    });

    testWidgets('no translate panel opens in a password field', (tester) async {
      final (_, probe) = await boot(
        tester,
        field: editorInfo(inputType: AndroidInputType.classText | AndroidInputType.textVariationPassword),
      );
      expect(probe.session!.input.currentField.isSensitive, isTrue);
      probe.session!.openPanel(
        TranslatePanel(session: probe.session!, from: 'en', to: 'es', installedPairs: () async => const {}),
      );
      expect(probe.session!.panel.value, isNull);
    });
  });
}
