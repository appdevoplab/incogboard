// SPDX-License-Identifier: GPL-3.0-or-later
import '../../settings/myna_settings.dart';

/// Sizes of the keyboard window. Dart owns the total height: the IME window
/// is exactly [totalHeight] dp (content plus the bottom inset Flutter applies).
abstract final class KeyboardMetrics {
  /// Suggestion strip.
  static const double stripHeight = 44;

  /// One standard key row before the height scale.
  static const double rowHeight = 56;

  /// Relative height of the optional number row.
  static const double numberRowUnits = 0.8;

  /// Rows in every page (the number row adds [numberRowUnits] when enabled).
  static const double baseRowUnits = 4;

  static double heightScale(AppearanceSettings a, {required bool landscape}) =>
      landscape ? a.landscapeHeightScale : a.heightScale;

  /// Height of the key rows (strip excluded). Constant across pages so the
  /// window never resizes when the page changes.
  static double rowsHeight(MynaSettings s, {required bool landscape}) {
    final units = baseRowUnits + (s.typing.numberRow ? numberRowUnits : 0);
    return units * rowHeight * heightScale(s.appearance, landscape: landscape);
  }

  /// Content height: strip plus rows.
  static double contentHeight(MynaSettings s, {required bool landscape}) =>
      stripHeight + rowsHeight(s, landscape: landscape);

  /// What to send in WindowLayoutMessage.heightDp.
  static double totalHeight(MynaSettings s, {required bool landscape, required double bottomInset}) =>
      contentHeight(s, landscape: landscape) + bottomInset;
}
