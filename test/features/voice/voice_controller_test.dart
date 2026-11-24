// SPDX-License-Identifier: GPL-3.0-or-later
//
// The mic panel's flow, with a mocked ImeHostApi and a fake editor: permission denied, no model, busy,
// partial then final text, stop, cancel, language cycling and disposal.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incogboard/src/bridge/input_sink.dart';
import 'package:incogboard/src/bridge/messages.g.dart';
import 'package:incogboard/src/features/voice/voice_controller.dart';

import '../../keyboard/support/app_harness.dart';
import '../../support/fake_editor.dart';

/// The text side of a session, backed by [editor] (the same fake the assertions read).
class _Sink implements VoiceTextSink {
  _Sink(this._editor);

  final FakeEditor _editor;

  @override
  InputSink get editor => _editor;

  @override
  void finishComposing() {}

  @override
  void resyncAfterExternalEdit() {}
}

Future<void> _settle() async {
  for (var i = 0; i < 6; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(() {
    registerKeyboardFallbacks();
    registerFallbackValue(VoiceRequestMessage(packId: '', autoDetect: false));
  });

  late MockImeHost host;
  late StreamController<VoiceEventMessage> events;
  late FakeEditor editor;
  late VoiceController controller;
  late List<VoiceRequestMessage> requests;
  var finished = 0;

  VoiceController make({
    bool enabled = true,
    List<String> languages = const ['en', 'pt-BR'],
    bool autoDetect = false,
    String packId = '',
  }) {
    final c = VoiceController(
      host: host,
      events: events.stream,
      text: _Sink(editor),
      packId: packId,
      enabled: enabled,
      languages: languages,
      defaultLanguage: languages.first,
      autoDetect: autoDetect,
    );
    c.onFinished = () => finished++;
    return c;
  }

  setUp(() {
    host = MockImeHost();
    events = StreamController<VoiceEventMessage>.broadcast(sync: true);
    editor = FakeEditor(text: '');
    finished = 0;
    requests = [];
    when(() => host.hasMicPermission()).thenAnswer((_) async => true);
    when(() => host.requestMicPermission()).thenAnswer((_) async => true);
    when(() => host.stopVoice()).thenAnswer((_) async {});
    when(() => host.cancelVoice()).thenAnswer((_) async {});
    when(() => host.startVoice(any())).thenAnswer((invocation) async {
      requests.add(invocation.positionalArguments.first as VoiceRequestMessage);
      return VoiceStartStatus.started;
    });
    // A placeholder so that tearDown is safe before a test assigns its own controller. It is disposed at once,
    // so it does not also hear the events meant for the test's controller.
    controller = make()..dispose();
  });

  tearDown(() async {
    controller.dispose();
    await events.close();
  });

  test('text rules: a space before a new utterance, and capitals at a sentence start', () {
    expect(VoiceText.utteranceAt(null).prefix, '');
    expect(VoiceText.utteranceAt(null).capitalise, isTrue);
    expect(VoiceText.utteranceAt('').capitalise, isTrue);
    expect(VoiceText.utteranceAt('Hello').prefix, ' ');
    expect(VoiceText.utteranceAt('Hello').capitalise, isFalse);
    expect(VoiceText.utteranceAt('Hello. ').prefix, '');
    expect(VoiceText.utteranceAt('Hello.').prefix, ' ');
    expect(VoiceText.utteranceAt('Hello.').capitalise, isTrue);
    expect(VoiceText.utteranceAt('Done!  ').capitalise, isTrue);
    expect(VoiceText.format('  turn on the light ', capitalise: true), 'Turn on the light');
    expect(VoiceText.format('turn on', capitalise: false), 'turn on');
    expect(VoiceText.format('   ', capitalise: true), '');
  });

  test('permission denied: never starts voice and says so', () async {
    when(() => host.hasMicPermission()).thenAnswer((_) async => false);
    when(() => host.requestMicPermission()).thenAnswer((_) async => false);
    controller = make();
    await controller.begin();
    expect(controller.phase, VoicePhase.noPermission);
    expect(requests, isEmpty);
  });

  test('permission is asked for once and granted: starts listening', () async {
    when(() => host.hasMicPermission()).thenAnswer((_) async => false);
    controller = make();
    await controller.begin();
    verify(() => host.requestMicPermission()).called(1);
    expect(controller.phase, VoicePhase.listening);
  });

  test('no voice pack: the panel says so', () async {
    when(() => host.startVoice(any())).thenAnswer((_) async => VoiceStartStatus.noModel);
    controller = make();
    await controller.begin();
    expect(controller.phase, VoicePhase.noModel);
  });

  test('busy microphone and a failed start both leave a message on the panel', () async {
    when(() => host.startVoice(any())).thenAnswer((_) async => VoiceStartStatus.busy);
    controller = make();
    await controller.begin();
    expect(controller.phase, VoicePhase.busy);

    when(() => host.startVoice(any())).thenAnswer((_) async => VoiceStartStatus.failed);
    final again = make();
    await again.begin();
    expect(again.phase, VoicePhase.failed);
    again.dispose();
    controller = make();
  });

  test('a request names the language, or sends none for auto-detect', () async {
    controller = make(languages: ['hi', 'en']);
    await controller.begin();
    expect(requests.single.language, 'hi');
    expect(requests.single.autoDetect, isFalse);

    controller.dispose();
    controller = make(languages: ['hi', 'en'], autoDetect: true, packId: 'voice-whisper-base');
    await controller.begin();
    expect(requests.last.language, isNull);
    expect(requests.last.autoDetect, isTrue);
    expect(requests.last.packId, 'voice-whisper-base');
  });

  test('partial text is composing text; final text is committed with a space', () async {
    editor = FakeEditor(text: 'Hello');
    controller = make();
    await controller.begin();

    events.add(VoiceEventMessage(kind: VoiceEventKind.partial, level: 0, text: 'turn on'));
    await _settle();
    expect(editor.text, 'Hello turn on');
    expect(editor.composing, ' turn on');
    expect(controller.partial, 'turn on');

    events.add(VoiceEventMessage(kind: VoiceEventKind.finalText, level: 0, text: 'turn on the light'));
    await _settle();
    expect(editor.text, 'Hello turn on the light');
    expect(editor.composing, isNull);
    expect(controller.partial, '');
    expect(controller.phase, VoicePhase.listening);
  });

  test('a final at a sentence start is capitalised', () async {
    controller = make();
    await controller.begin();
    events.add(VoiceEventMessage(kind: VoiceEventKind.finalText, level: 0, text: 'good morning'));
    await _settle();
    expect(editor.text, 'Good morning');
  });

  test('level events update the level while listening', () async {
    controller = make();
    await controller.begin();
    events.add(VoiceEventMessage(kind: VoiceEventKind.level, level: 0.7));
    expect(controller.level, 0.7);
  });

  test('stop keeps the text, then finishes and closes the panel', () async {
    controller = make();
    await controller.begin();
    controller.stop();
    verify(() => host.stopVoice()).called(1);
    expect(controller.phase, VoicePhase.stopping);
    events.add(VoiceEventMessage(kind: VoiceEventKind.finalText, level: 0, text: 'ok'));
    events.add(VoiceEventMessage(kind: VoiceEventKind.stopped, level: 0));
    await _settle();
    expect(controller.phase, VoicePhase.finished);
    expect(finished, 1);
    expect(editor.text, 'Ok');
  });

  test('cancel removes the partial text and never commits it', () async {
    controller = make();
    await controller.begin();
    events.add(VoiceEventMessage(kind: VoiceEventKind.partial, level: 0, text: 'maybe this'));
    await _settle();
    expect(editor.text, 'Maybe this');

    controller.cancel();
    verify(() => host.cancelVoice()).called(1);
    events.add(VoiceEventMessage(kind: VoiceEventKind.stopped, level: 0));
    await _settle();
    expect(editor.text, '');
    expect(controller.phase, VoicePhase.finished);
    expect(finished, 1);
  });

  test('language cycles Auto, then each enabled language', () async {
    controller = make(languages: ['en', 'pt-BR']);
    expect(controller.languageChoice, 'en');
    controller.cycleLanguage();
    expect(controller.languageChoice, 'pt-BR');
    controller.cycleLanguage();
    expect(controller.languageChoice, isNull);
    expect(controller.autoDetect, isTrue);
    controller.cycleLanguage();
    expect(controller.languageChoice, 'en');
  });

  test('changing language while listening restarts in the new language after the stop', () async {
    controller = make(languages: ['en', 'pt-BR']);
    await controller.begin();
    expect(requests, hasLength(1));

    controller.cycleLanguage();
    verify(() => host.cancelVoice()).called(1);
    expect(controller.phase, VoicePhase.cancelling);

    events.add(VoiceEventMessage(kind: VoiceEventKind.stopped, level: 0));
    await _settle();
    expect(requests, hasLength(2));
    expect(requests.last.language, 'pt-BR');
    expect(controller.phase, VoicePhase.listening);
  });

  test('a disabled voice setting shows its message and never starts', () async {
    controller = make(enabled: false);
    await controller.begin();
    expect(controller.phase, VoicePhase.disabled);
    expect(requests, isEmpty);
  });

  test('dispose cancels an active session and ignores later events', () async {
    controller = make();
    await controller.begin();
    controller.dispose();
    verify(() => host.cancelVoice()).called(1);
    events.add(VoiceEventMessage(kind: VoiceEventKind.partial, level: 0, text: 'late'));
    await _settle();
    expect(editor.text, '');
    controller = make();
  });
}
