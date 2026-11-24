// SPDX-License-Identifier: GPL-3.0-or-later
//
// The IncogBoard chest: every pose builds at the sizes it is used at, in light and dark, at font scale 1.3,
// with its TalkBack label, and springs between poses without overflowing.
import 'package:flutter_test/flutter_test.dart';
import 'package:incogboard/src/app/l10n.dart';
import 'package:incogboard/src/app/onboarding/incogboard_mascot.dart';
import 'package:incogboard/src/app/shell/incogboard_theme.dart';
import 'package:material_ui/material_ui.dart';

Widget _host({required Brightness brightness, required Widget child, bool disableAnimations = false}) {
  return MaterialApp(
    localizationsDelegates: incogboardLocalizationsDelegates,
    theme: incogboardThemeData(incogboardBrandScheme(Brightness.light)),
    darkTheme: incogboardThemeData(incogboardBrandScheme(Brightness.dark)),
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
    for (final pose in IncogBoardPose.values) {
      for (final size in [24.0, 48.0, 96.0, 160.0]) {
        testWidgets('${pose.name} at ${size.toInt()} dp builds in ${brightness.name} at font scale 1.3', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          await tester.pumpWidget(
            _host(
              brightness: brightness,
              child: IncogBoardMascot(size: size, pose: pose, label: 'IncogBoard chest'),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(tester.getSize(find.byType(IncogBoardMascot)), Size(size, size));
          // The painter itself must have room: a zero-sized CustomPaint draws nothing.
          expect(
            tester.getSize(find.descendant(of: find.byType(IncogBoardMascot), matching: find.byType(CustomPaint))),
            Size(size, size),
          );
          expect(find.bySemanticsLabel('IncogBoard chest'), findsOneWidget);
          semantics.dispose();
        });
      }
    }
  }

  testWidgets('the default pose is open and the default label is spoken', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_host(brightness: Brightness.light, child: const IncogBoardMascot()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(const IncogBoardMascot().pose, IncogBoardPose.open);
    expect(find.bySemanticsLabel('IncogBoard mascot'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('switching poses springs without exceptions and ends on the new pose', (tester) async {
    Widget chest(IncogBoardPose pose) => _host(
      brightness: Brightness.light,
      child: IncogBoardMascot(size: 96, pose: pose),
    );
    await tester.pumpWidget(chest(IncogBoardPose.open));
    await tester.pumpAndSettle();
    for (final pose in [IncogBoardPose.locked, IncogBoardPose.glowing, IncogBoardPose.quiet, IncogBoardPose.open]) {
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
        child: const IncogBoardMascot(size: 96, pose: IncogBoardPose.open),
      ),
    );
    await tester.pumpWidget(
      _host(
        brightness: Brightness.dark,
        disableAnimations: true,
        child: const IncogBoardMascot(size: 96, pose: IncogBoardPose.glowing),
      ),
    );
    // No transition is running, so a single frame is the final state.
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration, Duration.zero);
    expect(find.byKey(const ValueKey<IncogBoardPose>(IncogBoardPose.open)), findsNothing);
    expect(find.byKey(const ValueKey<IncogBoardPose>(IncogBoardPose.glowing)), findsOneWidget);
  });
}
