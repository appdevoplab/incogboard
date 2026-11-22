# Wave 3: common rules for every agent

You are one of 5 parallel Wave 3 agents building **Myna**, a private, fully offline, multilingual Android keyboard written in Flutter. Waves 1 and 2 are merged: the keyboard types, autocorrects and swipes in English, and has themes, the settings app, the privacy center, emoji/clipboard/editing panels and keyboard modes. Wave 3 adds **languages and voice**:

| Agent | Brief | Work |
|---|---|---|
| A | `A-european.md` | es, fr, de, pt-BR, pt-PT, id, ru, uk; multilingual typing; language switcher; Languages screen |
| B | `B-indic.md` | hi, mr, bn, ta, te: typing in English letters, native layouts, swipe |
| C | `C-arabic.md` | ar, ur: right-to-left, layouts, dictionaries |
| D | `D-voice.md` | offline voice typing (sherpa-onnx + Whisper), mic panel |
| T | `T-translator.md` | offline translation (ONNX models), translate panel, model-pack screen |

**Stack:**
- Flutter 3.50.0 stable and Dart 3.14.
- Material lives in the standalone `material_ui` package: `import 'package:material_ui/material_ui.dart'`.
- Packages: flutter_riverpod 3.5, path_provider, collection, meta, characters, image_picker, local_auth; dev: mocktail, pigeon 30.
- Android: AGP 9.3, Kotlin 2.4, compile/target SDK 36, minSdk 26. **New in Wave 3:** `com.microsoft.onnxruntime:onnxruntime-android:1.31.1` (MIT), the one native inference runtime shared by voice and translation.

You run in your own git worktree, a copy of the repo on a branch made from `main`.
- Work only in your current directory. Do NOT edit the original checkout at `C:\Users\kgnan\keyboard`.
- The machine runs Windows. Use PowerShell or Git Bash. In PowerShell, `bash` means WSL, which is not installed.
- You may use the network on this dev machine to download data, models and source. The app itself must never use the network.

## Read before coding

1. `docs/PARALLEL_WORK.md`: rules and the **Wave 3 ownership table**. Follow it strictly: 4 other agents edit other folders at the same time.
2. The approved plan, `C:\Users\kgnan\.claude\plans\i-want-to-create-greedy-treehouse.md`: sections "Languages", "Offline voice typing", "Do more languages make it slow?", "Privacy and security". Translator: `docs/waves/translator.md`.
3. The Wave 3 seams (setup commit `92ead05`; read `git show 92ead05 --stat` and the files):
   - `lib/src/engine/lang/`: `language_info.dart` (`LanguageInfo`, `LayoutChoice`), `registry.dart` (`allLanguages`, `languageInfo`, `layoutChoiceFor`, `blendedLanguages`, `rulesForLanguage`), and the per-agent files `european.dart` (A), `indic.dart` (B), `arabic.dart` (C), already seeded with every language.
   - `lib/src/keyboard/keyboard_session.dart`, "Wave 3 seams": `activeLanguage`, `activeLanguages` (the blend), `activeInfo`, `activeLayout`, `switchLanguage`, `spaceLabel`, `spaceLabelOverride`, `gestureWordSources`, `rebuildGestureTemplates`, and `layoutFor` (adds the globe key, currency, native digits and country domains).
   - `lib/src/keyboard/input/input_controller.dart`, "Wave 3 seams": `transform` (`SuggestionTransform`), `swipeTransform`, `language`.
   - `lib/src/keyboard/view/keyboard_hooks.dart`: `onVoice`, `onTranslate`, `onLanguageSwitch`, `onLanguagePicker`.
   - `lib/src/bridge/ime_events.dart`: `voice` stream. `pigeons/messages.dart`: the Wave 3 section (packs, voice, translation).
   - `lib/keyboard_main.dart`: the feature stubs you fill in (`lib/src/features/languages|indic|voice|translate/`).
   - Kotlin: `android/.../packs/` (PackStore, the pack format), `voice/VoiceService.kt`, `translate/TranslationService.kt`, `bridge/ImeHostApiImpl.kt` (how calls reach them).
4. `test/keyboard/wave3_seams_test.dart` shows each seam in use. `test/keyboard/seams_test.dart` shows how to pump `KeyboardApp` with a feature.

## Shared facts

- **Language ids:** 'en', 'es', 'fr', 'de', 'pt-BR', 'pt-PT', 'id', 'ru', 'uk', 'hi', 'mr', 'bn', 'ta', 'te', 'ar', 'ur'. Files use the id as is (`assets/dict/pt-BR.mdict`).
- **Layouts** are `assets/layouts/<id>.json` (format: `lib/src/keyboard/layout/layout_model.dart`; read-only). A layout's `script` field must match its `LayoutChoice.script`. Key rows keep their physical left-to-right order, even for right-to-left languages. Keep the `id: "currency"` key on symbol pages working.
- **Dictionaries** are `assets/dict/<id>.mdict`, built with `tool/build_dictionary.dart` from a `.combined` word list. Agent A owns that tool and makes it accept every script (see A's brief). B and C write their own converters into `.combined` under `tool/indic/` and `tool/arabic/`.
  - Size budget: at most 1.5 MB per `.mdict` (use `--max-words`), and say the size in your report.
- **Data licences:** use only CC0, CC-BY (any version), CC-BY-SA 4.0, Apache-2.0, MIT, BSD, Unicode or GPL-3.0-compatible sources. Never GPLv2-only, non-commercial (NC) or no-derivatives (ND) data. Write every source (URL, version or date, licence, attribution) to `docs/notices/<your-area>.md`.
- **Model packs** (D and T): the app never bundles models. A `.mynapack` is a signed container (format in `PackStore.kt`). `tool/make_pack.dart` builds one. The signing key is the orchestrator's and lives outside the repo, so write a staging script that downloads and lays out the model files, and the orchestrator signs. Tests use their own keys or fakes.
- **Merge order:** A, C, B, T, D.

## Hard rules

- **Privacy first.**
  - No network code. The only new permission this wave is RECORD_AUDIO, already declared.
  - Never log typed, spoken or translated text, words, app names or paths. Use `MynaLog` (Dart) or `Log` (Kotlin) with events, sizes and timings only.
  - Anything learned is persisted only through `SecureBlobStore`.
  - Respect `InputFieldInfo.isSensitive` (password fields) and incognito (`InputController.isIncognito`): voice and translation are off there, and nothing is recorded.
- **Do NOT run adb or emulators, and never install anything on a device.** A personal phone is plugged into this PC. The orchestrator does all device testing.
- **No new pub or Gradle dependencies** beyond those your brief names. Ask in your report if you truly need one, with its licence and a no-network confirmation.
- **Contracts are read-only.** If a seam lacks something, work around it inside your area and describe the change in your report. Orchestrator-owned: `pigeons/`, `lib/src/core/`, `lib/src/bridge/`, `lib/src/engine/contracts.dart`, `lib/src/engine/lang/language_info.dart` and `registry.dart`, `lib/src/keyboard/**` (session, controller, view, layout code, panels seam), `lib/keyboard_main.dart`, `lib/src/app/routes.dart`, `app_services.dart`, `pubspec.yaml`, the manifests, `android/.../packs/`, `bridge/`, `ime/`.
- **Line endings: LF only.** Before each commit, compare `git diff --cached --stat` with `git diff --cached --stat --ignore-cr-at-eol`; they must match. A few older files are CRLF (`pubspec.yaml`, `ime_events.dart`, `pigeons/messages.dart`, `PlatformHostApiImpl.kt`): keep each file's style.
- **Quality gate**, in order:
  1. `flutter pub get`
  2. `dart format --line-length 120 <your paths>`
  3. `flutter analyze`: zero issues, including infos.
  4. `flutter test`: all green, including the 804 existing tests.
  5. If you touched `android/`: `flutter build apk --debug`, then `cd android; .\gradlew.bat :app:testDebugUnitTest`.
- **Commit on your branch** (the git identity is preconfigured) with a descriptive message. End it with a `Co-Authored-By:` line naming your own model. Commit early and often, because a usage limit may stop you mid-way. Do not merge or push.
- **UI quality:** Material 3 Expressive (grouped containers, large headers, rounded shapes, spring motion); semantics labels on every control; touch targets of at least 48 dp; light and dark mode; font scale 1.3; widget tests for the main flows. Keyboard panels paint with `KeyboardThemeData` (`PanelContext.theme`) so they look like the keyboard.
- **Final message is your report, at most 400 words:**
  - what you built
  - the files you touched
  - test results (counts)
  - measured sizes and timings
  - known gaps and what the orchestrator should check on the emulator
  - requested contract or dependency changes
