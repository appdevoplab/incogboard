# Wave 3-T: offline translator and the model-pack screen

Read `docs/waves/wave3/COMMON.md` and the plan `docs/waves/translator.md` first (the user's decisions, interface, privacy rules and budgets are there and still hold).

**Pairs:** English ↔ Spanish, French, German, Portuguese, Hindi, Russian (12 directions). Models only in signed packs, one pack per direction.

## Ownership

**You own:**
- Kotlin: `android/app/src/main/kotlin/app/myna/keyboard/translate/**`. Replace the stub body of `createTranslationService`; keep the `TranslationService` interface as is. `ImeHostApiImpl` already runs `translate` on a single background thread and maps `TranslationException` codes.
- `android/app/build.gradle.kts`: you may add **one** line, `testImplementation("com.microsoft.onnxruntime:onnxruntime:1.31.1")` (the desktop runtime, MIT, test-only), so JVM tests can run a real model. Nothing else in that file.
- Dart: `lib/src/features/translate/**` (keep `createTranslateFeature()`), `lib/src/app/translate/**`, `lib/src/app/packs/**`, `lib/src/settings/sections/translate_settings.dart` (optional fields only).
- In `lib/src/app/privacy/privacy_center_screen.dart`: only **one** new tile in the stored-data group, "Model packs", with the total size, opening the `packs` route.
- `tool/packs/translate/**` (staging scripts) and `docs/notices/translate.md`.
- Tests: `android/app/src/test/kotlin/app/myna/keyboard/translate/**`, `test/features/translate/**`, `test/app/translate/**`, `test/app/packs/**`.

## Build

### 1. Engine choice (report first, then build)

- **Preferred:** Helsinki-NLP **OPUS-MT** (Marian) models exported to ONNX (for example the int8-quantised `Xenova/opus-mt-*` exports), run with the **onnxruntime Java API** (`ai.onnxruntime.*`, already in the app). This adds no native code. Licence: OPUS-MT models are CC-BY 4.0. Check every direction.
- Portuguese: no plain `opus-mt-en-pt` may exist; compare `opus-mt-tc-big-en-pt` / `pt-en` with the multilingual ROMANCE models (`>>pt_BR<<` target token) by size and quality, and pick.
- Mozilla Bergamot or CTranslate2 would add a second native runtime: choose them only with a strong reason, written in the report.
- Report per direction: model name, licence, size (int8), and time per sentence on the dev machine.

### 2. Kotlin translation service

- Tokeniser: the models' SentencePiece unigram tokenisers (from `tokenizer.json` or the `.spm` vocab). Implement the encoder (Viterbi over the vocab) and decoder in Kotlin, with special tokens and the target-language token where a model needs one. Check it against reference token ids that you generate at dev time with Python `transformers`; save them as JVM test fixtures.
- Decoding: greedy (beam 2–4 only if quality needs it and the budget allows), with the decoder's KV cache (`decoder_model_merged`), max length `1.5 × source + 10` tokens. Split long input into sentences and translate them one after another.
- One model loaded at a time; `release()` frees it; also free it after 2 minutes unused.
- Pack lookup: `PackStore.find("translation", listOf(from, to))` (pack languages are exactly `[from, to]`). Missing → `TranslationException("no_pack")`. Map Myna ids: pt-BR / pt-PT → the Portuguese pack.
- Budgets (from the plan): first translation after opening the panel under 1.5 s, later sentences under 300 ms on a mid-range phone, under 150 MB extra memory.
- **Privacy:** never log text; nothing written to disk except by the pack store.

### 3. Packs (staging script, run at dev time)

- `tool/packs/translate/stage.ps1` (or `.dart`): downloads the 12 chosen models with pinned revisions and SHA-256 checks, lays each out in `build/packs/staging/translate-<from>-<to>/` (encoder, decoder, tokeniser files, a small `config.json` of your own with the special token ids), and prints the `dart run tool/make_pack.dart ...` commands (`kind: translation`, `languages: <from>,<to>`, `engine: opus-mt-onnx`). The orchestrator signs.

### 4. Translate panel (keyboard)

- `attach` returns `KeyboardHooks(onTranslate:)` when `settings.translate.enabled`. Never open in password fields or incognito.
- A `PanelPlacement.strip` panel with a `KeyRedirect` (like emoji search): the keyboard's own keys type into the panel's source box. The 44 dp strip shows a language-pair chip ("EN → ES"), the source text (ending visible), the translation preview, and **Insert** (48 dp). Enter also inserts. Translate as you type, debounced about 300 ms; show a small progress dot while waiting.
- Tapping the pair chip opens a `PanelPlacement.keys` picker: from / to among Myna's languages, a swap button, and a mark on pairs whose pack is installed. Save the pair in `settings.translate`.
- **Insert** commits the translation with `input.insertText` and clears the box; the typed source text never goes into the app.
- `no_pack`: the strip says "Get the English → Spanish pack" with a button that opens the settings route `packs`.
- Call `host.releaseTranslator()` when the panel closes.
- Nothing from the panel is learned or put into the clipboard history: check that `insertText` does not reach `predictor.onWordCommitted`, and add a test.

### 5. Translate selection

- When `events.selection` shows a non-empty selection (not in password fields, not incognito, translation enabled), show a strip chip `translate.selection` "Translate" (priority 9; Wave 2's Cut/Copy chips use 10). Remove it when the selection collapses or the field changes.
- On tap only: `host.getSelectedText()`, translate into `settings.translate.to` (from = `settings.translate.from`, or swap if the active language is the target), then show chips "Replace" and "Insert after" with a short preview of the result (at most 24 characters in the label).
- Replace: `input.finishComposing()`, commit the translation over the selection through `input.editor`, then `input.resyncAfterExternalEdit()`. Insert after: move the cursor to the selection end and insert " " + translation.

### 6. Settings app

- **Model packs** screen (`lib/src/app/packs/packs_screen.dart`, route `packs`; voice uses it too): installed packs grouped Voice / Translation, with name, languages, size and licence; **Import** (`app.openDocument([...])` then `app.importPack(uri)` with a progress indicator; map the error codes `bad_signature`, `bad_format`, `too_large`, `unsupported_version`, `no_space` to plain messages); **Delete** with a confirmation. After any change call `AppServices.notifyDataChanged([DataSections.packs])`. Note at the top: "Packs are checked before they are installed. They contain data only, never code."
- **Translation** screen (`lib/src/app/translate/translate_screen.dart`, route `translate`): on/off, the default pair, installed directions, a link to Model packs, and the privacy note ("Translation runs on this phone. Nothing you translate is saved.").
- The keyboard re-reads `platform.listPacks()` on `DataSections.packs`.

## Tests

- JVM: tokeniser against fixtures; decoding with the desktop runtime and a tiny model if one is available (otherwise mark it `@Ignore` with the reason and test with a fake session); pack lookup and the error codes.
- Dart: the panel (typing through the redirect, debounce, Insert, no_pack, the pair picker), the selection chips (Replace, Insert after, never in password fields), nothing learned; the packs screen (list, import errors, delete); the translation screen.

## Report extras

- Model choice table (direction, model, licence, size, time per sentence); total size of all 12 packs.
- What the orchestrator should check on the emulator: import a pack from Downloads, translate "Where is the station?" EN → ES, Insert, the selection chip in a notes app, `no_pack` for a missing direction.
