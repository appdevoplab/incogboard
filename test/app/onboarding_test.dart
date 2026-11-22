// SPDX-License-Identifier: GPL-3.0-or-later
//
// First-run setup reacts to the enabled and selected status, polls while on the switch step,
// stores onboardingDone when finished, and writes the theme choice to the appearance section.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myna/src/app/app.dart';
import 'package:myna/src/app/routes.dart';
import 'package:myna/src/settings/myna_settings.dart';

import 'support/app_fakes.dart';

void main() {
  testWidgets('enable step follows Myna being turned on when the app resumes', (tester) async {
    final fakes = AppFakes(launchRoute: MynaRoutes.onboarding, enabled: false, selected: false);
    await pumpWithServices(tester, fakes.services, const MynaSettingsApp());
    expect(find.text('Myna is not turned on yet.'), findsOneWidget);

    when(() => fakes.app.isMynaEnabled()).thenAnswer((_) async => true);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Myna is turned on.'), findsOneWidget);
    expect(find.text('Skip'), findsNothing, reason: 'a done step offers Next, not Skip');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('switch step polls every 500 ms until Myna is selected', (tester) async {
    final fakes = AppFakes(launchRoute: MynaRoutes.onboarding, selected: false);
    await pumpWithServices(tester, fakes.services, const MynaSettingsApp());
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Switch to Myna'), findsOneWidget);
    expect(find.text('Myna is not your keyboard yet.'), findsOneWidget);

    when(() => fakes.app.isMynaSelected()).thenAnswer((_) async => true);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Myna is your keyboard.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the privacy step shows that the app has no internet permission', (tester) async {
    final fakes = AppFakes(launchRoute: MynaRoutes.onboarding, internet: false);
    await pumpWithServices(tester, fakes.services, const MynaSettingsApp());
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Why the warning does not apply'), findsOneWidget);
    expect(find.textContaining('no internet permission'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('finishing setup stores onboardingDone and opens home', (tester) async {
    final fakes = AppFakes(launchRoute: MynaRoutes.onboarding);
    await pumpWithServices(tester, fakes.services, const MynaSettingsApp());
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('You are all set'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    final update = capturedUpdate(fakes.store, 'languages');
    expect(update(const MynaSettings()).languages.onboardingDone, isTrue);
    expect(find.byKey(const ValueKey<String>('route:home')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('choosing a theme on the personalise step writes the appearance section', (tester) async {
    final fakes = AppFakes(launchRoute: MynaRoutes.onboarding);
    await pumpWithServices(tester, fakes.services, const MynaSettingsApp());
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Pick languages and a theme'), findsOneWidget);
    await tester.tap(find.text('Myna Gold'));
    await tester.pumpAndSettle();

    final update = capturedUpdate(fakes.store, 'appearance');
    expect(update(const MynaSettings()).appearance.themeId, 'myna_gold');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('every language is on the personalise step and can be chosen (Wave 3: nothing is coming soon)', (
    tester,
  ) async {
    final fakes = AppFakes(launchRoute: MynaRoutes.onboarding);
    await pumpWithServices(tester, fakes.services, const MynaSettingsApp());
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.textContaining('(soon)'), findsNothing);
    expect(find.text('Español'), findsOneWidget);
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    final update = capturedUpdate(fakes.store, 'languages');
    expect(update(const MynaSettings()).languages.enabled, ['en', 'es']);
    await tester.pumpWidget(const SizedBox());
  });
}
