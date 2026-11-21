// SPDX-License-Identifier: GPL-3.0-or-later
//
// Gallery and editor widgets: selecting a preset writes the theme id, the appearance controls work,
// deleting a selected custom theme falls back, and the editor's preview, save and discard flows work.
// Custom themes and layouts are read for real, so the tests wait outside the fake clock.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myna/src/app/app_services.dart';
import 'package:myna/src/app/common/settings_widgets.dart';
import 'package:myna/src/app/themes/theme_editor_screen.dart';
import 'package:myna/src/app/themes/theme_gallery_screen.dart';
import 'package:myna/src/bridge/messages.g.dart';
import 'package:myna/src/core/secure_blob_store.dart';
import 'package:myna/src/keyboard/preview/keyboard_preview.dart';
import 'package:myna/src/settings/myna_settings.dart';
import 'package:myna/src/settings/settings_store.dart';
import 'package:myna/src/theme/custom/custom_theme_store.dart';
import 'package:myna/src/theme/presets.dart';
import 'package:myna/src/theme/theme_spec.dart';

import '../../theme/theme_test_support.dart';

class _MockPlatform extends Mock implements PlatformHostApi {}

class _MockApp extends Mock implements AppHostApi {}

const String _uuid = '1b4e28ba-2fa1-41d2-883f-0016d3cca427';

late Directory _dataDir;
late _MockPlatform _platform;
late AppServices _services;

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();
  }
}

void _setUpServices({List<int>? palettes}) {
  _dataDir = Directory.systemTemp.createTempSync('myna_theme_screens_');
  _platform = _MockPlatform();
  when(() => _platform.getDataDirectory()).thenAnswer((_) async => _dataDir.path);
  when(() => _platform.getSystemColors())
      .thenAnswer((_) async => palettes == null ? null : SystemColorsMessage(palettes: palettes, isNightMode: false));
  _services = AppServices(
    settings: SettingsStore.memory(),
    secureStore: InMemorySecureBlobStore(),
    platform: _platform,
    app: _MockApp(),
  );
}

void _tearDownServices() {
  if (_dataDir.existsSync()) _dataDir.deleteSync(recursive: true);
}

Future<void> _pumpGallery(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AppScope(services: _services, child: const ThemeGalleryScreen()),
    ),
  );
  await _settle(tester);
}

/// Opens the editor from a button, so that saving and leaving pop a real route.
Future<void> _pumpEditor(WidgetTester tester, {String? themeId}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AppScope(
        services: _services,
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => ThemeEditorScreen(themeId: themeId))),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await _settle(tester);
}

void main() {
  group('theme gallery', () {
    setUp(() => _setUpServices());
    tearDown(_tearDownServices);

    testWidgets('shows the presets, My themes and the Create card', (tester) async {
      await _pumpGallery(tester);
      for (final preset in ThemePresets.all) {
        expect(find.text(preset.name), findsWidgets, reason: preset.name);
      }
      expect(find.text('My themes'), findsOneWidget);
      expect(find.text('Create theme'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('tapping a preset writes its id', (tester) async {
      await _pumpGallery(tester);
      await tester.tap(find.text('Lavender'));
      await _settle(tester);
      expect(_services.settings.value.appearance.themeId, 'lavender');
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('dark mode, pure black and contrast write the appearance', (tester) async {
      await _pumpGallery(tester);
      await tester.tap(find.text('Dark'));
      await _settle(tester);
      expect(_services.settings.value.appearance.darkMode, DarkModePreference.dark);

      await tester.tap(find.text('Pure black'));
      await _settle(tester);
      expect(_services.settings.value.appearance.pureBlack, isTrue);

      await tester.tap(find.text('High'));
      await _settle(tester);
      expect(_services.settings.value.appearance.contrast, ContrastPreference.high);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the wallpaper note appears only when system colours exist', (tester) async {
      await _pumpGallery(tester);
      expect(find.text('Myna Dynamic follows your wallpaper'), findsNothing);
      await tester.pumpWidget(const SizedBox());

      _tearDownServices();
      _setUpServices(palettes: syntheticPalettes());
      await _pumpGallery(tester);
      expect(find.text('Myna Dynamic follows your wallpaper'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('deleting the selected custom theme asks first and falls back to Myna Dynamic', (tester) async {
      final id = CustomThemeIds.idFor(_uuid);
      final store = CustomThemeStore('${_dataDir.path}/themes');
      await tester.runAsync(() => store.write(ThemeSpec(id: id, name: 'Saved look')));
      await tester.runAsync(
        () => _services.settings.update(
          (c) => c.copyWith(appearance: c.appearance.copyWith(themeId: id)),
          sections: const ['appearance'],
        ),
      );

      await _pumpGallery(tester);
      expect(find.text('Saved look'), findsWidgets);

      await tester.tap(find.byTooltip('Options for Saved look'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete "Saved look"?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await _settle(tester);
      expect(File('${_dataDir.path}/themes/$_uuid.json').existsSync(), isFalse);
      expect(_services.settings.value.appearance.themeId, ThemePresets.mynaDynamic.id);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('theme editor', () {
    setUp(() => _setUpServices());
    tearDown(_tearDownServices);

    testWidgets('changing the seed colour updates the pinned preview', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpEditor(tester);
      final before = tester.widget<KeyboardPreview>(find.byType(KeyboardPreview)).theme.letterKey.fill;

      await tester.tap(find.bySemanticsLabel('#D6336C'));
      await _settle(tester);
      final after = tester.widget<KeyboardPreview>(find.byType(KeyboardPreview)).theme.letterKey.fill;
      expect(after, isNot(before));
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    });

    testWidgets('saving writes the theme file, selects it and bumps the revision', (tester) async {
      await _pumpEditor(tester);
      expect(find.text('New theme'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Ocean test');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await _settle(tester);

      final files = Directory('${_dataDir.path}/themes')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'));
      expect(files, hasLength(1));
      final saved = await CustomThemeStore('${_dataDir.path}/themes').list();
      expect(saved.single.name, 'Ocean test');

      final appearance = _services.settings.value.appearance;
      expect(appearance.themeId, startsWith('custom:'));
      expect(appearance.customThemeRevision, 1);
      expect(find.text('New theme'), findsNothing, reason: 'the editor closes after saving');
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('leaving with unsaved changes asks first, and Keep editing stays', (tester) async {
      await _pumpEditor(tester);
      await tester.enterText(find.byType(TextField).first, 'Half done');
      await tester.pump();

      await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('New theme'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('editing an existing theme loads its name', (tester) async {
      final store = CustomThemeStore('${_dataDir.path}/themes');
      await store.write(ThemeSpec(id: CustomThemeIds.idFor(_uuid), name: 'Stored one'));
      await _settle(tester);

      await _pumpEditor(tester, themeId: CustomThemeIds.idFor(_uuid));
      expect(find.text('Edit theme'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, 'Stored one');
      await tester.pumpWidget(const SizedBox());
    });
  });
}
