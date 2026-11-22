// SPDX-License-Identifier: GPL-3.0-or-later
//
// Every settings control writes through SettingsStore.update with the section that owns it, so
// the keyboard reloads the right section.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myna/src/app/screens/feel_screen.dart';
import 'package:myna/src/app/screens/languages_screen.dart';
import 'package:myna/src/app/screens/panels_screen.dart';
import 'package:myna/src/app/screens/typing_screen.dart';
import 'package:myna/src/app/screens/voice_screen.dart';
import 'package:myna/src/settings/myna_settings.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_fakes.dart';

Future<AppFakes> _pump(WidgetTester tester, Widget screen, {MynaSettings settings = const MynaSettings()}) async {
  final fakes = AppFakes(settings: settings);
  await pumpWithServices(tester, fakes.services, MaterialApp(home: screen));
  return fakes;
}

void main() {
  testWidgets('a typing switch writes the typing section', (tester) async {
    final fakes = await _pump(tester, const TypingScreen());
    await tapText(tester, 'Autocorrect');
    expect(capturedUpdate(fakes.store, SettingsSection.typing)(const MynaSettings()).typing.autoCorrect, isFalse);
  });

  testWidgets('a swipe switch writes the swipe section', (tester) async {
    final fakes = await _pump(tester, const TypingScreen());
    await tapText(tester, 'Show trail');
    expect(capturedUpdate(fakes.store, SettingsSection.swipe)(const MynaSettings()).swipe.showTrail, isFalse);
  });

  testWidgets('the long-press delay slider writes the typing section on release', (tester) async {
    final fakes = await _pump(tester, const TypingScreen());
    final slider = find.byType(Slider).first;
    await tester.scrollUntilVisible(slider, 200, scrollable: find.byType(Scrollable).first);
    await tester.drag(slider, const Offset(60, 0));
    await tester.pumpAndSettle();
    final update = capturedUpdate(fakes.store, SettingsSection.typing);
    expect(update(const MynaSettings()).typing.longPressDelayMs, greaterThan(300));
  });

  testWidgets('a feel switch writes the feedback section', (tester) async {
    final fakes = await _pump(tester, const FeelScreen());
    await tapText(tester, 'Haptic feedback');
    expect(capturedUpdate(fakes.store, SettingsSection.feedback)(const MynaSettings()).feedback.haptics, isFalse);
  });

  testWidgets('the one-handed control writes the modes section', (tester) async {
    final fakes = await _pump(tester, const FeelScreen());
    await tapText(tester, 'Left');
    final update = capturedUpdate(fakes.store, SettingsSection.modes);
    expect(update(const MynaSettings()).modes.oneHanded, OneHandedMode.left);
  });

  testWidgets('the floating switch writes the modes section', (tester) async {
    final fakes = await _pump(tester, const FeelScreen());
    await tapText(tester, 'Floating keyboard');
    final update = capturedUpdate(fakes.store, SettingsSection.modes);
    expect(update(const MynaSettings()).modes.floating, isTrue);
  });

  testWidgets('the portrait height slider writes the appearance section', (tester) async {
    final fakes = await _pump(tester, const FeelScreen());
    // Sliders in order: haptic strength, portrait height, landscape height.
    final slider = find.byType(Slider).at(1);
    await tester.scrollUntilVisible(slider, 200, scrollable: find.byType(Scrollable).first);
    await tester.drag(slider, const Offset(-300, 0));
    await tester.pumpAndSettle();
    final update = capturedUpdate(fakes.store, SettingsSection.appearance);
    expect(update(const MynaSettings()).appearance.heightScale, lessThan(1.0));
  });

  testWidgets('a clipboard switch writes the clipboard section', (tester) async {
    final fakes = await _pump(tester, const PanelsScreen());
    await tapText(tester, 'Clipboard history');
    expect(capturedUpdate(fakes.store, SettingsSection.clipboard)(const MynaSettings()).clipboard.history, isFalse);
  });

  testWidgets('choosing an expiry writes the clipboard section', (tester) async {
    final fakes = await _pump(tester, const PanelsScreen());
    await tapText(tester, '1 day');
    final update = capturedUpdate(fakes.store, SettingsSection.clipboard);
    expect(update(const MynaSettings()).clipboard.expiryMinutes, 1440);
  });

  testWidgets('the emoji switch writes the typing section', (tester) async {
    final fakes = await _pump(tester, const PanelsScreen());
    await tapText(tester, 'Emoji suggestions');
    final update = capturedUpdate(fakes.store, SettingsSection.typing);
    expect(update(const MynaSettings()).typing.emojiSuggestions, isFalse);
  });

  testWidgets('the multilingual switch writes the languages section', (tester) async {
    final fakes = await _pump(tester, const LanguagesScreen());
    await tapText(tester, 'Multilingual typing');
    final update = capturedUpdate(fakes.store, SettingsSection.languages);
    expect(update(const MynaSettings()).languages.multilingual, isFalse);
  });

  testWidgets('the voice screen shows the stored values and writes nothing', (tester) async {
    final fakes = await _pump(tester, const VoiceScreen());
    expect(find.text('Offline voice arrives in a later update'), findsOneWidget);
    expect(find.text('Automatic'), findsOneWidget);
    expect(find.text('On'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);
    verifyNever(() => fakes.store.update(any(), sections: any(named: 'sections')));
  });
}
