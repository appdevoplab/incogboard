// SPDX-License-Identifier: GPL-3.0-or-later
//
// Settings → Model packs: the installed list, import errors, and delete with a confirmation.
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incogboard/src/app/l10n.dart';
import 'package:incogboard/src/app/packs/packs_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:incogboard/src/bridge/messages.g.dart';

import '../support/app_fakes.dart';

PackInfoMessage _translation() => PackInfoMessage(
  id: 'translate-en-es',
  kind: PackKind.translation,
  name: 'English → Spanish',
  version: 1,
  languages: const ['en', 'es'],
  sizeBytes: 110 * 1024 * 1024,
  engine: 'opus-mt-onnx',
  license: 'Apache-2.0',
);

PackInfoMessage _voice() => PackInfoMessage(
  id: 'voice-whisper-base',
  kind: PackKind.voice,
  name: 'Whisper base',
  version: 1,
  languages: const ['en', 'hi'],
  sizeBytes: 74 * 1024 * 1024,
  engine: 'sherpa-onnx-whisper',
  license: 'MIT',
);

void main() {
  testWidgets('lists voice and translation packs with sizes and licences', (tester) async {
    final f = AppFakes();
    when(() => f.platform.listPacks()).thenAnswer((_) async => [_voice(), _translation()]);
    await pumpWithServices(
      tester,
      f.services,
      const MaterialApp(localizationsDelegates: incogboardLocalizationsDelegates, home: PacksScreen()),
    );

    expect(find.text('Voice'), findsOneWidget);
    expect(find.text('Translation'), findsOneWidget);
    expect(find.text('Whisper base'), findsOneWidget);
    expect(find.text('English → Spanish'), findsOneWidget);
    expect(find.textContaining('Apache-2.0'), findsOneWidget);
    expect(find.textContaining('MIT'), findsOneWidget);
    expect(
      find.text('Packs are checked before they are installed. They contain data only, never code.'),
      findsOneWidget,
    );
  });

  testWidgets('an empty list says so for each kind', (tester) async {
    final f = AppFakes();
    when(() => f.platform.listPacks()).thenAnswer((_) async => const []);
    await pumpWithServices(
      tester,
      f.services,
      const MaterialApp(localizationsDelegates: incogboardLocalizationsDelegates, home: PacksScreen()),
    );
    expect(find.text('No voice packs installed'), findsOneWidget);
    expect(find.text('No translation packs installed'), findsOneWidget);
  });

  testWidgets('an import that fails says why, and nothing is installed', (tester) async {
    final f = AppFakes();
    when(() => f.platform.listPacks()).thenAnswer((_) async => const []);
    when(() => f.app.openDocument(any())).thenAnswer((_) async => 'content://downloads/pack.koshapack');
    when(() => f.app.importPack(any())).thenThrow(PlatformException(code: 'bad_signature'));
    await pumpWithServices(
      tester,
      f.services,
      const MaterialApp(localizationsDelegates: incogboardLocalizationsDelegates, home: PacksScreen()),
    );

    await tester.tap(find.text('Import a pack file'));
    await tester.pumpAndSettle();
    expect(find.text('This pack is not signed for IncogBoard, so nothing was installed.'), findsOneWidget);
    verifyNever(() => f.platform.notifySettingsChanged(any()));
  });

  testWidgets('a cancelled file picker changes nothing', (tester) async {
    final f = AppFakes();
    when(() => f.platform.listPacks()).thenAnswer((_) async => const []);
    when(() => f.app.openDocument(any())).thenAnswer((_) async => null);
    await pumpWithServices(
      tester,
      f.services,
      const MaterialApp(localizationsDelegates: incogboardLocalizationsDelegates, home: PacksScreen()),
    );

    await tester.tap(find.text('Import a pack file'));
    await tester.pumpAndSettle();
    verifyNever(() => f.app.importPack(any()));
  });

  testWidgets('delete asks first, then removes the pack and tells the keyboard', (tester) async {
    final f = AppFakes();
    when(() => f.platform.listPacks()).thenAnswer((_) async => [_translation()]);
    when(() => f.app.deletePack(any())).thenAnswer((_) async {});
    await pumpWithServices(
      tester,
      f.services,
      const MaterialApp(localizationsDelegates: incogboardLocalizationsDelegates, home: PacksScreen()),
    );

    await tester.tap(find.byTooltip('Delete English → Spanish'));
    await tester.pumpAndSettle();
    expect(find.text('Delete English → Spanish?'), findsOneWidget);
    verifyNever(() => f.app.deletePack(any()));

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    verify(() => f.app.deletePack('translate-en-es')).called(1);
    verify(() => f.platform.notifySettingsChanged(const ['data.packs'])).called(1);
  });

  testWidgets('cancelling the delete keeps the pack', (tester) async {
    final f = AppFakes();
    when(() => f.platform.listPacks()).thenAnswer((_) async => [_translation()]);
    await pumpWithServices(
      tester,
      f.services,
      const MaterialApp(localizationsDelegates: incogboardLocalizationsDelegates, home: PacksScreen()),
    );

    await tester.tap(find.byTooltip('Delete English → Spanish'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => f.app.deletePack(any()));
  });
}
