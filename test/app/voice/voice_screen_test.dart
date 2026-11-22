// SPDX-License-Identifier: GPL-3.0-or-later
//
// Voice settings: the switch, the voice pack choice (Automatic or an installed voice pack), automatic language
// detection and the privacy line. Writes go through SettingsStore.update with the 'voice' section.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myna/src/app/screens/voice_screen.dart';
import 'package:myna/src/bridge/messages.g.dart';
import 'package:myna/src/settings/myna_settings.dart';

import '../support/app_fakes.dart';

PackInfoMessage _pack(String id, PackKind kind, String name) => PackInfoMessage(
  id: id,
  kind: kind,
  name: name,
  version: 1,
  languages: const ['en'],
  sizeBytes: 60 * 1024 * 1024,
  engine: 'sherpa-onnx-whisper',
  license: 'MIT',
);

/// The settings a write produced: applies the captured change to [base].
MynaSettings _applied(AppFakes fakes, {MynaSettings base = const MynaSettings()}) {
  final change =
      verify(() => fakes.store.update(captureAny(), sections: any(named: 'sections'))).captured.last
          as MynaSettings Function(MynaSettings);
  return change(base);
}

void main() {
  setUpAll(() {
    registerFallbackValue((MynaSettings s) => s);
    registerFallbackValue(<String>[]);
  });

  late AppFakes fakes;

  setUp(() {
    fakes = AppFakes();
    when(() => fakes.platform.listPacks()).thenAnswer(
      (_) async => [
        _pack('voice-whisper-base', PackKind.voice, 'Whisper base'),
        _pack('voice-whisper-small', PackKind.voice, 'Whisper small'),
        _pack('translate-en-es', PackKind.translation, 'English to Spanish'),
      ],
    );
  });

  Future<void> pump(WidgetTester tester, MynaSettings settings) async {
    fakes = AppFakes(settings: settings);
    when(() => fakes.platform.listPacks()).thenAnswer(
      (_) async => [
        _pack('voice-whisper-base', PackKind.voice, 'Whisper base'),
        _pack('voice-whisper-small', PackKind.voice, 'Whisper small'),
        _pack('translate-en-es', PackKind.translation, 'English to Spanish'),
      ],
    );
    await pumpWithServices(tester, fakes.services, const MaterialApp(home: VoiceScreen()));
  }

  testWidgets('shows the switch, Automatic pack, language detection and the privacy line', (tester) async {
    await pump(tester, const MynaSettings());

    expect(find.text('Voice typing'), findsOneWidget);
    expect(find.text('Voice pack'), findsOneWidget);
    expect(find.text('Automatic'), findsOneWidget);
    expect(find.text('Detect language automatically'), findsOneWidget);
    expect(find.text('Audio stays on this phone and is never saved.'), findsOneWidget);
  });

  testWidgets('turning voice typing off writes the voice section', (tester) async {
    await pump(tester, const MynaSettings());

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final written = _applied(fakes);
    expect(written.voice.enabled, isFalse);
  });

  testWidgets('a selected pack shows its name', (tester) async {
    await pump(tester, const MynaSettings(voice: VoiceSettings(modelId: 'voice-whisper-small')));

    expect(find.text('Whisper small'), findsOneWidget);
    expect(find.text('Automatic'), findsNothing);
  });

  testWidgets('choosing a voice pack lists only voice packs and writes the id', (tester) async {
    await pump(tester, const MynaSettings());

    await tester.tap(find.text('Voice pack'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Whisper base'), findsOneWidget);
    expect(find.textContaining('Whisper small'), findsOneWidget);
    expect(find.textContaining('English to Spanish'), findsNothing);

    await tester.tap(find.textContaining('Whisper small'));
    await tester.pumpAndSettle();

    expect(_applied(fakes).voice.modelId, 'voice-whisper-small');
  });

  testWidgets('automatic detection switch writes autoDetectLanguage', (tester) async {
    await pump(tester, const MynaSettings());

    await tester.tap(find.widgetWithText(SwitchListTile, 'Detect language automatically'));
    await tester.pumpAndSettle();

    expect(_applied(fakes).voice.autoDetectLanguage, isTrue);
  });
}
