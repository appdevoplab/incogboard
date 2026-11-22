// SPDX-License-Identifier: GPL-3.0-or-later
//
// The Kosha chest: every pose builds at the sizes it is used at, in light and dark, at font scale 1.3,
// with its TalkBack label, and springs between poses without overflowing.
import 'package:flutter_test/flutter_test.dart';
import 'package:kosha/src/app/l10n.dart';
import 'package:kosha/src/app/onboarding/kosha_mascot.dart';
import 'package:kosha/src/app/shell/kosha_theme.dart';
import 'package:material_ui/material_ui.dart';

Widget _host({required Brightness brightness, required Widget child, bool disableAnimations = false}) {
  return MaterialApp(
    localizationsDelegates: koshaLocalizationsDelegates,
    theme: koshaThemeData(koshaBrandScheme(Brightness.light)),
    darkTheme: koshaThemeData(koshaBrandScheme(Brightness.dark)),
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.3), disableAnimations: disableAnimations),
      child: app!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    for (final pose in KoshaPose.values) {
      for (final size in [24.0, 48.0, 96.0, 160.0]) {
        testWidgets('${pose.name} at ${size.toInt()} dp builds in ${brightness.name} at font scale 1.3', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          await tester.pumpWidget(
            _host(
              brightness: brightness,
              child: KoshaMascot(size: size, pose: pose, label: 'Kosha chest'),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(tester.getSize(find.byType(KoshaMascot)), Size(size, size));
          expect(find.bySemanticsLabel('Kosha chest'), findsOneWidget);
          semantics.dispose();
        });
      }
    }
  }

  testWidgets('the default pose is open and the default label is spoken', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_host(brightness: Brightness.light, child: const KoshaMascot()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(const KoshaMascot().pose, KoshaPose.open);
    expect(find.bySemanticsLabel('Kosha mascot'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('switching poses springs without exceptions and ends on the new pose', (tester) async {
    Widget chest(KoshaPose pose) => _host(
      brightness: Brightness.light,
      child: KoshaMascot(size: 96, pose: pose),
    );
    await tester.pumpWidget(chest(KoshaPose.open));
    await tester.pumpAndSettle();
    for (final pose in [KoshaPose.locked, KoshaPose.glowing, KoshaPose.quiet, KoshaPose.open]) {
      await tester.pumpWidget(chest(pose));
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('reduced motion switches poses at once', (tester) async {
    await tester.pumpWidget(
      _host(
        brightness: Brightness.dark,
        disableAnimations: true,
        child: const KoshaMascot(size: 96, pose: KoshaPose.open),
      ),
    );
    await tester.pumpWidget(
      _host(
        brightness: Brightness.dark,
        disableAnimations: true,
        child: const KoshaMascot(size: 96, pose: KoshaPose.glowing),
      ),
    );
    // No transition is running, so a single frame is the final state.
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration, Duration.zero);
    expect(find.byKey(const ValueKey<KoshaPose>(KoshaPose.open)), findsNothing);
    expect(find.byKey(const ValueKey<KoshaPose>(KoshaPose.glowing)), findsOneWidget);
  });
}
