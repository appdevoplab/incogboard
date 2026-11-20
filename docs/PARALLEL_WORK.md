# How parallel agents work on Myna

Myna is built in waves. In each wave, several agents work at the same time, each in its own git worktree and branch. The orchestrator merges the branches in a fixed order and runs the full test suite plus an emulator smoke test before the next wave starts.

## Golden rules

1. **Edit only the paths you own** (see the wave table below). If you need a change elsewhere, describe it in your final report instead.
2. **Contracts are read-only for agents.** Only the orchestrator edits these:
   - `pigeons/messages.dart` and the generated `*.g.dart` / `*.g.kt`
   - `lib/src/engine/contracts.dart`
   - `lib/src/core/` (except files your brief names)
   - `lib/src/bridge/`
   - `lib/src/settings/myna_settings.dart` and `settings_store.dart`
   - `lib/src/keyboard/layout/layout_model.dart` (the JSON format)
   - `lib/src/theme/keyboard_theme_data.dart`
   - `lib/src/keyboard/gesture_layer/gesture_trail.dart` (signatures only; Wave 1-C owns the body)
   - `lib/main.dart`, `lib/keyboard_main.dart`
   - `pubspec.yaml`, `analysis_options.yaml`
   - `android/app/src/*/AndroidManifest.xml` (Wave 1-E may edit the main manifest's IME service block)
3. **Settings sections are per-feature.** You may add optional fields, with defaults, to *your* section file in `lib/src/settings/sections/`.
4. **Privacy is non-negotiable:**
   - No network code and no new permissions.
   - Never log typed text. Use `MynaLog` with events, sizes and timings only.
   - Anything learned from typing is stored only via `SecureBlobStore`.
   - Respect `InputFieldInfo.isSensitive` and `allowsLearning`.
5. **Dependencies:** none beyond `pubspec.yaml`. If you truly need one, request it in your report with its license and a confirmation that it has no network code.
6. **Quality bar before you report done:**
   - `dart format --line-length 120 <your paths>`
   - `flutter analyze` (zero issues)
   - `flutter test` (your new tests pass, and existing tests still pass)
   - If you touched `android/`, `cd android && ./gradlew :app:assembleDebug` passes.
7. **Commit on your branch** with a clear message. Don't merge, and don't push.
8. **Report:** what you built, the files you touched, test results, known gaps and any requested contract changes.

## Testing helpers

- `test/support/fake_editor.dart`: an in-memory EditText with Android InputConnection semantics. Use it to test keyboard logic.
- `InMemoryLexicon` / `InMemoryLexiconSource` in `lib/src/engine/in_memory_lexicon.dart`: test word lists.
- `InMemorySecureBlobStore` and `SettingsStore.memory()`: storage fakes.
- `tool/adb_ime.ps1`: emulator helpers. Only the orchestrator drives the emulator.

## Wave 1 ownership

| Agent | Owns | Delivers |
|---|---|---|
| A, keyboard view and input | `lib/src/keyboard/**` (except `gesture_layer/`), `assets/layouts/**`, `test/keyboard/**` | Layout engine and real layouts, key rendering, touch handling, popups, shift and caps, field-aware pages, suggestion bar, InputController |
| B, text engine | `lib/src/engine/dictionary/**`, `lib/src/engine/suggest/**`, `lib/src/engine/learn/**`, `tool/build_dictionary.dart`, `assets/dict/**`, `test/engine/text/**` | English dictionary format and build tool, autocorrect, completion, prediction, encrypted learning |
| C, gesture typing | `lib/src/engine/gesture/**`, `lib/src/keyboard/gesture_layer/**`, `test/engine/gesture/**` | Swipe decoder in an isolate, trail painter, accuracy tests |
| D, design and themes | `lib/src/design/**`, `lib/src/theme/**` (except `keyboard_theme_data.dart`), `assets/themes/**`, `assets/fonts/**`, `test/theme/**` | M3 Expressive tokens, presets, Material You, `resolveKeyboardTheme`, fonts |
| E, Android platform | `android/**` (except manifests, beyond the IME service block), `test/android/**` | InputConnection completeness, clipboard watcher, Keystore hardening, feedback, insets and floating mode, inline autofill, trim memory |
