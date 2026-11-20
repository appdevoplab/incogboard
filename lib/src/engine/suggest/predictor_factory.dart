// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 1-B (suggestions engine). Wave 0 placeholder: prefix completion
// over the lexicon, no autocorrect, no learning.
import '../../core/secure_blob_store.dart';
import '../../packs/pack_repository.dart';
import '../contracts.dart';

TextPredictor createTextPredictor({
  required PackRepository packs,
  required LexiconSource lexicons,
  required SecureBlobStore store,
}) => _PrefixPredictor(lexicons);

class _PrefixPredictor implements TextPredictor {
  _PrefixPredictor(this._lexicons);

  final LexiconSource _lexicons;
  final List<Lexicon> _active = [];

  @override
  Future<void> setActiveLanguages(List<LanguageId> languages) async {
    _active
      ..clear()
      ..addAll([for (final l in languages.take(3)) await _lexicons.load(l)]);
  }

  @override
  void setGeometry(KeyboardGeometry geometry) {}

  @override
  SuggestionResult suggest(TypingContext context) {
    final prefix = context.composing.toLowerCase();
    if (prefix.isEmpty) return SuggestionResult.empty;
    final out = <Suggestion>[Suggestion(context.composing, kind: SuggestionKind.typed)];
    for (final lexicon in _active) {
      for (final e in lexicon.entries()) {
        if (e.word.startsWith(prefix) && e.word != prefix) {
          out.add(Suggestion(e.word, kind: SuggestionKind.completion, score: e.logProb, language: lexicon.language));
          if (out.length >= 4) break;
        }
      }
    }
    return SuggestionResult(suggestions: out);
  }

  @override
  List<Suggestion> predictNext(List<String> previousWords, {int max = 3}) => const [];

  @override
  bool isKnownWord(String word) => _active.any((l) => l.logProb(word) != null);

  @override
  void onWordCommitted(String word, {required List<String> previousWords, required bool allowLearning}) {}

  @override
  void onAutoCorrectionReverted({required String original, required String correction}) {}

  @override
  void blockWord(String word) {}

  @override
  void forgetWord(String word) {}

  @override
  Iterable<LexiconEntry> learnedWords(LanguageId language) => const [];

  @override
  Future<void> flush() async {}

  @override
  Future<void> clearLearnedData() async {}

  @override
  void trimMemory() {}
}
