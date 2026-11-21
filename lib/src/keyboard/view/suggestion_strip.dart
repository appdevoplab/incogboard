// SPDX-License-Identifier: GPL-3.0-or-later
//
// The 44 dp strip above the keys: three suggestion slots (best in the centre),
// or a toolbar of icon buttons when there is nothing to suggest, or a
// "Private field" chip in password fields.
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../core/input_field_info.dart';
import '../../engine/contracts.dart';
import '../../theme/keyboard_theme_data.dart';
import '../input/input_controller.dart';
import 'keyboard_hooks.dart';
import 'keyboard_metrics.dart';

/// Three slots: [left, centre, right]. Null entries are empty.
List<Suggestion?> arrangeSlots(SuggestionBarState bar) {
  final items = <Suggestion>[];
  final seen = <String>{};
  void add(Suggestion s) {
    if (seen.add(s.text)) items.add(s);
  }

  final auto = bar.autoCorrection;
  if (auto != null) add(auto);
  bar.suggestions.forEach(add);
  final top = items.take(3).toList();
  return [top.length > 1 ? top[1] : null, top.isNotEmpty ? top[0] : null, top.length > 2 ? top[2] : null];
}

class SuggestionStrip extends StatelessWidget {
  const SuggestionStrip({
    super.key,
    required this.theme,
    required this.bar,
    required this.field,
    required this.suggestionsEnabled,
    required this.incognito,
    required this.onPick,
    required this.onOpenSettings,
    this.hooks = const KeyboardHooks(),
  });

  final KeyboardThemeData theme;
  final ValueListenable<SuggestionBarState> bar;
  final InputFieldInfo field;

  /// `TypingSettings.showSuggestions`.
  final bool suggestionsEnabled;
  final bool incognito;
  final ValueChanged<Suggestion> onPick;
  final VoidCallback onOpenSettings;
  final KeyboardHooks hooks;

  TextStyle _style(Color color, {bool bold = false}) => TextStyle(
    color: color,
    fontSize: 17 * theme.labelScale,
    fontFamily: theme.fontFamily,
    fontWeight: bold ? FontWeight.w600 : theme.labelWeight,
    fontVariations: theme.labelFontVariations,
    decoration: TextDecoration.none,
  );

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (field.isSensitive) {
      content = _PrivateChip(theme: theme, style: _style(theme.suggestionText));
    } else if (suggestionsEnabled && field.allowsSuggestions) {
      content = ValueListenableBuilder<SuggestionBarState>(
        valueListenable: bar,
        builder: (context, state, _) {
          final slots = arrangeSlots(state);
          if (slots.every((s) => s == null)) return _toolbar();
          return _slots(state, slots);
        },
      );
    } else {
      content = _toolbar();
    }
    return SizedBox(
      height: KeyboardMetrics.stripHeight,
      child: Stack(
        children: [
          Positioned.fill(child: content),
          if (incognito)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Semantics(
                label: 'Incognito mode on',
                child: Center(child: Icon(Icons.visibility_off_outlined, size: 18, color: theme.toolbarIcon)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _slots(SuggestionBarState state, List<Suggestion?> slots) {
    final autoText = state.autoCorrection?.text;
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) _divider(),
          Expanded(
            child: _slot(state, slots[i], isCentre: i == 1, autoText: autoText),
          ),
        ],
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 20, color: theme.suggestionDivider);

  Widget _slot(SuggestionBarState state, Suggestion? s, {required bool isCentre, required String? autoText}) {
    if (s == null) return const SizedBox.shrink();
    final highlighted = isCentre && autoText != null && s.text == autoText;
    var label = s.display ?? s.text;
    if (s.kind == SuggestionKind.typed && state.typedWordUnknown) label = '“$label”';
    return Semantics(
      button: true,
      label: 'Suggestion $label',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onPick(s),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: highlighted ? theme.suggestionHighlightFill : const Color(0x00000000),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _style(highlighted ? theme.suggestionHighlightText : theme.suggestionText, bold: isCentre),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbar() {
    Widget button(IconData icon, String label, VoidCallback? onTap) => Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: onTap == null ? theme.toolbarIcon.withValues(alpha: 0.5) : theme.toolbarIcon,
            ),
          ),
        ),
      ),
    );
    return Row(
      children: [
        button(Icons.emoji_emotions_outlined, 'Emoji', hooks.onEmoji),
        button(Icons.content_paste, 'Clipboard', hooks.onClipboard),
        button(Icons.palette_outlined, 'Themes', hooks.onTheme),
        button(Icons.settings_outlined, 'Settings', onOpenSettings),
      ],
    );
  }
}

class _PrivateChip extends StatelessWidget {
  const _PrivateChip({required this.theme, required this.style});

  final KeyboardThemeData theme;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: 'Private field. Nothing you type here is learned.',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: theme.suggestionHighlightFill, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 16, color: theme.suggestionHighlightText),
              const SizedBox(width: 6),
              Text('Private field', style: style.copyWith(fontSize: 14, color: theme.suggestionHighlightText)),
            ],
          ),
        ),
      ),
    ),
  );
}
