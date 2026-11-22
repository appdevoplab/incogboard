// SPDX-License-Identifier: GPL-3.0-or-later
import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:myna/src/features/translate/translate_controller.dart';
import 'package:myna/src/features/translate/translate_languages.dart';
import 'package:myna/src/features/translate/translate_panel.dart';
import 'package:myna/src/bridge/messages.g.dart';

const _debounce = Duration(milliseconds: 5);

/// Lets the debounce timer and the fake engine finish.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 30));

void main() {
  group('TranslateController', () {
    test('translates after the debounce, with the pair, and shows the result', () async {
      final calls = <(String, String, String)>[];
      final c = TranslateController(
        translate: (text, from, to) async {
          calls.add((text, from, to));
          return 'hola';
        },
        insert: (_) {},
        from: 'en',
        to: 'es',
        debounce: _debounce,
      );
      addTearDown(c.dispose);

      c.setSource('hello');
      expect(c.status, TranslateStatus.waiting);
      expect(calls, isEmpty, reason: 'not before the debounce');
      await settle();
      expect(calls, [('hello', 'en', 'es')]);
      expect(c.status, TranslateStatus.ready);
      expect(c.translation, 'hola');
      expect(c.canInsert, isTrue);
    });

    test('only the latest text counts: an older answer is dropped', () async {
      final slow = Completer<String>();
      var call = 0;
      final c = TranslateController(
        translate: (text, from, to) {
          call++;
          if (call == 1) return slow.future;
          return Future.value('second');
        },
        insert: (_) {},
        from: 'en',
        to: 'es',
        debounce: _debounce,
      );
      addTearDown(c.dispose);
      c.setSource('a');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      c.append('b');
      await settle();
      slow.complete('first');
      await settle();
      expect(c.translation, 'second');
    });

    test('a missing pack and an engine failure have their own states', () async {
      final noPack = TranslateController(
        translate: (_, _, _) async => throw PlatformException(code: 'no_pack'),
        insert: (_) {},
        from: 'en',
        to: 'hi',
        debounce: _debounce,
      );
      addTearDown(noPack.dispose);
      noPack.setSource('hi');
      await settle();
      expect(noPack.status, TranslateStatus.noPack);
      expect(noPack.canInsert, isFalse);

      final failed = TranslateController(
        translate: (_, _, _) async => throw PlatformException(code: 'failed'),
        insert: (_) {},
        from: 'en',
        to: 'es',
        debounce: _debounce,
      );
      addTearDown(failed.dispose);
      failed.setSource('hi');
      await settle();
      expect(failed.status, TranslateStatus.failed);
    });

    test('Insert commits the translation once and clears the source box', () async {
      final inserted = <String>[];
      final c = TranslateController(
        translate: (_, _, _) async => 'Dónde',
        insert: inserted.add,
        from: 'en',
        to: 'es',
        debounce: _debounce,
      );
      addTearDown(c.dispose);
      expect(c.insertTranslation(), isFalse, reason: 'nothing to insert yet');
      c.setSource('where');
      await settle();
      expect(c.insertTranslation(), isTrue);
      expect(inserted, ['Dónde']);
      expect(c.source, '');
      expect(c.translation, isNull);
      expect(c.insertTranslation(), isFalse);
    });

    test('backspace shortens the source by one character, and clearing returns to idle', () {
      final c = TranslateController(
        translate: (_, _, _) async => '',
        insert: (_) {},
        from: 'en',
        to: 'es',
        debounce: const Duration(hours: 1),
      );
      addTearDown(c.dispose);
      c
        ..append('a')
        ..append('é')
        ..backspace();
      expect(c.source, 'a');
      c
        ..backspace()
        ..backspace();
      expect(c.source, '');
      expect(c.status, TranslateStatus.idle);
    });
  });

  group('language pairs', () {
    test('every pair has English on one side and a supported language on the other', () {
      expect(isSupportedPair('en', 'es'), isTrue);
      expect(isSupportedPair('ru', 'en'), isTrue);
      expect(isSupportedPair('pt-BR', 'en'), isTrue);
      expect(isSupportedPair('en', 'pt-PT'), isTrue);
      expect(isSupportedPair('es', 'fr'), isFalse, reason: 'no pack between two other languages');
      expect(isSupportedPair('en', 'en'), isFalse);
      expect(isSupportedPair('en', 'ar'), isFalse);
    });

    test('Portuguese variants share the pack; installed packs give pair keys', () {
      expect(pairKey('en', 'pt-BR'), 'en>pt');
      expect(pairKey('pt-PT', 'en'), 'pt>en');
      final installed = installedPairKeys([
        PackInfoMessage(
          id: 'translate-en-pt',
          kind: PackKind.translation,
          name: 'English → Portuguese',
          version: 1,
          languages: const ['en', 'pt'],
          sizeBytes: 1,
          engine: 'opus-mt-onnx',
          license: 'Apache-2.0',
        ),
        PackInfoMessage(
          id: 'voice-hi',
          kind: PackKind.voice,
          name: 'Hindi voice',
          version: 1,
          languages: const ['hi'],
          sizeBytes: 1,
          engine: 'whisper',
          license: 'MIT',
        ),
      ]);
      expect(installed, {'en>pt'});
    });
  });

  group('source tail', () {
    test('short text is shown whole; long text keeps its end', () {
      expect(sourceTail('where is'), 'where is');
      final long = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJ';
      final tail = sourceTail(long);
      expect(tail.length, sourceTailChars);
      expect(tail.startsWith('…'), isTrue);
      expect(tail.endsWith('0123456789ABCDEFGHIJ'), isTrue);
    });
  });
}
