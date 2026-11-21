// SPDX-License-Identifier: GPL-3.0-or-later
//
// Extension points for Wave 2 (panels, space-bar cursor control, swipe to
// delete words). Every hook is optional; the keyboard works without them.
import 'package:flutter/foundation.dart';

class KeyboardHooks {
  const KeyboardHooks({
    this.onEmoji,
    this.onClipboard,
    this.onTheme,
    this.onVoice,
    this.onSpaceDrag,
    this.onBackspaceDrag,
  });

  /// Toolbar and key buttons.
  final VoidCallback? onEmoji;
  final VoidCallback? onClipboard;
  final VoidCallback? onTheme;
  final VoidCallback? onVoice;

  /// A finger that landed on the space bar moved horizontally. [dx] is the total
  /// horizontal travel since touch-down in dp; [done] is true when the finger lifts.
  /// Only called when `SwipeSettings.spaceCursorControl` is on. While the hook is
  /// active the space key does not type a space.
  final void Function(double dx, {required bool done})? onSpaceDrag;

  /// Same for backspace (`SwipeSettings.backspaceSwipeDelete`). While active the
  /// key stops repeating. Wave 2 selects words while [done] is false and deletes
  /// them on release.
  final void Function(double dx, {required bool done})? onBackspaceDrag;
}
