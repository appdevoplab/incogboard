# Third-party notices

Kosha is GPL-3.0-or-later. It includes or builds on the following. Every bundled data source must be listed here with its license and attribution, and also shown in the app's About → Licenses screen.

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
| onnxruntime-android 1.28.0 | MIT | Inference runtime shared by voice and translation. Copyright Microsoft Corporation (https://github.com/microsoft/onnxruntime). No network code. |
| sherpa-onnx v2.0.1 (`libsherpa-onnx-jni.so` and Kotlin API sources) | Apache-2.0 | Offline speech recognition (Wave 3-D). Copyright Xiaomi Corporation and the k2-fsa authors (https://github.com/k2-fsa/sherpa-onnx). Details in the voice section. |
| org.json 20240303 (tests only, not in the APK) | Public domain (JSON License text) | JVM tests of the pack store |
| onnxruntime 1.28.0 desktop (tests only, not in the APK) | MIT | JVM tests of the translation engine |

## Data

| Data | License | Attribution |
|---|---|---|
| English dictionary (`assets/dict/en.mdict`) | Apache-2.0 | Copyright (c) 2008, The Android Open Source Project (Wave 1-B, details below) |
| Latin accent-fold table in `lib/src/engine/dictionary/text_fold.dart` | Unicode License v3 | Generated from the Unicode Character Database, Unicode, Inc. (https://www.unicode.org/license.txt). No Unicode data files are shipped. |
| Google Sans Flex font (`assets/fonts/GoogleSansFlex.ttf`) | SIL OFL 1.1 | Copyright 2015 Google LLC / The Google Sans Flex Authors (Wave 1-D, details below) |
| Emoji list and CLDR annotations (`assets/emoji/`) | Unicode License v3 | (c) Unicode, Inc. (Wave 2-D, details below) |

### English dictionary

- Built by `tool/build_dictionary.dart` into Kosha's own `MDICT` format: about 147k words with frequencies, flags for possibly offensive words, apostrophe corrections and about 344k next-word pairs.
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

## Wave 3: languages, voice and translation

Model packs (voice and translation) are not part of the APK; each pack carries its own licence in its signed manifest, and the Model packs screen shows it. The sources below are what the packs and bundled dictionaries are built from.

### Third-party notices: European languages (Wave 3-A)

The dictionaries in `assets/dict/{es,fr,de,pt-BR,pt-PT,id,ru,uk}.mdict` are built from word lists by
`tool/build_dictionary.dart`, using `tool/european/prepare_wordlist.py` and `tool/european/build_dictionaries.py`.
The layouts `assets/layouts/{qwerty_es,azerty,qwertz,qwertz_umlaut,jcuken_ru,jcuken_uk}.json` are written by
`tool/european/make_layouts.py` from the shared rows of `qwerty.json`. No network code is involved.

#### Source of the word lists

- **Project:** HeliBoard dictionaries (`aosp-dictionaries`, maintained by Helium314), the `wordlists/*.combined`
  files and their `.source` descriptions.
- **URL:** https://codeberg.org/Helium314/aosp-dictionaries (raw files under `wordlists/`)
- **Retrieved:** 22 November 2026 (the repository's README lists its last update per language).
- **Attribution:** word lists by the Leipzig Corpora Collection (Wortschatz Leipzig), as credited by the
  aosp-dictionaries project.

#### Per language

| Language | Source file | Licence | Words | Bigrams | Size (bytes) |
|---|---|---|---|---|---|
| Spanish (`es`) | `wordlists/main_es__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 70,000 | 70,000 | 1,430,689 |
| French (`fr`) | `wordlists/main_fr__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 62,000 | 60,000 | 1,400,411 |
| German (`de`) | `wordlists/main_de.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 56,000 | 46,000 | 1,438,489 |
| Portuguese, Brazil (`pt-BR`) | `wordlists/main_pt_BR.combined` | See the note below | 70,000 | 0 | 1,296,162 |
| Portuguese, Portugal (`pt-PT`) | `wordlists/main_pt_PT__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 66,000 | 62,000 | 1,432,261 |
| Indonesian (`id`) | `wordlists/main_id__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 58,000 | 38,000 | 1,442,903 |
| Russian (`ru`) | `wordlists/main_ru__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 78,000 | 0 | 1,431,798 |
| Ukrainian (`uk`) | `wordlists/main_uk__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 85,000 | 0 | 1,459,689 |

Every file is under the 1.5 MB budget. Word counts are the words kept after cleaning; the builder drops
junk tokens (for example 436 in Spanish, 12,434 in French). Only the most frequent words are kept, and the
experimental lists also carry next-word (bigram) data, which is kept where it fits the size budget.

##### Portuguese, Brazil: licence to confirm

`main_pt_BR` is the AOSP pt_BR list (2014) as patched by joaohcopetti in
https://github.com/joaohcopetti/aosp-dict-pt-br-patched (grammar corrections with Hunspell). The HeliBoard
`.source` file only says "AOSP dictionary modified". The AOSP project is Apache-2.0, but the repository
states no licence for the patched list, and we did not verify the licence of the underlying word data.
**Before release the orchestrator must confirm this file's licence**, or replace it with a CC BY or CC0 Brazilian
Portuguese list. The build removes 36 words that are Portugal-only from it (for example *autocarro*, *equipa*)
and `pt-PT` removes 29 Brazil-only words (for example *ônibus*, *trem*), so each variant keeps its own vocabulary.

#### Licence summary

- CC BY 4.0: Wortschatz Leipzig word lists, as credited by the HeliBoard project. Attribution is this notice.
- Apache-2.0 / unconfirmed: the pt-BR list (see above).
- GPL-3.0-or-later: the tools in `tool/` and the Dart code in this area.

### Indic data notices (Wave 3-B)

Languages: Hindi (hi), Marathi (mr), Bengali (bn), Tamil (ta), Telugu (te). The data below is built by
`tool/indic/` and shipped in `assets/translit/`, `assets/dict/` and `assets/layouts/`. No model or network code
is involved: everything is a static file in the app.

#### Sources

##### 1. Aksharantar: romanised word pairs

- Project: Aksharantar, AI4Bharat (Madhani et al., 2022, arXiv:2205.03018).
- Source: https://huggingface.co/datasets/ai4bharat/Aksharantar (per-language archives `hin.zip`,
  `mar.zip`, `ben.zip`, `tam.zip`, `tel.zip`; dataset revision `e418c1fc928d9f5393af33268472cf20c1891be8`,
  last modified 2023-08-31). Downloaded 2026-11-22.
- Used: the train, validation and test JSON lines of each language, English (romanised) word and native word.
- Licence: the dataset card states CC0 for the mined data and existing sources, and CC BY 4.0 for the manually
  collected data. Both are accepted by the project's data rules. AI4Bharat is credited.
- Derived: `assets/translit/<lang>.bin` (romanised -> native table; the pairs are reduced to the most frequent
  100,000 entries per language, see `tool/indic/build_data.py`).

##### 2. Wikipedia word frequencies

- Source: Wikipedia "pages-articles" dumps (latest), for hi, mr, bn, ta and te, downloaded 2026-11-22 from
  https://dumps.wikimedia.org/. Articles in the main namespace only; redirects skipped.
- Licence: CC BY-SA 4.0. Only word counts are kept (no text). The derived word lists are therefore shared
  under CC BY-SA 4.0, with attribution to "Wikipedia contributors" and a link to the licence:
  https://creativecommons.org/licenses/by-sa/4.0/
- Derived: `assets/dict/<lang>.mdict` (the 50,000 most frequent words, count at least 3, one dictionary per
  language), and the frequency ranking of the translit table.

##### 3. Inverse romanisation (generated)

Canonical romanised spellings of the frequent Wikipedia words, produced by inverting the rule-based scheme in
`lib/src/engine/lang/indic/scheme.dart` (an original work, GPL-3.0-or-later). No external data.

##### 4. Keyboard layouts (generated)

`assets/layouts/{translit,phonetic,inscript}_<lang>.json` are generated by `tool/indic/make_layouts.py` from the
QWERTY layout and from the letter roles listed in the script. The InScript letter order follows the common
Indian-script keyboard arrangement (the InScript / BIS layout). The layouts contain no third-party artwork.

#### Sizes (this build)

Measured with `ls -l` after the final build (see the report of Wave 3-B for the full table).

| File | Size |
|---|---|
| `assets/translit/<lang>.bin` (gzip) | about 0.8 MB each |
| `assets/dict/<lang>.mdict` | about 1.0 to 1.1 MB each |

Budget: 1.5 MB per file.

#### Tools

- `tool/indic/wiki_counts.py`: word counts from a Wikipedia dump (stdlib only).
- `tool/indic/export_schemes.dart`: prints the romanisation schemes as JSON.
- `tool/indic/build_data.py`: translit tables and `.combined` word lists (needs the Aksharantar JSON and the counts).
- `tool/indic/build_indic_dict.dart`: `.combined` -> `.mdict`. Written instead of `tool/build_dictionary.dart`
  because that tool drops every word of three characters or fewer that "is upper case"; Indic scripts have no
  case, so it would drop common words such as है, और and में.
- `tool/indic/make_layouts.py`: the Indic layouts.

### Arabic and Urdu data notices (Wave 3-C)

Data shipped in `assets/dict/ar.mdict` and `assets/dict/ur.mdict`, and the layouts
`assets/layouts/arabic.json` and `assets/layouts/urdu_phonetic.json` (written by us, no third-party data).

#### ar: Arabic word list

- **Shipped:** `assets/dict/ar.mdict` (80,000 words in the converter, 76,436 after the builder's filter; 46,424 bigrams; 1.40 MB).
- **Source:** HeliBoard's `main_ar__experimental.combined` (next-word data included).
  - URL: https://codeberg.org/Helium314/aosp-dictionaries/raw/branch/main/wordlists/main_ar__experimental.combined
  - Source note: https://codeberg.org/Helium314/aosp-dictionaries/raw/branch/main/wordlists/main_ar__experimental.source
  - Downloaded 2026-11-22.
  - Licence as stated by that source note: "source lists under CC BY 4.0". The lists are derived from the
    Leipzig Corpora Collection (https://wortschatz.uni-leipzig.de/en/download). The Leipzig site could not be
    read from this machine (bot protection), so its licence text was **not checked directly**: verify before release.
- **Not used:** `main_ar.combined` (WikiAndOpenSubtitles). Its OpenSubtitles part has no clear licence.
- **Attribution (CC BY 4.0):** word frequencies and bigrams derived from the Leipzig Corpora Collection, via HeliBoard
  (Helium314 and contributors) aosp-dictionaries.
- **Processing:** `tool/arabic/convert_arabic.dart --source heliboard`. Removes harakat, tatweel and ZWNJ; maps
  Persian yeh and kaf to Arabic ي and ك; keeps only Arabic-script words of 2 to 20 letters; the highest frequency wins
  on duplicates.

#### ur: Urdu word list

- **Shipped:** `assets/dict/ur.mdict` (36,042 words after the builder filter; 656 KB).
- **Source:** the Urdu Wikipedia articles dump (`urwiki-latest-pages-articles.xml.bz2`, downloaded 2026-11-22 from
  https://dumps.wikimedia.org/urwiki/latest/).
  - Licence: Wikipedia text, **CC BY-SA 4.0**. Words and frequencies are extracted; no article text is shipped.
  - Attribution: Urdu Wikipedia contributors (https://ur.wikipedia.org).
- **Not used:** `main_ur.combined` in HeliBoard's list, licensed GPLv2 without "or later" (not usable here).
- **Processing:** `bzip2 -dc <dump> | dart run tool/arabic/convert_arabic.dart --lang ur --source wiki`. Counts Arabic-script
  words, normalises harakat, tatweel and ZWNJ, maps Arabic yeh, alef maqsura and kaf to Urdu ی and ک, and keeps words
  of 2 to 20 letters seen at least 3 times. Frequencies are log-scaled to 1..255.
- **No next-word data** for Urdu (the converter does not compute bigrams).

#### Layouts

`arabic.json` and `urdu_phonetic.json` are original work, under the project licence.

### Voice typing: third-party notices (Wave 3-D)

Everything below ships with the app or is staged for the orchestrator to sign as voice packs. Nothing here
is downloaded by the app; the staging script (`tool/packs/voice/stage_whisper.ps1`) runs on the dev machine only.

#### 1. sherpa-onnx native library and Kotlin API

| Item | Value |
|---|---|
| Project | sherpa-onnx, https://github.com/k2-fsa/sherpa-onnx |
| Release | **v2.0.1** (published 2026-10-26), asset `sherpa-onnx-v2.0.1-android.tar.bz2` |
| Licence | Apache-2.0 (`LICENSE` in the release source, `sherpa-onnx-2.0.1/LICENSE`) |
| Copyright | Copyright (c) the sherpa-onnx authors, including Xiaomi Corporation (Kotlin API headers) |
| Built against | onnxruntime 1.28.2 (`libonnxruntime.so` inside that bundle, NOT shipped; see section 3). Modified, see below |
| SHA-256 of the bundle | `39003753ec293425ed56723ea9b972b98841a490af3311670c3060548d654330` |

Shipped native libraries (only `libsherpa-onnx-jni.so`; the `c-api`/`cxx-api` libraries and the bundled
`libonnxruntime.so` are not copied):

| ABI | File | Bytes | SHA-256 as shipped (modified) | SHA-256 in the release (original) |
|---|---|---|---|---|
| arm64-v8a | `app/src/main/jniLibs/arm64-v8a/libsherpa-onnx-jni.so` | 4,609,320 | `e3a7bea4e718f15d22806c6a871fcd981e9bbe1f1f98c7d18bdbdb783fa14e32` | `5db8f89f12b2c900a98c9e01e00c475c59db35e9437a62e36e27839ec48b5575` |
| armeabi-v7a | `app/src/main/jniLibs/armeabi-v7a/libsherpa-onnx-jni.so` | 3,381,796 | `10a70ad0e2f5896c4e3a3f812de8471606eaa76cfa8bf554885ba8d26374353c` | `d45f377249d5c3191b91de6ba6edffcd83e4cf7e109bc523b212db341581c2a8` |
| x86_64 (emulator) | `app/src/main/jniLibs/x86_64/libsherpa-onnx-jni.so` | 5,053,592 | `d1614526d6f4682e10be2feaae90f866c4736b46dfef8d12de213ed2ca29ce34` | `878d61116f244131263eec24297ef05bf508d02bccdede2a4e3ad3202bbdaa48` |

`libsherpa-onnx-jni.so` has one dependency, `libonnxruntime.so`. It is provided by the Maven artifact
`com.microsoft.onnxruntime:onnxruntime-android:1.28.0` (MIT); 1.28.2 is not published for Android, and 1.29+ adds telemetry.

**Modification (Apache-2.0 section 4b):** the release libraries ask for `OrtGetApiBase@VERS_1.28.2`, and Android's linker
enforces symbol versions, so they did not load against 1.28.0 ("cannot locate symbol OrtGetApiBase"). Kosha changes one
entry of each library's ELF version-needs table from `VERS_1.28.2` to `VERS_1.28.0` and updates its hash: 2 bytes per file,
done by `tool/patch_sherpa_ort_version.dart` and checked by `test/tool/patch_sherpa_ort_version_test.dart`. OrtGetApiBase
is the only onnxruntime symbol sherpa imports, and the OrtApi level (28) is the same in 1.28.0 and 1.28.2. Checked on the
emulator (API 37, x86_64) on 2026-11-22: the library loads and the Whisper base pack runs.

Kotlin API files copied unmodified (apart from a two-line provenance comment at the top) into
`app/src/main/kotlin/app/kosha/keyboard/voice/sherpa/`, from `android/SherpaOnnxAar/sherpa_onnx/src/main/java/com/k2fsa/sherpa/onnx/`
of the same tag: `FeatureConfig.kt`, `HomophoneReplacerConfig.kt`, `QnnConfig.kt`, `OfflineRecognizer.kt`,
`OfflineStream.kt`, `Vad.kt`. Their package stays `com.k2fsa.sherpa.onnx` because the JNI symbols bind to it.

##### Build from source (for Wave 5's reproducible builds; not yet run)

1. Get the sources of the same tag: `https://github.com/k2-fsa/sherpa-onnx/archive/refs/tags/v2.0.1.tar.gz`.
2. Get onnxruntime 1.28.0 for Android from Maven (`onnxruntime-android-1.28.0.aar`) and unzip it. Its `headers/`
   folder is the include dir, and `jni/<abi>/libonnxruntime.so` is the lib dir for each ABI.
3. Install the Android NDK matching `flutter.ndkVersion` and set `ANDROID_NDK`.
4. From the source root run, for each ABI, for example:
   `SHERPA_ONNXRUNTIME_LIB_DIR=<aar>/jni/arm64-v8a SHERPA_ONNXRUNTIME_INCLUDE_DIR=<aar>/headers ./build-android-arm64-v8a.sh`
   (`build-android-armv7-eabi.sh` and `build-android-x86-64.sh` for the others). The scripts use CMake and build
   the shared library, which links the AAR's `libonnxruntime.so`.
5. Take `libsherpa-onnx-jni.so` from the build output and compare its SHA-256 with the table above.

#### 2. Whisper (speech recognition, multilingual, int8)

| Item | Value |
|---|---|
| Model | OpenAI Whisper, base and small, multilingual, exported for sherpa-onnx (int8 encoder and decoder) |
| Licence | MIT (Whisper weights and code, OpenAI) |
| Source | sherpa-onnx release `asr-models`: `sherpa-onnx-whisper-base.tar.bz2` and `sherpa-onnx-whisper-small.tar.bz2` |
| Archive SHA-256 | base `911b2083efd7c0dca2ac3b358b75222660dc09fb716d64fbfc417ba6c99ff3de` (207,557,382 bytes); small `486a46afbb7ba798507190ffe02fea2dd726049af212e774537efac6afb210a6` (639,387,718 bytes) |
| Files in a pack | `encoder.int8.onnx`, `decoder.int8.onnx`, `tokens.txt` (renamed from `base-*`/`small-*`) |
| Staged sizes | base: encoder 29,120,534; decoder 130,672,026; tokens 816,730 bytes. small: encoder 112,442,483; decoder 262,226,114; tokens 816,730 bytes |
| Languages | en, es, fr, de, pt-BR (pt), pt-PT (pt), id, ru, uk, hi, mr, bn, ta, te, ar, ur |

The brief's pinned hashes come from the first download. The Whisper archives have no digest in the GitHub
API, so re-pin only on purpose.

#### 3. Silero VAD (voice activity detection)

| Item | Value |
|---|---|
| Model | Silero VAD (`silero_vad.onnx`, the sherpa-onnx release file of that name) |
| Licence | MIT (snakers4/silero-vad; confirm on the model card) |
| Source | sherpa-onnx release `asr-models`, `silero_vad.onnx` (2025-07-11) |
| SHA-256 | `9e2449e1087496d8d4caba907f23e0bd3f78d91fa552479bb9c23ac09cbb1fd6` (643,854 bytes; matches the API digest) |

#### 4. Later packs (assessed, not built)

- **Dolphin** (Apache-2.0 per the brief; verify on the model card): sherpa-onnx has an offline Dolphin config (`OfflineDolphinModelConfig`). Hindi, Urdu and Arabic coverage to be checked
  on the model card before a pack is staged. Not built in Wave 3.
- **Moonshine** (licence to verify on the model card, believed MIT): English-only. sherpa-onnx has an offline Moonshine config (`OfflineMoonshineModelConfig`). Useful as a small English pack. Not built in Wave 3.

### Notices: offline translation (Wave 3-T)

Kosha's translation runs OPUS-MT neural models on the phone with ONNX Runtime. The app never bundles
a model: each direction is a signed model pack that the user imports (see `tool/packs/translate/`).

#### Engine

| Component | Version | Licence | Use |
|---|---|---|---|
| ONNX Runtime (`com.microsoft.onnxruntime:onnxruntime-android`, JVM tests: `onnxruntime`) | 1.28.0 | MIT | Runs the encoder and decoder |
| OPUS-MT model architecture (Marian) | - | MIT (Marian NMT) | Model graph |

The SentencePiece model file (`source.spm`) is read by our own minimal reader
(`SentencePieceModel.kt`); no SentencePiece library is used.

#### Models

All 12 directions come from the ONNX exports by Xenova (Hugging Face, Transformers.js project), which
convert the Helsinki-NLP OPUS-MT models. The int8 "quantized" graphs are used
(`encoder_model_quantized.onnx`, `decoder_model_merged_quantized.onnx`). Upstream models are trained on
OPUS corpora (Tiedemann, 2012, "Parallel Data, Tools and Interfaces in OPUS", LREC).

Citation for OPUS-MT: Tiedemann, J. and Thottingal, S. (2020), "OPUS-MT - Building open translation
services for the World", EAMT.

| Pack | Upstream model (Helsinki-NLP) | Exported by | Revision (commit) | Licence | Staged size |
|---|---|---|---|---|---|
| translate-en-es | opus-mt-en-es | Xenova/opus-mt-en-es | 4b002a4c7edd54a7ced58877258b87f7efd3f892 | Apache-2.0 | 110.3 MB |
| translate-es-en | opus-mt-es-en | Xenova/opus-mt-es-en | eadfd7c658a9d8929ac3b8e996b68a68e2c7d480 | Apache-2.0 | 110.3 MB |
| translate-en-fr | opus-mt-en-fr | Xenova/opus-mt-en-fr | 28726206f80896b90035bd99cccd5cc1e151f916 | Apache-2.0 | 104.6 MB |
| translate-fr-en | opus-mt-fr-en | Xenova/opus-mt-fr-en | 6b166a182780e118c997879d0ad5be4b53671644 | Apache-2.0 | 104.6 MB |
| translate-en-de | opus-mt-en-de | Xenova/opus-mt-en-de | 1ca130c44c4c5441ef16d48aae521a424ab644f7 | CC-BY-4.0 | 103.2 MB |
| translate-de-en | opus-mt-de-en | Xenova/opus-mt-de-en | 399dfd68706739fffd503f876093e455ae268a06 | Apache-2.0 | 103.2 MB |
| translate-en-pt | opus-mt-en-ROMANCE (multi-target, `>>pt<<`) | Xenova/opus-mt-en-ROMANCE | 9d2ba69ac80c8e8453c3d9a1e2323a0e7b8ca3cd | Apache-2.0 | 110.1 MB |
| translate-pt-en | opus-mt-ROMANCE-en | Xenova/opus-mt-ROMANCE-en | f60feaabe8bb435a5871e7702b25f53a01e770f8 | Apache-2.0 | 110.2 MB |
| translate-en-hi | opus-mt-en-hi | Xenova/opus-mt-en-hi | 7aad72006a1588a9c3485ed6203aed99eebbc872 | Apache-2.0 | 107.8 MB |
| translate-hi-en | opus-mt-hi-en | Xenova/opus-mt-hi-en | 99853100ed9d932987a6816e8cf7b1b6742a6116 | Apache-2.0 | 107.2 MB |
| translate-en-ru | opus-mt-en-ru | Xenova/opus-mt-en-ru | e050376e960175e8ddc5cff85025dc8436cddd68 | Apache-2.0 | 108.8 MB |
| translate-ru-en | opus-mt-ru-en | Xenova/opus-mt-ru-en | afe8c6c738ec81b6d033fd8f44f9678a639a7c67 | CC-BY-4.0 | 109.1 MB |

Licences are the ones stated on the upstream Helsinki-NLP model cards (checked on 2026-11-22). Apache-2.0
and CC-BY-4.0 are both allowed. The Portuguese pack uses the multilingual ROMANCE models with the target
token `>>pt<<`, which both Portuguese variants (pt-BR, pt-PT) share.

Every file's SHA-256 is pinned in `tool/packs/translate/models.json` and checked by `stage.ps1`.
The pack manifest carries the licence of each pack; the orchestrator signs the packs.

Thanks and attribution: the Helsinki-NLP team (OPUS-MT), Jörg Tiedemann and the OPUS project, and Xenova
for the ONNX conversions.

#### Tokeniser

Each model's `source.spm` and shared `vocab.json` come unchanged from the same upstream repository.
Tokenisation is checked against the sentencepiece library on 102 test sentences (0 mismatches).

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
