# Wave 1-B: English text engine

Read `docs/waves/wave1/COMMON.md` first.

**Plan sections to read:**
- Suggestions, autocorrect and learning
- Do more languages make it slow?
- Performance budgets
- Languages

**Contracts to study:**
- From `contracts.dart`: `Lexicon`, `LexiconSource`, `TextPredictor`, `TypingContext`, `KeyTap`, `KeyboardGeometry` and `Suggestion*`.
- `in_memory_lexicon.dart`
- `secure_blob_store.dart`
- `pack_repository.dart`
- `input_field_info.dart`

## Ownership

**You own:**
- `lib/src/engine/dictionary/**`
- `lib/src/engine/suggest/**`
- `lib/src/engine/learn/**`
- `tool/build_dictionary.dart`
- `assets/dict/**` (already declared in pubspec)
- `test/engine/text/**`
- `docs/notices/text_engine.md`

Keep the factory signatures in `lexicon_factory.dart` and `predictor_factory.dart`.

## Build

### 1. Data

You need an English word list with frequencies and bigrams, under a GPL-3-compatible license.

- **First choice:** AOSP LatinIME `dictionaries/en_US_wordlist.combined.gz`. It is Apache-2.0 as part of AOSP; verify this via the LatinIME repo's NOTICE/LICENSE and record it.
  - Download from `https://android.googlesource.com/platform/packages/inputmethods/LatinIME/+/refs/heads/main/dictionaries/en_US_wordlist.combined.gz?format=TEXT`.
  - The response is base64. Try `master` if `main` fails.
- **If the licensing is unclear:** use HeliBoard's English list marked CC BY 4.0 (`https://codeberg.org/Helium314/aosp-dictionaries`).

Keep raw downloads out of git (`tool/out/` is gitignored) and commit only the built asset. Record the source URL, revision, license and attribution in `docs/notices/text_engine.md`.

### 2. Builder: `tool/build_dictionary.dart`

Usage: `dart run tool/build_dictionary.dart --input <file> --lang en --out assets/dict/en.mdict`

- Parse the `.combined` format: ` word=...,f=...,flags=...,possibly_offensive=true` lines, plus indented ` bigram=...,f=...` children.
- Clean the data:
  - NFC-normalize.
  - Drop junk such as URLs and stray punctuation.
  - Flag offensive words.
- Size limits: keep at most 150k words and the strongest bigrams, with a cap on the total.
- Convert `f` (0–255, log scale) to natural-log probabilities.
- Write a compact, versioned binary format, documented in a header comment.
- Target asset size: 4 MB or less. Compression is allowed (`dart:io` ZLibCodec).

### 3. Runtime reader

- Keep it memory-efficient: a single `Uint8List`, with no per-word objects beyond what's needed.
- Implement the `Lexicon` contract, plus:
  - fast prefix enumeration
  - exact lookup with a case-insensitive fallback
  - bigram lookup
- `createLexiconSource({packs})` loads `dict/<lang>.mdict` via `PackRepository`, and handles caching and eviction.
- Load in under 300 ms on desktop. Report memory use.

### 4. Predictor: `createTextPredictor(...)` implementing `TextPredictor`

**Spatial model** (from `setGeometry`):
- Per-tap key likelihood from a 2-D Gaussian around key centres, with σ ≈ 0.45 key width.
- Use `KeyTap.point` when present, otherwise the exact key.

**Candidate search** over the trie:
- Beam search with neighbour-weighted substitution, insertion, deletion and transposition, up to 2 edits.
- Prefix completions.
- Merge up to 3 active languages.

**Scoring:** spatial log-likelihood + λ·language model (unigram + bigram on `previousWords`, with stupid backoff) + a learned prior. Return up to 8 suggestions, including the typed word (kind `typed`) when sensible.

**`autoCorrection`, only when confident:**
- Require a margin over the typed word.
- Never correct a known typed word, unless it is far rarer AND the spatial match is very strong.
- Never correct tokens containing digits, @, #, '/' or '.', camelCase tokens, or 1-letter tokens.
- Preserve case: Hello and HELLO patterns.
- Handle contractions: dont→don't, im→I'm, youre→you're.

**`predictNext(previousWords)`:** bigram continuations plus learned n-grams.

**Learning** (only when `allowLearning`):
- A new word becomes known after 2 commits.
- Keep personal unigram and bigram counts with time decay.
- Never learn high-entropy or credential-like strings.
- Support `blockWord`, `forgetWord`, `learnedWords(lang)` (used by the gesture decoder) and `clearLearnedData()`.
- Persist encrypted via `SecureBlobStore` under the name `learned_<lang>`, with a debounce. `flush()` persists immediately.

**Speed:** `suggest()` p95 under 3 ms on desktop with 150k words (8 ms budget on phones). Write a benchmark test that prints p50 and p95. `trimMemory()` drops caches.

## Tests (`test/engine/text/`)

- **Corrections:** teh→the, helo→hello, thnaks→thanks, recieve→receive, adress→address.
- **Spatial:** taps near g for "gello" → hello.
- **Completions.**
- **Bigram prediction:** thank → you.
- **Case and contractions.**
- **No correction** for URLs, emails or digits.
- **Learning round-trip** via `InMemorySecureBlobStore`, with nothing learned when `allowLearning` is false.
- **Blocklist.**
- **Offensive words** are never auto-suggested.
- **Builder/reader** round-trip.
