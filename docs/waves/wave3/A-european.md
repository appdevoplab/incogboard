# Wave 3-A: European languages, multilingual typing and the language switcher

Read `docs/waves/wave3/COMMON.md` first. Plan sections: "Languages", "Suggestions, autocorrect and learning", "Do more languages make it slow?".

Languages: **es, fr, de, pt-BR, pt-PT, id, ru, uk** (English already works).

## Ownership

**You own:**
- `lib/src/engine/lang/european.dart` (info and rules for your languages; new files under `lib/src/engine/lang/european/` are yours too).
- The text engine: `lib/src/engine/dictionary/**`, `lib/src/engine/suggest/**`, `lib/src/engine/learn/**`, `tool/build_dictionary.dart`. B and C use the dictionary tool and the predictor but do not edit them, so keep both working for every script.
- Layout files: `assets/layouts/qwerty_es.json`, `azerty.json`, `qwertz.json`, `jcuken_ru.json`, `jcuken_uk.json`, and any other `assets/layouts/<name>.json` for your languages. You may adjust popups in `qwerty.json`, which every Latin language shares.
- Dictionaries: `assets/dict/{es,fr,de,pt-BR,pt-PT,id,ru,uk}.mdict`, plus any helper scripts under `tool/european/`.
- `lib/src/features/languages/**` (the keyboard-side language picker; keep `createLanguagesFeature()`).
- Settings app: `lib/src/app/screens/languages_screen.dart`, `lib/src/app/shell/language_catalog.dart`, `lib/src/app/onboarding/**` (the language step only).
- `lib/src/settings/sections/language_settings.dart`: you may add optional fields.
- `docs/notices/european.md`.
- Tests: `test/engine/text/**`, `test/engine/lang/european_test.dart`, `test/features/languages/**`, `test/app/languages/**`, `test/tool/build_dictionary_test.dart`, `test/keyboard/layouts_european_test.dart`.

## Build

### 1. Text engine fixes first (others depend on them)

- `MynaTextPredictor.setActiveLanguages`: a language without a dictionary must be skipped (log it), not make the whole call fail. Today one missing `.mdict` leaves the blend unchanged.
- Blending (up to 3, which already exists): check that suggestions mix languages sensibly. The best word from any active language wins by score; never autocorrect a word that is valid in any active language ("die" is German and English); prefer the active (first) language on ties. Add tests.
- Learning goes to the language the word belongs to; unknown words go to the active language.
- `text_fold.dart` and the spatial model must work for Cyrillic, Devanagari, Bengali, Tamil, Telugu and Arabic letters (no Latin-only assumptions; ß, ё/е and ї are real letters). Accent-insensitive matching: typing "cafe" finds "café"; "ss" never folds to "ß".
- The tool already accepts ZWNJ/ZWJ inside words (orchestrator change). Keep it.
- Performance: `suggest` with 3 languages under 8 ms (measure it with the benchmark style of `test/keyboard/key_handling_benchmark_test.dart`).

### 2. Dictionaries

- Source: HeliBoard's dictionaries (`https://codeberg.org/Helium314/aosp-dictionaries`, the `wordlists/` `.combined` files) or AOSP LatinIME. **Check the licence of each file** (see COMMON): note it per language in `docs/notices/european.md`. If a language's list is not usable, look for a CC-BY or CC0 frequency list (for example Leipzig corpora word lists are CC-BY) and convert it.
- pt-BR and pt-PT each get their own dictionary (brasileiro "ônibus, time"; europeu "autocarro, equipa"). id has few accents.
- Build with `--max-words` so each file is at most 1.5 MB. Keep bigrams where the source has them.

### 3. Layouts

- `qwerty_es`: Spanish QWERTY with ñ after l (shrink the row, not the keys below 0.9 width). Popups: á é í ó ú ü, ¿ ¡ on the punctuation popups.
- `azerty` (French): AZERTY rows, é è ê ë à â ç ù û ô î ï œ æ in popups; the bottom row keeps ?123, emoji, comma, space, period, enter. Apostrophe easy to reach (popup on the comma or a key in row 3).
- `qwertz` (German): Z and Y swapped, ü ö ä on popups of u o a **and** as optional keys in a `qwertz` variant with umlaut keys (decide; report it). ß on the s popup.
- `jcuken_ru`: ЙЦУКЕН with ё (popup on е), ъ (popup on ь). `jcuken_uk`: ї є і ґ and the apostrophe ʼ.
- Every layout: popups with numbers 1-0 on the top row (hints), as in `qwerty.json`.
- Update `LanguageInfo.layouts` in `european.dart` to match (first = default).

### 4. Language rules (`europeanRules`)

- **French:** a narrow no-break space (U+202F) before ; : ! ? and inside « » (`spaceBefore`, `quotes`). Elision: "l'", "d'", "qu'" are part of words.
- **German:** quotes „ “. **Spanish:** “ ” and the inverted ¿ ¡ never take a space after them. **Portuguese:** “ ”. **Russian/Ukrainian:** « », and the Ukrainian apostrophe (ʼ and ') inside words.
- Sentence ends and auto-capitalisation like English for all of them.
- Currency and country domains are already in the `LanguageInfo` entries; check them.

### 5. Language switcher

- The globe key already cycles enabled languages and long-pressing it opens the system keyboard picker (orchestrator).
- **Space-bar long press** (`KeyboardHooks.onLanguagePicker`): a `PanelPlacement.keys` panel listing the enabled languages (native name, layout name, a check on the active one; tap switches with `session.switchLanguage(id)` and closes). Below the list: "Language settings" (opens the settings route `languages`) and "Switch keyboard" (`host.showInputMethodPicker()`). When the active language uses a transliterating layout (Indic, `session.activeLayout.transliterates`), add a switch "Type in Hinglish (English letters)" writing `languages.hinglishOutput`.
- Show the picker only when 2 or more languages are enabled; with one, return a null hook so the system picker opens.

### 6. Settings app: Languages screen and onboarding

- List every language from `allLanguages` (`registry.dart`), grouped: Enabled (drag to reorder; the first is the default), then Available. The catalog in `language_catalog.dart` must read from the registry, not its own list; drop "coming soon" for Wave 3 languages.
- Per enabled language: layout choice (from `LanguageInfo.layouts`), and remove.
- Global: "Multilingual typing" (blend up to 3 languages that share a script; explain it in one line), "Native digits" (`languages.nativeDigits`, shown when an enabled language has `nativeDigits`).
- Onboarding's language step: pick one or more languages with search; the user's system locale is pre-selected when we support it.
- Write with `SettingsStore.update(..., sections: [SettingsSection.languages])`; the keyboard reloads by itself.

## Tests

- Rules per language (spacing, quotes, sentence ends).
- Every layout parses, has the right script, its keys fit (row widths), and contains all letters of the language's alphabet.
- Blending and the missing-dictionary skip; accent-insensitive lookup; a 3-language benchmark.
- The picker panel (switching, settings link, Hinglish switch) with a pumped `KeyboardApp`.
- Languages screen: enable, reorder, layout choice, writes the right section.

## Report extras

- Dictionary sizes and word counts per language; licence per source.
- Measured `suggest` time with 1 and 3 languages.
- What to check on the emulator: German QWERTZ + English blend ("ich bin hungry"), French spacing ("Bonjour !"), Russian typing and the globe key, the space-bar picker.
