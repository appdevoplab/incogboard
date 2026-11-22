// SPDX-License-Identifier: GPL-3.0-or-later
//
// Every route opens its screen; unknown routes go home; first run opens setup; the home tiles
// navigate.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosha/src/app/app.dart';
import 'package:kosha/src/app/routes.dart';
import 'package:kosha/src/app/shell/app_router.dart';
import 'package:kosha/src/settings/kosha_settings.dart';

import 'support/app_fakes.dart';

void main() {
  for (final route in [...KoshaRoutes.all, voiceRoute]) {
    testWidgets('launch route "$route" opens its screen', (tester) async {
      final fakes = AppFakes(launchRoute: route);
      await pumpWithServices(tester, fakes.services, const KoshaSettingsApp());
      expect(find.byKey(ValueKey<String>('route:$route')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('an unknown launch route goes home', (tester) async {
    final fakes = AppFakes(launchRoute: 'no-such-screen');
    await pumpWithServices(tester, fakes.services, const KoshaSettingsApp());
    expect(find.byKey(const ValueKey<String>('route:home')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('first run without a launch route opens setup', (tester) async {
    final fakes = AppFakes();
    await pumpWithServices(tester, fakes.services, const KoshaSettingsApp());
    expect(find.byKey(const ValueKey<String>('route:onboarding')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('after setup a launch goes home', (tester) async {
    final fakes = AppFakes(settings: const KoshaSettings(languages: LanguageSettings(onboardingDone: true)));
    await pumpWithServices(tester, fakes.services, const KoshaSettingsApp());
    expect(find.byKey(const ValueKey<String>('route:home')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('home lists every section and opens it', (tester) async {
    final fakes = AppFakes(
      launchRoute: KoshaRoutes.home,
      settings: const KoshaSettings(languages: LanguageSettings(onboardingDone: true)),
    );
    await pumpWithServices(tester, fakes.services, const KoshaSettingsApp());
    for (final title in ['Languages', 'Typing', 'Feel', 'Themes', 'Panels', 'Voice', 'Privacy', 'About']) {
      await tester.scrollUntilVisible(find.text(title), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text(title), findsOneWidget);
    }
    await tapText(tester, 'Typing');
    expect(find.byKey(const ValueKey<String>('route:typing')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('home shows the setup card while Kosha is not enabled', (tester) async {
    final fakes = AppFakes(
      launchRoute: KoshaRoutes.home,
      enabled: false,
      settings: const KoshaSettings(languages: LanguageSettings(onboardingDone: true)),
    );
    await pumpWithServices(tester, fakes.services, const KoshaSettingsApp());
    expect(find.text('Finish setting up Kosha'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('home hides the setup card once Kosha is enabled and selected', (tester) async {
    final fakes = AppFakes(
      launchRoute: KoshaRoutes.home,
      settings: const KoshaSettings(languages: LanguageSettings(onboardingDone: true)),
    );
    await pumpWithServices(tester, fakes.services, const KoshaSettingsApp());
    expect(find.text('Finish setting up Kosha'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
