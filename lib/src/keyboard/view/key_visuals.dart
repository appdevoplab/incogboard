// SPDX-License-Identifier: GPL-3.0-or-later
//
// What each key looks like and what it is called to accessibility services.
import 'package:characters/characters.dart';
import 'package:flutter/widgets.dart' show IconData;
import 'package:material_ui/material_ui.dart' show Icons;

import '../../core/input_field_info.dart';
import '../../settings/kosha_settings.dart';
import '../input/input_controller.dart';
import '../input/keyboard_page.dart';
import '../layout/layout_model.dart';
import '../../theme/keyboard_theme_data.dart';

/// Which theme fill a key uses.
enum KeyGroup { letter, function, action, space }

/// Shift icon states: outline (off), filled (one letter), filled with a bar (caps lock).
enum ShiftGlyph { outline, filled, caps }

class KeyVisual {
  const KeyVisual({
    required this.group,
    required this.semantics,
    this.label,
    this.icon,
    this.shiftGlyph,
    this.hint,
    this.smallLabel = false,
  });

  final KeyGroup group;
  final String? label;
  final IconData? icon;
  final ShiftGlyph? shiftGlyph;
  final String? hint;

  /// Multi-character labels ("?123", ".com") use a smaller size.
  final bool smallLabel;
  final String semantics;

  KeyStyle styleOf(KeyboardThemeData theme) => switch (group) {
    KeyGroup.letter => theme.letterKey,
    KeyGroup.function => theme.functionKey,
    KeyGroup.action => theme.actionKey,
    KeyGroup.space => theme.spaceKey,
  };
}

/// Upper-cases one key label or output the way a keyboard should ("ß" becomes "ẞ").
String applyShift(String s) => s == 'ß' ? 'ẞ' : s.toUpperCase();

bool _isSingleLetter(String s) => s.characters.length == 1 && s.toLowerCase() != s.toUpperCase();

/// The text a character key commits right now.
String outputFor(KeyDef def, {required bool shifted}) {
  final out = def.output ?? def.label ?? '';
  if (!shifted) return out;
  if (def.shiftedOutput != null) return def.shiftedOutput!;
  return _isSingleLetter(out) ? applyShift(out) : out;
}

String _enterName(InputFieldInfo f) {
  if (f.enterInsertsNewline) return 'Enter';
  return switch (f.action) {
    ImeAction.search => 'Search',
    ImeAction.send => 'Send',
    ImeAction.go => 'Go',
    ImeAction.next => 'Next',
    ImeAction.done => 'Done',
    ImeAction.previous => 'Previous',
    _ => 'Enter',
  };
}

IconData enterIcon(InputFieldInfo f) {
  if (f.enterInsertsNewline) return Icons.keyboard_return;
  return switch (f.action) {
    ImeAction.search => Icons.search,
    ImeAction.send => Icons.send,
    ImeAction.go => Icons.arrow_forward,
    ImeAction.next => Icons.keyboard_tab,
    ImeAction.done => Icons.check,
    ImeAction.previous => Icons.keyboard_tab,
    _ => Icons.keyboard_return,
  };
}

const Map<String, String> _spoken = {
  ',': 'Comma',
  '.': 'Period',
  '@': 'At sign',
  '#': 'Hash',
  '\$': 'Dollar',
  '%': 'Percent',
  '&': 'Ampersand',
  '-': 'Minus',
  '+': 'Plus',
  '(': 'Open parenthesis',
  ')': 'Close parenthesis',
  '/': 'Slash',
  '*': 'Asterisk',
  '"': 'Quote',
  "'": 'Apostrophe',
  ':': 'Colon',
  ';': 'Semicolon',
  '!': 'Exclamation mark',
  '?': 'Question mark',
  '=': 'Equals',
  '_': 'Underscore',
  '<': 'Less than',
  '>': 'Greater than',
  '[': 'Open bracket',
  ']': 'Close bracket',
  '{': 'Open brace',
  '}': 'Close brace',
  '\\': 'Backslash',
  '|': 'Vertical bar',
  '~': 'Tilde',
  '^': 'Caret',
  '`': 'Backtick',
  '.com': 'Dot com',
  '‍': 'Zero width joiner',
  '‌': 'Zero width non-joiner',
};

String spokenName(String text) => _spoken[text] ?? text;

/// Invisible format characters get a visible label (popups would otherwise show an empty cell).
const Map<String, String> _formatLabels = {'‍': 'ZWJ', '‌': 'ZWNJ'};

/// What a popup cell shows for [item]; the item itself is what gets typed.
String displayLabel(String item) => _formatLabels[item] ?? item;

KeyVisual resolveKeyVisual(
  KeyDef def, {
  required ShiftState shift,
  required KeyboardPage page,
  required InputFieldInfo field,
  required TypingSettings typing,
  required bool showHints,
  String? spaceLabel,
}) {
  final commitsShifted = shift != ShiftState.off && page == KeyboardPage.letters;
  final shifted = commitsShifted && !typing.lowercaseLabels;
  String? hintFor() => (showHints && typing.hintLabels) ? def.hint : null;

  switch (def.type) {
    case KeyType.character:
    case KeyType.comma:
    case KeyType.period:
      final base = def.label ?? def.output ?? '';
      final out = def.output ?? base;
      String label;
      if (def.type == KeyType.character && shifted) {
        label = def.shiftedLabel ?? def.shiftedOutput ?? (_isSingleLetter(base) ? applyShift(base) : base);
      } else {
        label = base;
      }
      return KeyVisual(
        group: KeyGroup.letter,
        label: label,
        hint: hintFor(),
        smallLabel: label.characters.length > 1,
        // Speak what the key commits now: InScript shift layers use shiftedOutput (not upper case), and
        // lowercase labels change only the label, not what is typed.
        semantics: spokenName(def.type == KeyType.character ? outputFor(def, shifted: commitsShifted) : out),
      );
    case KeyType.shift:
      return KeyVisual(
        group: KeyGroup.function,
        shiftGlyph: switch (shift) {
          ShiftState.off => ShiftGlyph.outline,
          ShiftState.once => ShiftGlyph.filled,
          ShiftState.caps => ShiftGlyph.caps,
        },
        semantics: switch (shift) {
          ShiftState.off => 'Shift, off',
          ShiftState.once => 'Shift, on',
          ShiftState.caps => 'Shift, caps lock on',
        },
      );
    case KeyType.backspace:
      return const KeyVisual(group: KeyGroup.function, icon: Icons.backspace_outlined, semantics: 'Delete');
    case KeyType.enter:
      return KeyVisual(group: KeyGroup.action, icon: enterIcon(field), semantics: _enterName(field));
    case KeyType.space:
      if (spaceLabel == null || spaceLabel.isEmpty) return const KeyVisual(group: KeyGroup.space, semantics: 'Space');
      return KeyVisual(group: KeyGroup.space, label: spaceLabel, smallLabel: true, semantics: 'Space, $spaceLabel');
    case KeyType.symbols:
      return KeyVisual(group: KeyGroup.function, label: def.label ?? '?123', smallLabel: true, semantics: 'Symbols');
    case KeyType.moreSymbols:
      return KeyVisual(
        group: KeyGroup.function,
        label: def.label ?? '=\\<',
        smallLabel: true,
        semantics: 'More symbols',
      );
    case KeyType.alphabet:
      return KeyVisual(group: KeyGroup.function, label: def.label ?? 'ABC', smallLabel: true, semantics: 'Letters');
    case KeyType.numbers:
      return KeyVisual(group: KeyGroup.function, label: def.label ?? '123', smallLabel: true, semantics: 'Numbers');
    case KeyType.globe:
      return const KeyVisual(group: KeyGroup.function, icon: Icons.language, semantics: 'Switch language');
    case KeyType.emoji:
      return const KeyVisual(group: KeyGroup.function, icon: Icons.emoji_emotions_outlined, semantics: 'Emoji');
    case KeyType.voice:
      return const KeyVisual(group: KeyGroup.function, icon: Icons.mic_none, semantics: 'Voice typing');
    case KeyType.clipboard:
      return const KeyVisual(group: KeyGroup.function, icon: Icons.content_paste, semantics: 'Clipboard');
    case KeyType.settings:
      return const KeyVisual(group: KeyGroup.function, icon: Icons.settings_outlined, semantics: 'Settings');
    case KeyType.tab:
      return const KeyVisual(group: KeyGroup.function, icon: Icons.keyboard_tab, semantics: 'Tab');
    case KeyType.cursorLeft:
      return const KeyVisual(group: KeyGroup.function, icon: Icons.chevron_left, semantics: 'Cursor left');
    case KeyType.cursorRight:
      return const KeyVisual(group: KeyGroup.function, icon: Icons.chevron_right, semantics: 'Cursor right');
    case KeyType.custom:
      return KeyVisual(group: KeyGroup.function, label: def.label, semantics: def.label ?? 'Key');
  }
}
