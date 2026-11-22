// SPDX-License-Identifier: GPL-3.0-or-later
//
// Light and dark builds of every settings screen, at font scale 1.3, without exceptions.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:kosha/src/app/l10n.dart';
import 'package:kosha/src/app/about/about_screen.dart';
import 'package:kosha/src/app/app_services.dart';
import 'package:kosha/src/app/screens/feel_screen.dart';
import 'package:kosha/src/app/screens/home_screen.dart';
import 'package:kosha/src/app/screens/languages_screen.dart';
import 'package:kosha/src/app/screens/panels_screen.dart';
import 'package:kosha/src/app/screens/typing_screen.dart';
import 'package:kosha/src/app/screens/voice_screen.dart';
import 'package:kosha/src/app/shell/kosha_theme.dart';
import 'package:kosha/src/settings/kosha_settings.dart';

import 'support/app_fakes.dart';

const Map<String, Widget Function()> _screens = {
  'home': HomeScreen.new,
  'languages': LanguagesScreen.new,
  'typing': TypingScreen.new,
  'feel': FeelScreen.new,
  'panels': PanelsScreen.new,
  'voice': VoiceScreen.new,
  'about': AboutScreen.new,
};

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    for (final entry in _screens.entries) {
      testWidgets('${entry.key} builds in ${brightness.name} at font scale 1.3', (tester) async {
        final fakes = AppFakes(settings: const KoshaSettings(languages: LanguageSettings(onboardingDone: true)));
        await tester.pumpWidget(
          AppScope(
            services: fakes.services,
            child: MaterialApp(
              localizationsDelegates: koshaLocalizationsDelegates,
              theme: koshaThemeData(koshaBrandScheme(Brightness.light)),
              darkTheme: koshaThemeData(koshaBrandScheme(Brightness.dark)),
              themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: entry.value(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(Scaffold), findsWidgets);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('the brand scheme keeps Kosha yellow and brown for emphasis', (tester) async {
    final light = koshaBrandScheme(Brightness.light);
    final dark = koshaBrandScheme(Brightness.dark);
    expect(light.tertiary, const Color(0xFF3E2723));
    expect(dark.brightness, Brightness.dark);
    expect(light.brightness, Brightness.light);
  });
}
