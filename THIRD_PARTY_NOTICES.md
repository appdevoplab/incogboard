# Third-party notices

Myna is GPL-3.0-or-later. It includes or builds on the following. Every bundled data source must be listed here with its license and attribution, and also shown in the app's About → Licenses screen.

## Code

| Component | License | Use |
|---|---|---|
| Flutter engine and framework | BSD-3-Clause | UI runtime |
| material_ui | BSD-3-Clause | Material widgets (settings app) |
| flutter_riverpod | MIT | State management |
| path_provider | BSD-3-Clause | App directories |
| collection, meta, characters | BSD-3-Clause | Dart utilities |
| pigeon (build-time only) | BSD-3-Clause | Kotlin and Dart bridge generation |
| androidx.autofill:autofill 1.3.0 | Apache-2.0 | Styles the inline autofill chips from password managers (Android 11+). UI helpers only: no network code, no permissions, no native code. Source: https://maven.google.com, code at https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/autofill/ |
| kotlinx-coroutines-android 1.9.0 | Apache-2.0 | Runs Pigeon's async Kotlin handlers. Copyright JetBrains s.r.o. (https://github.com/Kotlin/kotlinx.coroutines) |
| image_picker | BSD-3-Clause | Android Photo Picker for theme backgrounds (no storage permission) |
| local_auth | BSD-3-Clause | BiometricPrompt app lock |
| junit:junit 4.13.2 (tests only, not in the APK) | EPL-1.0 | JVM unit tests under `android/app/src/test` |

## Data

| Data | License | Attribution |
|---|---|---|
| English dictionary (`assets/dict/en.mdict`) | Apache-2.0 | Copyright (c) 2008, The Android Open Source Project (Wave 1-B, details below) |
| Latin accent-fold table in `lib/src/engine/dictionary/text_fold.dart` | Unicode License v3 | Generated from the Unicode Character Database, Unicode, Inc. (https://www.unicode.org/license.txt). No Unicode data files are shipped. |
| Google Sans Flex font (`assets/fonts/GoogleSansFlex.ttf`) | SIL OFL 1.1 | Copyright 2015 Google LLC / The Google Sans Flex Authors (Wave 1-D, details below) |
| Emoji list and CLDR annotations (`assets/emoji/`) | Unicode License v3 | (c) Unicode, Inc. (Wave 2-D, details below) |

### English dictionary

- Built by `tool/build_dictionary.dart` into Myna's own `MDICT` format: about 147k words with frequencies, flags for possibly offensive words, apostrophe corrections and about 344k next-word pairs.
- Original list: AOSP LatinIME `dictionaries/en_US_wordlist.combined.gz` (https://android.googlesource.com/platform/packages/inputmethods/LatinIME/, branch `main`, commit `127336e9f29d69607eab55982324b210279ae8c5` checked 2026-11-21). That file has no next-word pairs.
- Build input actually used: `wordlists/main_en_US.combined` from https://codeberg.org/Helium314/aosp-dictionaries (branch `main`, downloaded 2026-11-21). It comes from OpenBoard v1.4.5 `en_wordlist.combined.gz` (https://github.com/openboard-team/openboard/blob/v1.4.5/dictionaries/en_wordlist.combined.gz), which is the same AOSP word set (160,715 words) plus the next-word pairs.
- License: Apache License 2.0 (LatinIME `NOTICE`), compatible with GPL-3.0-or-later.
- Modifications: NFC-normalised and cleaned (URLs, digits and stray punctuation removed), capped to 150k words by frequency, accent-folded keys merged, frequencies converted to log probabilities, and common English contractions added.

### Google Sans Flex

- Files: `assets/fonts/GoogleSansFlex.ttf` (variable font, axes `opsz`, `wdth`, `wght` 1-1000, `ROND` 0-100, `slnt`) and its licence `assets/fonts/OFL.txt`.
- Version 5.000 (upstream commit `cedf1e9`, 2026-10-09), from https://github.com/google/fonts/tree/main/ofl/googlesansflex (file `GoogleSansFlex[ROND,opsz,slnt,wdth,wght].ttf`). Upstream project: https://github.com/googlefonts/googlesans-flex.
- Integrity: git blob SHA-1 `1d8d8ae5a7c6d0e48312d2a0a478bad92caee73a` (TTF) and `3e50f6cb72e58f01997d1e608195e8fdbc0eb8b4` (`OFL.txt`), identical to google/fonts.
- Bundled unmodified under its own name, so the Reserved Font Name clause is respected. Declared in `pubspec.yaml` as family `GoogleSansFlex`; never downloaded at runtime.
- Non-Latin scripts fall back to the device's Noto fonts.

### Emoji data

- Built offline by `tool/build_emoji.dart` into `assets/emoji/`: `emoji.dat` (2,338 base emoji with English names, Unicode versions and skin-tone variants) and `keywords_<lang>.dat` (keyword index and CLDR short names) for 17 languages: en, es, fr, de, pt, id, hi, mr, bn, ta, te, ar, ur, ru, uk, zh, ja. About 1.8 MB in total.
- Sources: Unicode Emoji 18.0 `emoji-test.txt` (https://unicode.org/Public/emoji/latest/emoji-test.txt, file dated 2026-04-30) and CLDR release-49 `common/annotations` and `annotationsDerived` (https://github.com/unicode-org/cldr/tree/release-49, published 2026-10-21).
- License: Unicode License v3 (https://www.unicode.org/license.txt). Unicode, CLDR and their data are (c) Unicode, Inc.
- Modifications: reshaped only (skin-tone variants grouped under their base emoji, keywords indexed). Never downloaded at runtime.

## Algorithm references (no code copied)

The swipe decoder in `lib/src/engine/gesture/` is an original implementation of ideas from:
- **SHARK²**: P.-O. Kristensson and S. Zhai, "SHARK2: A Large Vocabulary Shorthand Writing System for Pen-Based Computers", ACM UIST 2004. Template matching through key centres, equal arc-length resampling, location and shape channels.
- **FlorisBoard `StatisticalGlideTypingClassifier`** (https://github.com/florisboard/florisboard, Apache-2.0): Gaussian channel likelihoods with a language-model prior, and pruning by first and last key. If any of its code is ever ported, keep the Apache-2.0 notice and attribute it here.

## Test-only data (not shipped in the app)

- `test/engine/gesture/fixtures/en_words.tsv.gz`: the 50,000 most frequent plain entries of AOSP LatinIME `en_US_wordlist.combined` (Apache-2.0, The Android Open Source Project), stored as `word<TAB>frequency` and gzip-compressed. Used only by the gesture accuracy and latency tests.

Rules for adding data:
- Only CC0, CC-BY, Apache-2.0, BSD, MIT, OFL, Unicode or GPL-3-compatible sources.
- "GPLv2-only" and anything non-commercial (NC) are not allowed.
- Record the exact source URL, version and license here before committing the data.
- Each wave's agents write `docs/notices/<area>.md`; the orchestrator folds them into this file after merging and deletes them.
