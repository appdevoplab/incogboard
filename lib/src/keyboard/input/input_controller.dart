// SPDX-License-Identifier: GPL-3.0-or-later
//
// InputController: the keyboard's typing brain. Pure Dart: it talks to the
// editor only through [InputSink], so it is unit-tested against FakeEditor.
//
// PRIVACY: never log typed text. Only events and sizes go to MynaLog.
import 'dart:async';

import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';

import '../../bridge/input_sink.dart';
import '../../bridge/messages.g.dart';
import '../../core/input_field_info.dart';
import '../../core/log.dart';
import '../../engine/contracts.dart';
import '../../engine/language_rules.dart';
import '../../settings/myna_settings.dart';
import 'keyboard_page.dart';

/// One-shot shift, caps lock, or off.
enum ShiftState { off, once, caps }

/// What the suggestion strip shows.
@immutable
class SuggestionBarState {
  const SuggestionBarState({
    this.suggestions = const [],
    this.autoCorrection,
    this.isComposing = false,
    this.typedWordUnknown = false,
    this.fromSwipe = false,
  });

  static const SuggestionBarState empty = SuggestionBarState();

  /// Best first.
  final List<Suggestion> suggestions;

  /// The correction that will be applied on the next separator, if any.
  final Suggestion? autoCorrection;
  final bool isComposing;

  /// The literal typed word is not in any active lexicon (shown in quotes).
  final bool typedWordUnknown;

  /// Alternatives for the word just swiped (the first one is already committed).
  final bool fromSwipe;
}

/// Whether the keyboard window must hide from screenshots.
bool shouldSecureWindow(InputFieldInfo field, PrivacySettings privacy) =>
    field.isSensitive || privacy.hideFromScreenshots;

enum _SpaceState {
  none,

  /// The user typed a space after a word.
  typedAfterWord,

  /// A space we inserted after a picked suggestion or swipe (punctuation may swallow it).
  autoAfterPick,

  /// A space we inserted after punctuation (a further space press is ignored).
  autoAfterPunct,
}

class _Correction {
  const _Correction({required this.original, required this.corrected, required this.committedLength});

  final String original;
  final String corrected;

  /// UTF-16 length of everything committed for this correction (word + separator output).
  final int committedLength;
}

class _SwipeRecord {
  const _SwipeRecord({required this.leading, required this.word, required this.candidates});

  /// Space inserted before the word (may be empty).
  final String leading;
  final String word;
  final List<Suggestion> candidates;

  /// Word plus its trailing space.
  int get bodyLength => word.length + 1;
}

class InputController {
  InputController({
    required this._input,
    required this._predictor,
    required GestureDecoder gestureDecoder,
    required this._settings,
    this._rulesFor = languageRulesFor,
    LanguageId Function()? language,
    int Function()? clock,
  }) : _decoder = gestureDecoder,
       _language = language ?? (() => 'en'),
       _clock = clock ?? _defaultClock();

  static int Function() _defaultClock() {
    final sw = Stopwatch()..start();
    return () => sw.elapsedMilliseconds;
  }

  /// Selection events this soon after our own edit are assumed to be echoes.
  static const int selfEventGraceMs = 150;

  /// Two shift taps within this time lock caps.
  static const int doubleTapMs = 300;

  final InputSink _input;
  final TextPredictor _predictor;
  final GestureDecoder _decoder;
  final MynaSettings Function() _settings;
  final LanguageRulesResolver _rulesFor;
  final LanguageId Function() _language;
  final int Function() _clock;

  // ---- Observable state -------------------------------------------------

  final ValueNotifier<InputFieldInfo> field = ValueNotifier(InputFieldInfo.plainText);
  final ValueNotifier<ShiftState> shift = ValueNotifier(ShiftState.off);
  final ValueNotifier<KeyboardPage> page = ValueNotifier(KeyboardPage.letters);
  final ValueNotifier<SuggestionBarState> bar = ValueNotifier(SuggestionBarState.empty);

  // ---- Private state ----------------------------------------------------

  String _composing = '';
  final List<KeyTap> _taps = [];
  SuggestionResult _lastResult = SuggestionResult.empty;

  /// Text just before the cursor, excluding the composing word (a mirror of the editor).
  String _before = '';
  List<String> _previous = const [];

  _SpaceState _space = _SpaceState.none;
  _Correction? _lastCorrection;
  _SwipeRecord? _lastSwipe;
  String? _noCorrectionWord;

  bool _autoShifted = false;
  int _lastShiftTapMs = -100000;

  int _seq = 0;
  int _startGen = 0;
  int _editDepth = 0;
  int _lastEditMs = 0;

  // ---- Derived ----------------------------------------------------------

  InputFieldInfo get currentField => field.value;
  MynaSettings get settings => _settings();
  LanguageRules get _rules => _rulesFor(_language());

  /// The word being composed (empty when none). Exposed for tests and the view.
  String get composing => _composing;

  /// Up to 3 words before the cursor, oldest first.
  List<String> get previousWords => List.unmodifiable(_previous);

  bool get _raw => field.value.isRawKeyMode;
  bool get _sensitive => field.value.isSensitive;

  /// Composing text (and suggestions) only in ordinary text fields.
  bool get _composeEnabled => !_raw && field.value.allowsSuggestions;

  /// Smart spacing (double space, punctuation spacing) only where autocorrect would be allowed.
  bool get _smartField => field.value.allowsAutoCorrect;

  bool get isIncognito {
    final p = settings.privacy;
    return p.incognito || (field.value.packageName != null && p.incognitoApps.contains(field.value.packageName));
  }

  bool get learningAllowed => field.value.allowsLearning && settings.privacy.learning && !isIncognito;

  bool get _contextReadable => field.value.kind == FieldKind.text && !_sensitive;

  // ---- Edit bracket -----------------------------------------------------

  void _begin() {
    _editDepth++;
    _seq++;
    _lastEditMs = _clock();
  }

  void _end() {
    _editDepth--;
    _lastEditMs = _clock();
  }

  void _send(Future<Object?> call) {
    unawaited(call.then<void>((_) {}, onError: (Object e) => MynaLog.w('Input', 'editor call failed', e.runtimeType)));
  }

  void _batch(void Function() body) {
    _send(_input.beginBatchEdit());
    try {
      body();
    } finally {
      _send(_input.endBatchEdit());
    }
  }

  // ---- Mirror helpers ---------------------------------------------------

  void _mirrorAppend(String text) {
    if (_sensitive) return; // never keep password text around
    var next = _before + text;
    if (next.length > 256) next = next.substring(next.length - 128);
    _before = next;
  }

  void _mirrorDeleteUnits(int units) {
    _before = units >= _before.length ? '' : _before.substring(0, _before.length - units);
  }

  String? get _prevChar => _before.isEmpty ? null : _before.characters.last;

  bool _isLetter(String c) => RegExp(r'^[\p{L}\p{M}]', unicode: true).hasMatch(c);
  bool _isDigit(String c) => RegExp(r'^\p{Nd}', unicode: true).hasMatch(c);

  List<String> _wordsOf(String text) {
    final rules = _rules;
    final words = <String>[];
    final b = StringBuffer();
    for (final ch in text.characters) {
      if (rules.isWordChar(ch)) {
        b.write(ch);
      } else if (b.isNotEmpty) {
        words.add(b.toString());
        b.clear();
      }
    }
    if (b.isNotEmpty) words.add(b.toString());
    return words.length <= 3 ? words : words.sublist(words.length - 3);
  }

  void _pushPrevious(String word) {
    final next = [..._previous, word];
    _previous = next.length <= 3 ? next : next.sublist(next.length - 3);
  }

  bool get _startOfSentence {
    final trimmed = _before.trimRight();
    if (trimmed.isEmpty) return true;
    if (trimmed.length == _before.length) return false;
    return _rules.endsSentence(trimmed.characters.last);
  }

  // ---- Field lifecycle --------------------------------------------------

  /// A field gained focus (or restarted). [restarting] keeps page and shift when the field is unchanged.
  Future<void> startInput(InputFieldInfo f, {bool restarting = false}) async {
    final same = restarting && f == field.value;
    final gen = ++_startGen;
    field.value = f;
    _resetTransient();
    _lastEditMs = _clock();
    if (!same) {
      page.value = KeyboardPage.forField(f.preferredPage);
      shift.value = ShiftState.off;
      _autoShifted = false;
    }
    _before = '';
    _previous = const [];
    _setBar(SuggestionBarState.empty);
    final req = _capsRequest();
    if (req != 0 && !same) _applyCaps(f.initialCapsMode & req);
    if (!_contextReadable) return;
    final text = await _input.getTextBeforeCursor(64);
    if (gen != _startGen) return;
    _before = text ?? '';
    _previous = _wordsOf(_before);
    _updateSuggestions();
    await _refreshCaps();
  }

  /// The connection ended: commit what is composing and forget it.
  void finishInput() {
    _startGen++;
    if (_composing.isNotEmpty) {
      _composing = '';
      _taps.clear();
      _send(_input.finishComposingText());
    }
    _resetTransient();
    _setBar(SuggestionBarState.empty);
  }

  void _resetTransient() {
    _seq++;
    _composing = '';
    _taps.clear();
    _lastResult = SuggestionResult.empty;
    _space = _SpaceState.none;
    _lastCorrection = null;
    _lastSwipe = null;
    _noCorrectionWord = null;
  }

  /// Feed `events.selection` here.
  void onSelectionChanged(SelectionMessage m) {
    if (_editDepth > 0) return;
    if (_clock() - _lastEditMs < selfEventGraceMs) return;
    if (_composing.isNotEmpty) {
      final consistent = m.newSelStart == m.newSelEnd && m.candidatesStart >= 0 && m.newSelStart == m.candidatesEnd;
      if (consistent) return;
    }
    _onExternalChange();
  }

  void _onExternalChange() {
    _begin();
    try {
      if (_composing.isNotEmpty) {
        _composing = '';
        _taps.clear();
        _send(_input.finishComposingText());
      }
      _resetTransient();
      _setBar(SuggestionBarState.empty);
    } finally {
      _end();
    }
    unawaited(_resyncContext());
  }

  Future<void> _resyncContext() async {
    if (!_contextReadable) return;
    final seq = _seq;
    final text = await _input.getTextBeforeCursor(64);
    if (seq != _seq) return;
    _before = text ?? '';
    _previous = _wordsOf(_before);
    _updateSuggestions();
    await _refreshCaps();
  }

  // ---- Pages and shift --------------------------------------------------

  void setPage(KeyboardPage p) {
    if (page.value == p) return;
    page.value = p;
  }

  /// Tap on the shift key: one-shot, or caps lock on a quick second tap.
  void onShiftTap() {
    final now = _clock();
    final quick = now - _lastShiftTapMs <= doubleTapMs;
    _lastShiftTapMs = now;
    _autoShifted = false;
    switch (shift.value) {
      case ShiftState.off:
        shift.value = ShiftState.once;
      case ShiftState.once:
        shift.value = quick ? ShiftState.caps : ShiftState.off;
      case ShiftState.caps:
        shift.value = ShiftState.off;
    }
  }

  void _consumeShift() {
    if (shift.value == ShiftState.once) {
      shift.value = ShiftState.off;
      _autoShifted = false;
    }
  }

  int _capsRequest() {
    final f = field.value;
    final s = settings;
    if (!s.typing.autoCapitalize || !_rules.hasCase || _raw || _sensitive || f.kind != FieldKind.text) return 0;
    var req = 0;
    if (f.capCharacters) req |= AndroidCapsMode.characters;
    if (f.capWords) req |= AndroidCapsMode.words;
    if (f.capSentences) req |= AndroidCapsMode.sentences;
    return req;
  }

  void _applyCaps(int mode) {
    if (mode == 0) {
      if (_autoShifted && shift.value == ShiftState.once) shift.value = ShiftState.off;
      _autoShifted = false;
      return;
    }
    if (mode & AndroidCapsMode.characters != 0) {
      shift.value = ShiftState.caps;
      return;
    }
    if (shift.value == ShiftState.off) {
      shift.value = ShiftState.once;
      _autoShifted = true;
    }
  }

  Future<void> _refreshCaps() async {
    final req = _capsRequest();
    if (req == 0) return;
    final seq = _seq;
    final mode = await _input.getCursorCapsMode(req);
    if (seq != _seq) return;
    _applyCaps(mode & req);
  }

  // ---- Typing -----------------------------------------------------------

  bool _isComposable(String text) {
    if (!_rules.isWordChar(text)) return false;
    if (_composing.isNotEmpty) return true;
    // A word starts with a letter: digits, apostrophes and dashes alone are not words.
    return _isLetter(text);
  }

  /// A character key (already cased by the view) or a popup alternative.
  void onText(String text, {TouchPoint? point}) {
    if (text.isEmpty) return;
    _begin();
    try {
      _lastCorrection = null;
      _lastSwipe = null;
      final single = text.characters.length == 1;
      if (!single) {
        _commitLiteral(text);
      } else if (_composeEnabled && _isComposable(text)) {
        _composing += text;
        _taps.add(KeyTap(text, point));
        _space = _SpaceState.none;
        _send(_input.setComposingText(_composing));
        _updateSuggestions();
      } else if (_composeEnabled) {
        _onSeparator(text);
      } else {
        _commitPlain(text);
      }
      _consumeShift();
    } finally {
      _end();
    }
  }

  void _commitPlain(String text) {
    _send(_input.commitText(text));
    _mirrorAppend(text);
    _space = _SpaceState.none;
  }

  /// Multi-character outputs such as ".com" or "R$".
  void _commitLiteral(String text) {
    if (_composing.isNotEmpty) _commitComposingAsTyped();
    _commitPlain(text);
    _updateSuggestions();
  }

  bool _canAutoCorrect(String word) {
    if (!settings.typing.autoCorrect || !field.value.allowsAutoCorrect || _sensitive) return false;
    if (_noCorrectionWord == word) return false;
    if (word.characters.any(_isDigit)) return false;
    // Never touch handles, tags, paths and camelCase tokens.
    final before = _prevChar;
    if (before == '@' || before == '#' || before == '/') return false;
    if (RegExp(r'\p{Ll}\p{Lu}', unicode: true).hasMatch(word)) return false;
    return true;
  }

  void _learn(String word) {
    if (word.isEmpty) return;
    _predictor.onWordCommitted(word, previousWords: List.of(_previous), allowLearning: learningAllowed);
    _pushPrevious(word);
  }

  /// Leaves the composing word in the editor as typed.
  void _commitComposingAsTyped() {
    final word = _composing;
    if (word.isEmpty) return;
    _composing = '';
    _taps.clear();
    _send(_input.finishComposingText());
    _mirrorAppend(word);
    _learn(word);
    _lastResult = SuggestionResult.empty;
  }

  void _onSeparator(String sep) {
    if (sep == ' ') {
      _onSpaceInner();
      return;
    }
    final rules = _rules;
    final smart = _smartField && settings.typing.smartPunctuation;
    final hadComposing = _composing.isNotEmpty;
    var out = sep;
    var deleteBefore = 0;
    var nextSpace = _SpaceState.none;

    var word = _composing;
    Suggestion? applied;
    if (hadComposing) {
      final corr = _lastResult.autoCorrection;
      if (corr != null && corr.text != word && _canAutoCorrect(word)) {
        applied = corr;
        word = corr.text;
      }
    }

    if (!hadComposing && smart && _space == _SpaceState.autoAfterPick && rules.removesSpaceBefore(sep)) {
      deleteBefore = 1;
      if (rules.addsSpaceAfter(sep)) {
        out = '$sep ';
        nextSpace = _SpaceState.autoAfterPunct;
      }
    } else if (smart) {
      final thin = rules.spaceBefore(sep);
      final lastChar = hadComposing ? word.characters.last : _prevChar;
      if (thin != null && lastChar != null && (rules.isWordChar(lastChar))) out = '$thin$sep';
    }

    final original = _composing;
    if (hadComposing) {
      _composing = '';
      _taps.clear();
      _lastResult = SuggestionResult.empty;
      _send(_input.commitText('$word$out'));
      _mirrorAppend('$word$out');
      _learn(word);
      if (applied != null) {
        _lastCorrection = _Correction(original: original, corrected: word, committedLength: word.length + out.length);
      }
    } else if (deleteBefore > 0) {
      _batch(() {
        _send(_input.deleteSurroundingText(deleteBefore, 0));
        _send(_input.commitText(out));
      });
      _mirrorDeleteUnits(deleteBefore);
      _mirrorAppend(out);
    } else {
      _send(_input.commitText(out));
      _mirrorAppend(out);
    }
    _space = nextSpace;
    if (applied == null) _lastCorrection = null;
    _updateSuggestions();
    unawaited(_refreshCaps());
  }

  /// The space key.
  void onSpace() {
    _begin();
    try {
      _lastCorrection = null;
      _lastSwipe = null;
      if (!_composeEnabled) {
        _commitPlain(' ');
      } else {
        _onSpaceInner();
      }
      if (page.value.isSymbols) page.value = KeyboardPage.letters;
      _consumeShift();
    } finally {
      _end();
    }
  }

  void _onSpaceInner() {
    final s = settings.typing;
    final hadComposing = _composing.isNotEmpty;
    if (!hadComposing && _space == _SpaceState.autoAfterPunct) return;

    // Double space becomes ". ".
    if (!hadComposing &&
        s.doubleSpacePeriod &&
        _smartField &&
        (_space == _SpaceState.typedAfterWord || _space == _SpaceState.autoAfterPick) &&
        _before.endsWith(' ') &&
        _charBeforeLastSpaceIsWord()) {
      _batch(() {
        _send(_input.deleteSurroundingText(1, 0));
        _send(_input.commitText('. '));
      });
      _mirrorDeleteUnits(1);
      _mirrorAppend('. ');
      _space = _SpaceState.autoAfterPunct;
      _updateSuggestions();
      unawaited(_refreshCaps());
      return;
    }

    var word = _composing;
    Suggestion? applied;
    if (hadComposing) {
      final corr = _lastResult.autoCorrection;
      if (corr != null && corr.text != word && _canAutoCorrect(word)) {
        applied = corr;
        word = corr.text;
      }
      final original = _composing;
      _composing = '';
      _taps.clear();
      _lastResult = SuggestionResult.empty;
      _send(_input.commitText('$word '));
      _mirrorAppend('$word ');
      _learn(word);
      _lastCorrection = applied == null
          ? null
          : _Correction(original: original, corrected: word, committedLength: word.length + 1);
      _space = _SpaceState.typedAfterWord;
    } else {
      final prev = _prevChar;
      _send(_input.commitText(' '));
      _mirrorAppend(' ');
      _space = prev != null && prev != ' ' && prev != '\n' && (_rules.isWordChar(prev))
          ? _SpaceState.typedAfterWord
          : _SpaceState.none;
    }
    _updateSuggestions();
    unawaited(_refreshCaps());
  }

  bool _charBeforeLastSpaceIsWord() {
    final chars = _before.characters;
    if (chars.length < 2) return false;
    final c = chars.skipLast(1).last;
    return _rules.isWordChar(c);
  }

  /// The enter / action key.
  void onEnter() {
    _begin();
    try {
      _lastCorrection = null;
      _lastSwipe = null;
      _commitComposingAsTyped();
      final f = field.value;
      if (_raw) {
        _send(_input.sendDownUpKeyEvent(AndroidKeyCode.enter));
      } else if (f.enterInsertsNewline) {
        _send(_input.commitText('\n'));
        _mirrorAppend('\n');
      } else {
        _send(_input.performEditorAction(f.editorActionId));
      }
      _space = _SpaceState.none;
      _updateSuggestions();
      unawaited(_refreshCaps());
    } finally {
      _end();
    }
  }

  /// Long-press on enter in a multi-line field.
  void onEnterLongPress() {
    final f = field.value;
    if (_raw || !f.enterInsertsNewline || f.editorActionId == 0) return;
    _begin();
    try {
      _commitComposingAsTyped();
      _send(_input.performEditorAction(f.editorActionId));
    } finally {
      _end();
    }
  }

  // ---- Backspace --------------------------------------------------------

  void onBackspace() {
    _begin();
    try {
      _space = _SpaceState.none;
      if (_raw) {
        _send(_input.sendDownUpKeyEvent(AndroidKeyCode.del));
        return;
      }
      if (_composing.isNotEmpty) {
        _lastCorrection = null;
        _lastSwipe = null;
        _composing = _composing.characters.skipLast(1).string;
        if (_taps.isNotEmpty) _taps.removeLast();
        if (_composing.isEmpty) {
          _send(_input.commitText(''));
        } else {
          _send(_input.setComposingText(_composing));
        }
        _updateSuggestions();
        return;
      }
      final corr = _lastCorrection;
      if (corr != null) {
        _revertCorrection(corr);
        return;
      }
      final swipe = _lastSwipe;
      if (swipe != null) {
        _deleteSwipe(swipe);
        return;
      }
      _send(_input.sendDownUpKeyEvent(AndroidKeyCode.del));
      if (_before.isNotEmpty) _before = _before.characters.skipLast(1).string;
      _afterPlainDelete();
    } finally {
      _end();
    }
  }

  void _afterPlainDelete() {
    _updateSuggestions();
    unawaited(_resyncContext());
  }

  void _revertCorrection(_Correction c) {
    _lastCorrection = null;
    _batch(() {
      _send(_input.deleteSurroundingText(c.committedLength, 0));
      _send(_input.setComposingText(c.original));
    });
    _mirrorDeleteUnits(c.committedLength);
    _composing = c.original;
    _taps
      ..clear()
      ..addAll([for (final ch in c.original.characters) KeyTap(ch)]);
    _noCorrectionWord = c.original;
    _predictor.onAutoCorrectionReverted(original: c.original, correction: c.corrected);
    _updateSuggestions();
  }

  void _deleteSwipe(_SwipeRecord s) {
    _lastSwipe = null;
    final n = s.leading.length + s.bodyLength;
    _send(_input.deleteSurroundingText(n, 0));
    _mirrorDeleteUnits(n);
    if (_previous.isNotEmpty) _previous = _previous.sublist(0, _previous.length - 1);
    _updateSuggestions();
    unawaited(_resyncContext());
  }

  /// Backspace held for a long time: deletes a whole word (Wave 2 also uses this for swipe-to-delete).
  void deleteWordBackward() {
    _begin();
    try {
      _space = _SpaceState.none;
      _lastCorrection = null;
      _lastSwipe = null;
      if (_composing.isNotEmpty) {
        _composing = '';
        _taps.clear();
        _send(_input.commitText(''));
        _updateSuggestions();
        return;
      }
      if (_raw || _before.isEmpty) {
        _send(_input.sendDownUpKeyEvent(AndroidKeyCode.del));
        return;
      }
      final rules = _rules;
      final chars = _before.characters.toList();
      var i = chars.length;
      while (i > 0 && chars[i - 1].trim().isEmpty) {
        i--;
      }
      if (i > 0) {
        final wordy = rules.isWordChar(chars[i - 1]);
        while (i > 0 && chars[i - 1].trim().isNotEmpty && rules.isWordChar(chars[i - 1]) == wordy) {
          i--;
        }
      }
      final units = chars.sublist(i).join().length;
      if (units == 0) {
        _send(_input.sendDownUpKeyEvent(AndroidKeyCode.del));
        return;
      }
      _send(_input.deleteSurroundingText(units, 0));
      _mirrorDeleteUnits(units);
      _afterPlainDelete();
    } finally {
      _end();
    }
  }

  /// The Tab key (hardware-style key event).
  void sendTab() {
    _begin();
    try {
      _commitComposingAsTyped();
      _space = _SpaceState.none;
      _lastCorrection = null;
      _lastSwipe = null;
      _send(_input.sendDownUpKeyEvent(AndroidKeyCode.tab));
    } finally {
      _end();
    }
  }

  /// Moves the cursor by [delta] characters (hook for Wave 2's space-bar cursor control).
  void moveCursor(int delta) {
    if (delta == 0) return;
    _begin();
    try {
      _commitComposingAsTyped();
      _space = _SpaceState.none;
      _lastCorrection = null;
      _lastSwipe = null;
      final key = delta < 0 ? AndroidKeyCode.dpadLeft : AndroidKeyCode.dpadRight;
      for (var i = 0; i < delta.abs(); i++) {
        _send(_input.sendDownUpKeyEvent(key));
      }
    } finally {
      _end();
    }
    unawaited(_resyncContext());
  }

  // ---- Suggestions ------------------------------------------------------

  void _setBar(SuggestionBarState s) => bar.value = s;

  /// Recomputes the strip. Call when suggestion-related settings change.
  void refreshSuggestions() => _updateSuggestions();

  void _updateSuggestions() {
    final s = settings.typing;
    if (!_composeEnabled || !s.showSuggestions) {
      _lastResult = SuggestionResult.empty;
      _setBar(SuggestionBarState.empty);
      return;
    }
    if (_composing.isNotEmpty) {
      final result = _predictor.suggest(
        TypingContext(
          composing: _composing,
          taps: List.unmodifiable(_taps),
          previousWords: List.unmodifiable(_previous),
          isStartOfSentence: _startOfSentence,
          field: field.value,
        ),
      );
      _lastResult = result;
      _setBar(
        SuggestionBarState(
          suggestions: result.suggestions,
          autoCorrection: _canAutoCorrect(_composing) ? result.autoCorrection : null,
          isComposing: true,
          typedWordUnknown: !_predictor.isKnownWord(_composing),
        ),
      );
      return;
    }
    _lastResult = SuggestionResult.empty;
    if (s.nextWordPrediction) {
      _setBar(SuggestionBarState(suggestions: _predictor.predictNext(List.of(_previous))));
    } else {
      _setBar(SuggestionBarState.empty);
    }
  }

  /// A tap on a suggestion in the strip.
  void onSuggestionPicked(Suggestion s) {
    if (_sensitive || _raw) return;
    _begin();
    try {
      final swipe = _lastSwipe;
      if (swipe != null && _composing.isEmpty) {
        _replaceSwipe(swipe, s);
        return;
      }
      _lastCorrection = null;
      _lastSwipe = null;
      if (_composing.isNotEmpty) {
        final word = s.text;
        _composing = '';
        _taps.clear();
        _lastResult = SuggestionResult.empty;
        _send(_input.commitText('$word '));
        _mirrorAppend('$word ');
        _learn(word);
      } else {
        final prev = _prevChar;
        final lead = prev != null && prev != ' ' && prev != '\n' && _rules.isWordChar(prev) ? ' ' : '';
        _send(_input.commitText('$lead${s.text} '));
        _mirrorAppend('$lead${s.text} ');
        _learn(s.text);
      }
      _space = _SpaceState.autoAfterPick;
      _consumeShift();
      _updateSuggestions();
      unawaited(_refreshCaps());
    } finally {
      _end();
    }
  }

  void _replaceSwipe(_SwipeRecord swipe, Suggestion pick) {
    var text = pick.text;
    if (text == swipe.word) return;
    final first = swipe.word.characters.isEmpty ? '' : swipe.word.characters.first;
    if (first.isNotEmpty && first != first.toLowerCase() && text.isNotEmpty) {
      final chars = text.characters;
      text = '${chars.first.toUpperCase()}${chars.skip(1)}';
    }
    _batch(() {
      _send(_input.deleteSurroundingText(swipe.bodyLength, 0));
      _send(_input.commitText('$text '));
    });
    _mirrorDeleteUnits(swipe.bodyLength);
    _mirrorAppend('$text ');
    if (_previous.isNotEmpty) _previous = _previous.sublist(0, _previous.length - 1);
    _learn(text);
    _lastSwipe = _SwipeRecord(leading: swipe.leading, word: text, candidates: swipe.candidates);
    _setBar(SuggestionBarState(suggestions: _lastSwipe!.candidates, fromSwipe: true));
  }

  // ---- Gesture typing ---------------------------------------------------

  /// Decodes and commits a swiped path. Safe to call without checking the
  /// field: sensitive and raw fields ignore it.
  Future<void> commitSwipe(GesturePath path) async {
    if (_sensitive || _raw || !settings.swipe.enabled) return;
    final candidates = await _decoder.decode(path, previousWords: List.of(_previous));
    if (candidates.isEmpty) return;
    _begin();
    try {
      _lastCorrection = null;
      if (_composing.isNotEmpty) _commitComposingAsTyped();
      var word = candidates.first.text;
      switch (shift.value) {
        case ShiftState.once:
          final chars = word.characters;
          if (chars.isNotEmpty) word = '${chars.first.toUpperCase()}${chars.skip(1)}';
        case ShiftState.caps:
          word = word.toUpperCase();
        case ShiftState.off:
          break;
      }
      final prev = _prevChar;
      final needsLead = prev != null && (_isLetter(prev) || _isDigit(prev) || _rules.addsSpaceAfter(prev));
      final lead = needsLead ? ' ' : '';
      _send(_input.commitText('$lead$word '));
      _mirrorAppend('$lead$word ');
      _learn(word);
      _space = _SpaceState.autoAfterPick;
      _lastSwipe = _SwipeRecord(leading: lead, word: word, candidates: candidates);
      _consumeShift();
      _setBar(SuggestionBarState(suggestions: candidates, fromSwipe: true));
      unawaited(_refreshCaps());
    } finally {
      _end();
    }
  }

  void dispose() {
    field.dispose();
    shift.dispose();
    page.dispose();
    bar.dispose();
  }
}
