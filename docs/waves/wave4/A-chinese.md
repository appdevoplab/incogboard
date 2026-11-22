# Wave 4-A: Chinese (pinyin)

Read `docs/waves/wave4/COMMON.md` first. Plan sections: "Languages" (the zh row), "Suggestions, autocorrect and learning", "Performance budgets" (CJK conversion update < 30 ms p95; memory with CJK + voice < 250 MB).

## Ownership

**You own:**
- `lib/src/engine/lang/chinese.dart`, plus anything under `lib/src/engine/lang/chinese/` (segmenter, lattice, dictionary reader, OpenCC converter).
- `lib/src/features/chinese/**` (keep `createChineseFeature()`).
- `lib/src/app/chinese/**` (keep `ChineseScreen`), and optional fields in `lib/src/settings/sections/chinese_settings.dart`.
- `assets/layouts/pinyin_zh.json` (the seed is yours to change).
- `tool/chinese/**` (data conversion) and `tool/packs/chinese/**` (staging script).
- `docs/notices/chinese.md`.
- Tests: `test/engine/lang/chinese/**`, `test/features/chinese/**`, `test/app/chinese/**`, `test/tool/chinese/**`.

The learned-phrases blob is `learned_zh_phrases` (through `SecureBlobStore`; the orchestrator registers it for wipe and backup).

Write the settings screen's strings in plain English (Agent C localises the rest of the app at the same time; the orchestrator moves your strings into the ARB files after the merge).

## How Chinese typing works

The `pinyin_zh` layout is QWERTY letters with Chinese punctuation (`，` `。` and a popup with `'` as the syllable separator). `LayoutChoice.composes` is true, so nothing is blended with it.

`createChineseFeature()` listens to `session.activeLanguage` and the settings. While the active language is 'zh' and `session.activeLayout.composes`, it sets `session.input.composer.value` to your `PinyinComposer` (a `TextComposer`); otherwise, if the composer is yours, it sets it back to null. The controller does the routing, the strip, the grid and the editor calls (see `composer.dart`).

## Build

### 1. Dictionary pack (`dict-zh-rime-ice`)

- Source: **rime-ice** (雾凇拼音, https://github.com/iDvel/rime-ice, GPL-3.0; record the commit or tag): the base, ext and tencent word lists (word, pinyin, weight). Add **OpenCC** (https://github.com/BYVoid/OpenCC, Apache-2.0) phrase and character tables for Simplified → Traditional (Taiwan standard, `s2twp`).
- `tool/chinese/` converts them into your own compact, documented binary format: a pinyin syllable trie (or sorted syllable-sequence table) → words with frequencies, plus single-character readings, plus the OpenCC tables. Prefix and abbreviation lookups must work without loading everything into Dart objects (memory-map style reads with `RandomAccessFile` or one `Uint8List`).
- Budget: at most 40 MB for the pack, about 300 to 600k words; say the size and word count in your report.
- `tool/packs/chinese/stage_rime_ice.ps1` downloads the sources, runs the converter and lays the files out under `%USERPROFILE%\.kosha\packs\staging\dict-zh-rime-ice\`. Then it prints the `tool/make_pack.dart --kind dictionary --id dict-zh-rime-ice --languages zh --engine rime-ice --license GPL-3.0-or-later ...` line for the orchestrator.
- At runtime: `InstalledPacks(session.services.platform).open('zh', engine: 'rime-ice')` gives the folder. Load off the UI isolate. Re-check on `DataSections.packs` notifications (a pack was installed or deleted).

### 2. The pinyin composer

- **Segmentation:** split the letters into syllables with a lattice over the dictionary (Viterbi by word frequency). Examples: "xian" is 西安 or 先 (both kept), "nihao" → 你好, "zhongguoren" → 中国人. Show the segmented reading in `ComposerState.reading` ("zhong'guo'ren"); the user's `'` forces a break.
- **Abbreviations:** initials only ("nh" → 你好, "zgr" → 中国人).
- **Fuzzy pinyin** (`settings.chinese.fuzzyPinyin`): z/zh, c/ch, s/sh, n/l, an/ang, en/eng, in/ing.
- **Candidates:** whole-buffer phrases first, then shorter prefixes and single characters (`ComposerCandidate.consumes` says how many letters each one converts). Picking a prefix commits it and leaves the rest composing. Space commits the highlighted candidate, enter commits the letters, backspace removes the last letter.
- **Punctuation:** with an empty buffer, `,` `.` `?` `!` `:` `;` `(` `)` `"` commit their full-width forms (`，` `。` `？` `！` `：` `；` `（` `）` `“”` alternating). With a buffer, commit the best candidate first.
- **Predictions (联想):** after a commit, offer up to 10 likely next words from the dictionary's bigram data (if rime-ice has none, skip it and say so), with an empty preedit.
- **Traditional output** (`settings.chinese.traditional`): convert every candidate through OpenCC before showing it.
- **Learning:** count picked phrases and new multi-character words built from several picks, and rank them up (only when `learningAllowed`). Store them in `learned_zh_phrases`, encrypted.
- **No pack installed:** the composer stays off and letters type as English, and the feature shows a chip with `session.showChip(StripChip(...))` ("Chinese needs a dictionary pack"; tapping it calls `session.services.host.openSettings(KoshaRoutes.packs)`).
- Budget: under 30 ms p95 per key with the full dictionary on a mid-range phone. Measure on this PC and report the median and p95 per key.

### 3. Chinese settings screen

`ChineseScreen`: Traditional output, fuzzy pinyin (with what it accepts), the pack status (installed name and size, or a button to `KoshaRoutes.packs`), and "clear learned phrases".

## Tests

- Segmentation and conversion on a fixture dictionary under `test/` (a few hundred words): "nihao", "xian", "zhongguoren", "nh", "zgr", fuzzy pairs, `'` breaks, partial picks.
- A golden corpus: 300 common phrases with their pinyin, built from the real data by `tool/chinese/` and checked in as a small text file. Top-1 accuracy ≥ 85% and top-5 ≥ 95% when the staged pack exists (skip the test otherwise, like the voice tests do).
- The feature sets and clears the composer as the language changes; no composer in password and URL fields; the no-pack chip.
- Punctuation, predictions, Traditional output and learning (with an `InMemorySecureBlobStore`).

## Report extras

- Pack size, word count, load time and memory after load. Per-key median and p95.
- What to check on the emulator: "nihao" → 你好, "zhongguoren", "nh", a partial pick, Traditional output, full-width punctuation, and the grid.
