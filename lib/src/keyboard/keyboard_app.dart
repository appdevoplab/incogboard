// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 1-A (keyboard view). Wave 0 placeholder: a minimal QWERTY that
// proves the Flutter-in-IME pipeline end to end. Keep the KeyboardApp
// constructor signature stable (keyboard_main.dart depends on it).
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../bridge/messages.g.dart';
import '../core/input_field_info.dart';
import '../core/keyboard_services.dart';
import '../engine/contracts.dart';
import '../theme/keyboard_theme_data.dart';
import '../theme/theme_resolver.dart';

/// Content height (dp) excluding the navigation-bar inset.
const double kPlaceholderKeyboardHeight = 284;

class KeyboardApp extends StatefulWidget {
  const KeyboardApp({super.key, required this.services});

  final KeyboardServices services;

  @override
  State<KeyboardApp> createState() => _KeyboardAppState();
}

class _KeyboardAppState extends State<KeyboardApp> {
  KeyboardServices get s => widget.services;
  bool _shift = true;
  String _word = '';
  List<Suggestion> _suggestions = const [];

  static const _rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];
  double? _requestedHeight;

  /// Dart owns the total window height: content + the bottom inset Flutter applies.
  void _syncWindowHeight(double bottomInset) {
    final total = kPlaceholderKeyboardHeight + bottomInset;
    if (total == _requestedHeight) return;
    _requestedHeight = total;
    unawaited(s.host.setWindowLayout(WindowLayoutMessage(mode: WindowMode.docked, heightDp: total)));
  }

  @override
  void initState() {
    super.initState();
    unawaited(s.predictor.setActiveLanguages(['en']));
    s.events.startInput.listen((e) {
      if (e.inputView) setState(_resetForField);
    });
  }

  void _resetForField() {
    _word = '';
    _suggestions = const [];
    _shift = s.events.field.value.capSentences || s.events.field.value.capWords;
  }

  void _letter(String c) {
    final out = _shift ? c.toUpperCase() : c;
    unawaited(s.input.commitText(out));
    unawaited(s.host.performHaptic(HapticKind.keyTap));
    setState(() {
      _word += out;
      _shift = false;
      _suggestions = s.predictor.suggest(TypingContext(composing: _word)).suggestions;
    });
  }

  void _space() {
    unawaited(s.input.commitText(' '));
    setState(() {
      _word = '';
      _suggestions = const [];
    });
  }

  void _backspace() {
    unawaited(s.input.sendDownUpKeyEvent(AndroidKeyCode.del));
    setState(() {
      if (_word.isNotEmpty) _word = _word.substring(0, _word.length - 1);
      _suggestions = _word.isEmpty ? const [] : s.predictor.suggest(TypingContext(composing: _word)).suggestions;
    });
  }

  void _enter() {
    final field = s.events.field.value;
    if (field.enterInsertsNewline) {
      unawaited(s.input.commitText('\n'));
    } else {
      unawaited(s.input.performEditorAction(field.editorActionId));
    }
    setState(() => _word = '');
  }

  void _pick(Suggestion suggestion) {
    unawaited(s.input.deleteSurroundingText(_word.length, 0));
    unawaited(s.input.commitText('${suggestion.text} '));
    setState(() {
      _word = '';
      _suggestions = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final metrics = s.events.metrics.value;
    final theme = resolveKeyboardTheme(
      appearance: s.settings.value.appearance,
      systemColors: null,
      systemDark: metrics?.isNightMode ?? false,
      disableAnimations: MediaQuery.of(context).disableAnimations,
    );
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    _syncWindowHeight(bottomInset);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: theme.background,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: _SuggestionStrip(theme: theme, suggestions: _suggestions, onPick: _pick),
              ),
              for (final row in _rows)
                _row([
                  for (final c in row.split(''))
                    _Key(label: _shift ? c.toUpperCase() : c, theme: theme, onTap: () => _letter(c)),
                ], theme),
              _row([
                _Key(
                  label: _shift ? '⇧' : '⇧',
                  theme: theme,
                  flex: 3,
                  function: true,
                  onTap: () => setState(() => _shift = !_shift),
                ),
                _Key(label: ',', theme: theme, flex: 2, onTap: () => unawaited(s.input.commitText(','))),
                _Key(label: 'Myna', theme: theme, flex: 9, space: true, onTap: _space),
                _Key(label: '.', theme: theme, flex: 2, onTap: () => unawaited(s.input.commitText('.'))),
                _Key(label: '⌫', theme: theme, flex: 3, function: true, onTap: _backspace),
                _Key(label: '↵', theme: theme, flex: 3, action: true, onTap: _enter),
              ], theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> keys, KeyboardThemeData theme) => SizedBox(
    height: 56,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: theme.keyGap / 2),
      child: Row(children: keys),
    ),
  );
}

class _SuggestionStrip extends StatelessWidget {
  const _SuggestionStrip({required this.theme, required this.suggestions, required this.onPick});

  final KeyboardThemeData theme;
  final List<Suggestion> suggestions;
  final ValueChanged<Suggestion> onPick;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final sug in suggestions.take(3))
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onPick(sug),
            child: Center(
              child: Text(sug.text, style: TextStyle(color: theme.suggestionText, fontSize: 17), maxLines: 1),
            ),
          ),
        ),
    ],
  );
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.theme,
    required this.onTap,
    this.flex = 2,
    this.function = false,
    this.action = false,
    this.space = false,
  });

  final String label;
  final KeyboardThemeData theme;
  final VoidCallback onTap;
  final int flex;
  final bool function;
  final bool action;
  final bool space;

  @override
  Widget build(BuildContext context) {
    final style = action
        ? theme.actionKey
        : function
        ? theme.functionKey
        : space
        ? theme.spaceKey
        : theme.letterKey;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(theme.keyGap / 2),
          child: DecoratedBox(
            decoration: BoxDecoration(color: style.fill, borderRadius: BorderRadius.circular(22)),
            child: Center(
              child: Text(
                label,
                style: TextStyle(color: style.label, fontSize: space ? 14 : 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
