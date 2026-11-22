# Wave 3-B: Indic languages (hi, mr, bn, ta, te)

Read `docs/waves/wave3/COMMON.md` first. Plan sections: "Languages" (the hi/mr and bn/ta/te rows), "Suggestions, autocorrect and learning", "Swipe (glide) typing".

The user chose **only these five** languages for now (no pack template for others).

## Ownership

**You own:**
- `lib/src/engine/lang/indic.dart`, plus anything under `lib/src/engine/lang/indic/` (transliterators, scheme tables).
- `lib/src/features/indic/**` (keep `createIndicFeature()`).
- Layout files `assets/layouts/translit_{hi,mr,bn,ta,te}.json`, `phonetic_*.json`, `inscript_*.json`.
- `assets/translit/**` (already declared in `pubspec.yaml`) and `assets/dict/{hi,mr,bn,ta,te}.mdict`.
- `tool/indic/**` (data download and conversion scripts; output `.combined` files for `tool/build_dictionary.dart` and your own transliteration data files).
- `docs/notices/indic.md`.
- Tests: `test/engine/lang/indic*`, `test/features/indic/**`, `test/tool/indic/**`, `test/keyboard/layouts_indic_test.dart`.

You use, but do not edit, `tool/build_dictionary.dart` and the predictor (Agent A owns them). If they need a change for your scripts, work around it in your converter and describe the change in your report.

## How Indic typing works

Three layouts per language, already listed in `indic.dart` (the first is the default):

1. **English letters** (`translit_<lang>`, script `Latn`, `transliterates: true`): a QWERTY layout. The user types "namaste" and the strip shows **नमस्ते** (centre, with "namaste" smaller below or after it) plus 2 more candidates. Space commits the native word. The predictor blends English too (the registry adds English when it is enabled), so "ok", "time" and "phone" still work.
2. **Phonetic** (`phonetic_<lang>`): native letters laid out by sound (क near k), with matras and conjunct help on long-press.
3. **InScript** (`inscript_<lang>`): the Indian standard (BIS) layout for that script.

## Build

### 1. Transliteration data

- Source: **Aksharantar** (AI4Bharat; check the licence on the dataset page, CC-BY 4.0 is expected) word pairs for hi, mr, bn, ta, te. Record the exact version in `docs/notices/indic.md`.
- Build a compact asset per language, `assets/translit/<lang>.bin` (your format, documented in a comment): romanised → native candidates with frequencies, about 50 to 100k entries per language, prefix-searchable (so "nam" already shows नम…). Budget: 1.5 MB per language. Load lazily off the UI isolate (`Isolate.run`), only for enabled languages.
- **Rule-based fallback** for words not in the table: a per-script scheme (ITRANS/Harvard-Kyoto-like: "kh" ख, "aa" आ, "ri" ऋ, schwa deletion at the word end for hi/mr, nasal "n" + consonant → anusvara). The fallback candidate always exists, so any typed word converts.
- Implement the `Transliterator` contract (`lib/src/engine/contracts.dart`).

### 2. Dictionaries (native script)

- `assets/dict/<lang>.mdict` from a frequency list with a usable licence (the native side of Aksharantar is one option; IndicCorp or Leipzig corpora are others: check each licence). HeliBoard's hi/mr/ta/te lists are marked GPLv2: use them only if they are "or later". Write `.combined` with your script in `tool/indic/`, then run `tool/build_dictionary.dart`. At most 1.5 MB each.

### 3. The Indic keyboard feature (`createIndicFeature`)

- Listen to `session.activeLanguage` and settings. When the active language is Indic **and** `session.activeLayout.transliterates`:
  - Set `session.input.transform` to a `SuggestionTransform` that turns the Latin composing word into native candidates (`Suggestion(kind: SuggestionKind.transliteration, display: <native>, ...)`; put the Latin text in the strip too). Keep English candidates from `base` when the typed word is a real English word, but rank the native word first.
  - Return `autoCorrection` = the best native candidate (kind `transliteration`), so space commits it. The controller applies it even when autocorrect is off, and never in URL/email/password fields.
  - With `settings.languages.hinglishOutput` on: no `autoCorrection` (the Latin word commits as typed), native candidates still offered, and `session.spaceLabelOverride.value = 'Hinglish'`.
  - Otherwise clear the transform and the override. Budget: 2 ms per key.
- **Swipe over the English-letters layout:** add a `session.gestureWordSources` entry giving the romanised forms of the top ~20k native words (as `LexiconEntry`, with the native word's frequency), then call `session.rebuildGestureTemplates()` once loaded. Set `session.input.swipeTransform` to map romanised candidates to native ones (unless Hinglish output is on).
- Native layouts: no transform; the native dictionary and the predictor do the work.

### 4. Layouts

- `translit_<lang>`: QWERTY like `qwerty.json`, with no accents in popups, `script: "Latn"`.
- `phonetic_<lang>` and `inscript_<lang>`: native letters, with `script` set to the language's script. Long-press the virama (्) key for ZWNJ (U+200C) and ZWJ (U+200D), with readable labels. The nukta, the visarga and the chandrabindu go in popups. The danda । and double danda ॥ go on the period popup (hi/mr/bn). The shift layer holds the second set of letters as InScript does.
- Native digits: the orchestrator's `withDigits` variant already swaps 0-9 when `languages.nativeDigits` is on, so don't build digits into your layouts.

### 5. Rules (`indicRules`)

- `hasCase: false`. Word characters: letters and marks of the script, plus ZWJ/ZWNJ. Danda । ends a sentence (hi, mr, bn). `addsSpaceAfter` and `removesSpaceBefore` include । and ॥.

## Tests

- Transliteration: "namaste" → नमस्ते, "bharat" → भारत, "kya" → क्या, "dhanyavaad" → धन्यवाद, and similar for mr/bn/ta/te; the fallback scheme on unknown words; the prefix search.
- Feature: transform on and off with the layout, Hinglish output, swipe mapping, no transform in URL fields; uses a pumped `KeyboardApp` (see `test/keyboard/wave3_seams_test.dart`).
- Layouts parse, fit, and contain every letter of the script; rules.

## Report extras

- Data sizes, entry counts and load times per language; per-key transform time.
- What to check on the emulator: Hindi in English letters ("namaste dosto"), Hinglish output, InScript typing with a ZWJ, Tamil and Telugu rendering, swipe "namaste".
