// SPDX-License-Identifier: GPL-3.0-or-later
//
// Extension points for Wave 2 (panels, space-bar cursor control, swipe to
// delete words). Every hook is optional; the keyboard works without them.
import 'package:flutter/foundation.dart';

class KeyboardHooks {
  const KeyboardHooks({
    this.onEmoji,
    this.onClipboard,
    this.onEditing,
    this.onModes,
    this.onTheme,
    this.onVoice,
    this.onSpaceDrag,
    this.onBackspaceDrag,
  });

  /// Toolbar and key buttons. The Editing and Modes toolbar buttons only appear when set.
  final VoidCallback? onEmoji;
  final VoidCallback? onClipboard;

  /// Text-editing panel (Wave 2-D).
  final VoidCallback? onEditing;

  /// One-handed / floating / resize bar (Wave 2-E).
  final VoidCallback? onModes;
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

  /// Combines hooks from several features: for each callback the first non-null one wins.
  static KeyboardHooks merge(Iterable<KeyboardHooks> all) {
    T? first<T>(T? Function(KeyboardHooks h) pick) {
      for (final h in all) {
        final v = pick(h);
        if (v != null) return v;
      }
      return null;
    }

    return KeyboardHooks(
      onEmoji: first((h) => h.onEmoji),
      onClipboard: first((h) => h.onClipboard),
      onEditing: first((h) => h.onEditing),
      onModes: first((h) => h.onModes),
      onTheme: first((h) => h.onTheme),
      onVoice: first((h) => h.onVoice),
      onSpaceDrag: first((h) => h.onSpaceDrag),
      onBackspaceDrag: first((h) => h.onBackspaceDrag),
    );
  }
}
