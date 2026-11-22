# Wave 3-C: Arabic and Urdu, right to left

Read `docs/waves/wave3/COMMON.md` first. Plan sections: "Languages" (the ar/ur row), "Typing feel", "Panels and modes".

## Ownership

**You own:**
- `lib/src/engine/lang/arabic.dart`, plus anything under `lib/src/engine/lang/arabic/`.
- Layout files `assets/layouts/arabic.json`, `urdu_phonetic.json` (and other `arabic*`/`urdu*` layouts).
- `assets/dict/{ar,ur}.mdict` and `tool/arabic/**` (download and conversion scripts that write `.combined` files for `tool/build_dictionary.dart`).
- **Right-to-left fixes only** inside the Wave 2 panels: `lib/src/features/emoji/**`, `clipboard/**`, `editing/**`, `shared/**`. Don't change their behaviour otherwise.
- `docs/notices/arabic.md`.
- Tests: `test/engine/lang/arabic*`, `test/keyboard/layouts_arabic_test.dart`, `test/features/rtl/**`.

You use, but do not edit, `tool/build_dictionary.dart` and the predictor (Agent A owns them). The keyboard view, strip and modes belong to the orchestrator: report RTL problems there with a precise description, a failing test in `test/features/rtl/`, and the fix you suggest.

## What already works

- When the active language is right-to-left (`LanguageInfo.isRtl`), the orchestrator wraps the suggestion strip and every panel in `Directionality(rtl)`. Key rows keep the physical order of the layout file, so write the Arabic layout's rows left to right as they look on screen.
- Native (Eastern Arabic) digits come from `languages.nativeDigits` and the orchestrator's `withDigits` variant: `٠١٢٣٤٥٦٧٨٩` for ar, `۰۱۲۳۴۵۶۷۸۹` for ur.

## Build

### 1. Layouts

- `arabic`: the standard Arabic phone layout (as on Android's Arabic keyboard), 3 letter rows (ض ص ث ق ف غ ع ه خ ح ج / ش س ي ب ل ا ت ن م ك ط / ئ ء ؤ ر ى ة و ز ظ د plus backspace). The shift layer holds the harakat and the rarer letters.
  - **Harakat on long-press:** the alef key offers أ إ آ ٱ; a dedicated harakat key (or the shift layer) has َ ُ ِ ً ٌ ٍ ْ ّ.
  - Punctuation: the comma key types ، and the period popup has . ؟ ! ؛.
  - `script: "Arab"`.
- `urdu_phonetic`: Urdu phonetic (ٹ ڈ ڑ ں ے ھ گ چ پ ژ on the letters they sound like), with the Urdu full stop ۔ on the period key and ، on the comma key.
- Update `arabicLanguages` in `arabic.dart` to match.

### 2. Dictionaries

- ar: HeliBoard's Arabic list (`https://codeberg.org/Helium314/aosp-dictionaries`; CC BY 4.0 expected: check). ur: HeliBoard's Urdu list only if its licence is usable (it is marked GPLv2: only if "or later"); otherwise a CC-BY or CC0 frequency list (Leipzig corpora, for example). Record each one in `docs/notices/arabic.md`.
- Normalise in your converter: remove tatweel (ـ) and harakat from the stored words (the user rarely types them); map Arabic/Persian variants of yeh and kaf consistently per language (Urdu uses ی ک, Arabic uses ي ك). At most 1.5 MB each.
- Make sure the predictor matches a typed word with harakat to the bare dictionary word. If that needs a change in A's text engine, report it and handle the stripping in your rules as far as you can.

### 3. Rules (`arabicRules`)

- `hasCase: false`. Word characters: Arabic letters, harakat, tatweel, ZWNJ (Urdu).
- Sentence ends: . ! ؟ and ۔ (Urdu). `addsSpaceAfter` and `removesSpaceBefore` include ، ؛ ؟ ۔.
- Quotes: choose « » or “ ” per language and say which in the report.

### 4. Right to left, end to end

Write widget tests in `test/features/rtl/` that pump `KeyboardApp` with Arabic active (`LanguageSettings(enabled: ['ar'], active: 'ar')`) and check:
- The strip: the best suggestion is in the centre, the second one on the **right**, and the text is right-aligned.
- Emoji, clipboard and editing panels: tabs, rows and back buttons mirror; arrows in the editing panel keep their meaning (◀ moves the cursor back in the text, which is to the right in RTL text). Fix these in the panel files.
- Mixed text: an English word inside Arabic text and digits in the strip render correctly (no `TextDirection.ltr` hard-coded where it matters).

### 5. Swipe

- Swipe typing works on the Arabic layout through the existing decoder (it is script-agnostic). Measure accuracy on 50 common Arabic words with synthetic paths, as Wave 1's gesture tests do (`test/engine/gesture/`), and report it. Don't change the decoder: report what would help.

## Tests

- Rules, layouts (parse, fit, contain every letter of the alphabet), the converter (normalisation), RTL widget tests above.

## Report extras

- Dictionary sizes, word counts and licences; swipe accuracy.
- What to check on the emulator: typing "مرحبا بكم" and "آپ کیسے ہیں", harakat long-press, the mirrored strip and emoji panel, Eastern digits on, and switching back to English.
