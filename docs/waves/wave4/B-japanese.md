# Wave 4-B: Japanese (romaji and 12-key flick)

Read `docs/waves/wave4/COMMON.md` first. Plan sections: "Languages" (the ja row), "Suggestions, autocorrect and learning", "Performance budgets" (CJK conversion update < 30 ms p95; memory with CJK + voice < 250 MB).

## Ownership

**You own:**
- `lib/src/engine/lang/japanese.dart`, plus anything under `lib/src/engine/lang/japanese/` (romaji table, kana tools, lattice, dictionary reader).
- `lib/src/features/japanese/**` (keep `createJapaneseFeature()`).
- `lib/src/app/japanese/**` (keep `JapaneseScreen`), and optional fields in `lib/src/settings/sections/japanese_settings.dart`.
- `assets/layouts/kana12_ja.json` and `romaji_ja.json` (the seeds are yours to change), plus a Japanese symbols page if you need one (`assets/layouts/symbols_ja.json`; ask in your report for it to be wired).
- `tool/japanese/**` (data conversion) and `tool/packs/japanese/**` (staging script).
- `docs/notices/japanese.md`.
- Tests: `test/engine/lang/japanese/**`, `test/features/japanese/**`, `test/app/japanese/**`, `test/tool/japanese/**`.

The learned-words blob is `learned_ja_words` (through `SecureBlobStore`; the orchestrator registers it for wipe and backup).

Write the settings screen's strings in plain English (Agent C localises the rest of the app at the same time).

## How Japanese typing works

Two layouts, both `composes: true`:
1. **12-key** (`kana12_ja`, default): flick keys (centre あ, left い, up う, right え, down お; the view already handles flicks and shows the guide), multi-tap cycling (tapping あ again within 1 s gives い, unless `settings.japanese.flickOnly`), `kana_modifier` (か→が, は→ば→ぱ→は, つ→っ→づ, や→ゃ), `undo_cycle`, cursor keys and a globe key.
2. **Romaji** (`romaji_ja`): QWERTY; "nihongo" → にほんご, "kya" → きゃ, "tt" → っ, "n'" and "nn" → ん, "-" → ー.

`createJapaneseFeature()` sets `session.input.composer.value` to your `JapaneseComposer` while the active language is 'ja' and its layout composes, and clears it otherwise. One composer serves both layouts. Read the active layout id to know whether letters are romaji or kana.

## Build

### 1. Dictionary pack (`dict-ja-mozc`)

- Source: the **Mozc** open-source dictionary (https://github.com/google/mozc, `src/data/dictionary_oss/`: `dictionary*.txt`, `connection_single_column.txt`, `id.def`, `suffix.txt`; record the commit). Licence: BSD-3-Clause, plus the IPAdic-derived terms in `dictionary_oss/README.txt`. Copy both licence texts into `docs/notices/japanese.md`. The romaji table (`src/data/preedit/romanji-hiragana.tsv`, BSD-3) may go in the app itself as a small asset or as Dart code.
- `tool/japanese/` converts them into your own compact, documented binary format: a reading (hiragana) trie → (surface, left id, right id, cost) entries, and the connection cost matrix (left × right id). Store the matrix compactly (Int16, and drop or merge rare ids if it is too big).
- Budget: at most 45 MB for the pack; say the size and entry count in your report.
- `tool/packs/japanese/stage_mozc.ps1` downloads, converts and lays out `%USERPROFILE%\.kosha\packs\staging\dict-ja-mozc\`, then prints the `tool/make_pack.dart --kind dictionary --id dict-ja-mozc --languages ja --engine mozc --license BSD-3-Clause ...` line.
- At runtime: `InstalledPacks(session.services.platform).open('ja', engine: 'mozc')`. Load off the UI isolate; re-check on `DataSections.packs`.

### 2. The Japanese composer

- **Kana input:** the preedit is hiragana while typing. Candidates while typing are predictions: dictionary words starting with the reading, best first.
- **Conversion:** space converts the reading with a Viterbi pass over the lattice (word costs + connection costs) into segments. The preedit shows the converted text. Each segment has its own candidates (`ComposerState.candidates` = the focused segment's; the reading line shows the segment reading). Space again moves to the next candidate of the focused segment, and enter commits everything.
  - `ComposerKeys.cursorLeft`/`cursorRight` move the focused segment.
  - `segmentShorter`/`segmentLonger` resize it (add a small button pair for them in the strip's reading area if you need one; ask in the report, since the strip is orchestrator-owned).
- **Always offer** the hiragana, the katakana (ニホンゴ) and, for ASCII input, half-width and full-width forms as candidates.
- **Punctuation:** `、` `。` `「」` `・` `ー` `？` `！`. Space with an empty buffer types a full-width space (U+3000), or a half-width one with `settings.japanese.halfWidthSpace`.
- **Learning:** picked segment conversions rank up next time (only when `learningAllowed`), stored in `learned_ja_words`.
- **No pack installed:** kana still types (hiragana and katakana candidates only), and a chip says "Japanese needs a dictionary pack for kanji" and opens `KoshaRoutes.packs` (`session.showChip`, `session.services.host.openSettings`).
- Budget: under 30 ms p95 per key and per conversion of 20 kana, with the full dictionary on a mid-range phone. Measure on this PC and report the median and p95.

### 3. Japanese settings screen

`JapaneseScreen`: flick only (no multi-tap), half-width space, the default layout (12-key or romaji; write `languages.layouts['ja']`), the pack status, and "clear learned words".

## Tests

- Romaji → kana table cases (sokuon, youon, "n" rules, "-"), 12-key multi-tap, flick-only mode, `kana_modifier` cycles, `undo_cycle`.
- Conversion on a fixture dictionary and matrix under `test/`: "きょうはいいてんきです" → 今日はいい天気です, segment move and resize, katakana candidate.
- A golden corpus of 300 sentences (reading → expected text) built from real data by `tool/japanese/`. Top-1 sentence accuracy ≥ 70% and per-segment top-5 ≥ 95% when the staged pack exists (skip otherwise).
- The feature sets and clears the composer; no composer in password and URL fields; the no-pack chip.

## Report extras

- Pack size, entry count, matrix size, load time and memory after load. Per-key and per-conversion median and p95.
- What to check on the emulator: flick あ row, multi-tap, ゛゜小 on か and は, romaji "nihongo" with conversion, segment moves with the cursor keys, the grid, and full-width space.
