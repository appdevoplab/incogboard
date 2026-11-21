# Text engine: third-party data

## English dictionary (`assets/dict/en.mdict`)

**What it is.** A compact binary dictionary (Myna's own `MDICT` format) built by `tool/build_dictionary.dart` from the
AOSP LatinIME English (US) word list: about 147k words with frequencies, flags for possibly offensive words, a list of
always-applied apostrophe corrections, and about 344k "next word" pairs.

**Source of the word list.**
- Original: AOSP LatinIME `dictionaries/en_US_wordlist.combined.gz`
  (`https://android.googlesource.com/platform/packages/inputmethods/LatinIME/`, branch `main`, tip checked on
  2026-11-21 was commit `127336e9f29d69607eab55982324b210279ae8c5`). That file has the same 160k-word list but no next-word
  pairs.
- Actually used as the build input: `wordlists/main_en_US.combined` from
  `https://codeberg.org/Helium314/aosp-dictionaries` (branch `main`, downloaded 2026-11-21). Its source is
  OpenBoard v1.4.5 `en_wordlist.combined.gz` (`https://github.com/openboard-team/openboard/blob/v1.4.5/dictionaries/en_wordlist.combined.gz`),
  which is the AOSP list with the next-word pairs that the current AOSP file lacks. The word set is identical
  (160,715 words); we used it for the pairs.

**License.** The word list is part of the Android Open Source Project, licensed under the Apache License 2.0
(LatinIME `NOTICE`: "Copyright (c) 2008, The Android Open Source Project ... Licensed under the Apache License, Version
2.0"). Apache-2.0 is compatible with GPL-3.0-or-later. The Helium314 mirror lists no additional license for this
"legacy" list; its repository is GPL-3.0.

**Attribution.** Copyright (c) 2008, The Android Open Source Project, Apache License 2.0
(`https://www.apache.org/licenses/LICENSE-2.0`). Modified: words were NFC-normalised and cleaned (URLs, digits and
stray punctuation removed), capped to 150k words by frequency, accent-folded keys merged, frequencies converted to
log probabilities, and a list of common English contractions was added.

**Alternative evaluated (not used).** HeliBoard `main_en_US__experimental.combined` (CC BY 4.0, 280k words) is
available if a larger or more modern list is wanted later.

## Code and tables

- `lib/src/engine/dictionary/text_fold.dart` contains a Latin decomposition table generated from the Unicode Character
  Database (Unicode License v3, https://www.unicode.org/license.txt). No Unicode data files are shipped.
