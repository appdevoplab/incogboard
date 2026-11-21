// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:flutter_test/flutter_test.dart';
import 'package:myna/src/bridge/messages.g.dart';
import 'package:myna/src/keyboard/view/keyboard_metrics.dart';
import 'package:myna/src/settings/myna_settings.dart';

WindowMetricsMessage _metrics({required bool landscape, required int smallestDp}) => WindowMetricsMessage(
  screenWidthPx: 2400,
  screenHeightPx: 1080,
  density: 2.625,
  navigationBarInsetPx: 0,
  isLandscape: landscape,
  smallestScreenWidthDp: smallestDp,
  fontScale: 1,
  isNightMode: false,
);

void main() {
  test('compact only for landscape phones', () {
    expect(KeyboardMetrics.isCompact(_metrics(landscape: true, smallestDp: 411)), isTrue);
    expect(KeyboardMetrics.isCompact(_metrics(landscape: false, smallestDp: 411)), isFalse);
    expect(KeyboardMetrics.isCompact(_metrics(landscape: true, smallestDp: 800)), isFalse);
    expect(KeyboardMetrics.isCompact(null), isFalse);
  });

  test('split needs 600 dp and the setting', () {
    const s = MynaSettings();
    expect(KeyboardMetrics.isSplit(s, 900), isTrue);
    expect(KeyboardMetrics.isSplit(s, 599), isFalse);
    final off = s.copyWith(modes: s.modes.copyWith(splitOnWideScreens: false));
    expect(KeyboardMetrics.isSplit(off, 900), isFalse);
  });

  test('compact caps each row at 44 dp, so the window is 4 x 44 dp of keys', () {
    const s = MynaSettings();
    expect(KeyboardMetrics.rowsHeight(s, landscape: true), 4 * 56);
    expect(KeyboardMetrics.rowsHeight(s, landscape: true, compact: true), 4 * 44);
  });
}
