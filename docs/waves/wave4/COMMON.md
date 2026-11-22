# Wave 4: common rules for every agent

You are one of 5 parallel Wave 4 agents building **Kosha** (renamed from Myna on 2026-11-22; Sanskrit *kosha*, "a treasury": your words are your treasure, kept with you). Kosha is a private, fully offline, multilingual Android keyboard written in Flutter. Waves 0-3 are merged: typing, autocorrect, swipe, themes, the settings app, privacy center, panels, modes, 17 languages (European, Indic, Arabic/Urdu), offline voice and translation. Wave 4 adds **Chinese and Japanese, accessibility and translations, performance, and the brand**:

| Agent | Brief | Work |
|---|---|---|
| A | `A-chinese.md` | Chinese pinyin composer, dictionary pack, Chinese settings |
| B | `B-japanese.md` | Japanese romaji and 12-key flick composer, kana-kanji conversion, dictionary pack |
| C | `C-a11y-l10n.md` | TalkBack on the keyboard, then the settings app in en, es, fr, de, pt, id, hi |
| D | `D-perf.md` | Reduced onnxruntime build (APK size), performance budgets, fuzzing, QA |
| E | `E-brand.md` | Treasure-chest icon, splash, chest "mascot" poses, store graphics |

**Stack:**
- Flutter 3.50.0 stable and Dart 3.14. Material lives in the standalone `material_ui` package: `import 'package:material_ui/material_ui.dart'`.
- Packages: flutter_riverpod 3.5, path_provider, collection, meta, characters, image_picker, local_auth, **flutter_localizations (SDK) and intl 0.20.3 (new in Wave 4)**; dev: mocktail, pigeon 30.
- Android: AGP 9.3, Kotlin 2.4, compile/target SDK 36, minSdk 26. `onnxruntime-android` is **pinned to 1.28.0**: 1.29+ ships HTTP telemetry and the INTERNET permission. Never upgrade it. The shipped `libsherpa-onnx-jni.so` files are patched to need `VERS_1.28.0` (`tool/patch_sherpa_ort_version.dart`).

You run in your own git worktree, a copy of the repo on a branch made from `main`.
- Work only in your current directory. Do NOT edit the original checkout at `C:\Users\kgnan\keyboard`.
- The machine runs Windows. Use PowerShell or Git Bash. In PowerShell, `bash` means WSL, which is not installed.
- You may use the network on this dev machine to download data, models and source. The app itself must never use the network.

## Read before coding

1. `docs/PARALLEL_WORK.md`: rules and the **Wave 4 ownership table**. Follow it strictly: 4 other agents edit other files at the same time.
2. The approved plan, `C:\Users\kgnan\.claude\plans\i-want-to-create-greedy-treehouse.md`: "Languages" (zh, ja rows), "Performance budgets", "Brand", "Privacy and security". The plan says Myna; the name is now Kosha.
3. The Wave 4 seams, setup commit `f2fd99a` (`git show f2fd99a --stat`, then the files):
   - `lib/src/keyboard/input/composer.dart`: `TextComposer`, `ComposerState`, `ComposerCandidate`, `ComposerStep`, `ComposerKeys`. Read the header: it says exactly which keys reach a composer and when.
   - `lib/src/keyboard/input/input_controller.dart`, "Wave 4 seams": `composer`, `composerState`, `composerActive`, `selectCandidate`, `onCustomKey`.
   - `lib/src/keyboard/candidates/`: the candidate strip and grid (orchestrator-owned; they draw `composerState`).
   - `lib/src/keyboard/view/keyboard_view_controller.dart` and `popup_layer.dart`: flick input (`KeyDef.flick`, `FlickGuideState`), custom keys.
   - `lib/src/engine/lang/chinese.dart`, `japanese.dart` (seeded), `cjk_rules.dart`, `language_info.dart` (`LayoutChoice.composes`).
   - `lib/src/packs/installed_packs.dart` and `PlatformHostApi.getPackDirectory`: dictionary packs (`PackKind.dictionary`).
   - `lib/src/settings/sections/chinese_settings.dart`, `japanese_settings.dart`; routes `KoshaRoutes.chinese`/`japanese`; stubs in `lib/src/features/chinese|japanese/` and `lib/src/app/chinese|japanese/`.
   - `lib/src/app/l10n.dart`, `l10n.yaml`, `lib/l10n/app_en.arb`: localisation.
4. `test/keyboard/wave4_seams_test.dart` shows every seam in use (a fake pinyin composer, the strip, the grid, flick, packs, l10n).

## Shared facts

- **Language ids** add 'zh' (Simplified Chinese; Traditional is an output option) and 'ja'.
- **Layouts** are `assets/layouts/<id>.json` (format: `lib/src/keyboard/layout/layout_model.dart`, read-only). New in Wave 4: `flick` (`{"left": "い", "up": "う", "right": "え", "down": "お"}`), `{"type": "custom", "code": "..."}` for composer keys, and `spoken` (what TalkBack says).
- **Dictionary packs** (A and B): the app never bundles CJK dictionaries. A pack is a signed `.koshapack` (format: `PackStore.kt`) with `kind: "dictionary"`, built by `tool/make_pack.dart --kind dictionary`. At most 64 files per pack. The signing key is the orchestrator's and lives outside the repo, so write a staging script that downloads and lays out the files; the orchestrator signs. Tests use small fixtures under `test/`, never the real data.
- **Data licences:** use only CC0, CC-BY (any version), CC-BY-SA 4.0, Apache-2.0, MIT, BSD, Unicode or GPL-3.0-compatible sources (Kosha is GPL-3.0-or-later). Never GPLv2-only, non-commercial (NC) or no-derivatives (ND) data. Write every source (URL, version or date, licence, attribution) to `docs/notices/<your-area>.md`.
- **Learned data** goes only through `SecureBlobStore`, in a blob named in your brief. The orchestrator registers new blobs for wipe, backup and the privacy center sizes after the merge.
- **Merge order:** E, D, A, B, C.

## Hard rules

- **Privacy first.**
  - No network code and no new permissions.
  - Never log typed text, candidates, readings, words, app names or paths. Use `KoshaLog` (Dart) or `Log` (Kotlin) with events, sizes and timings only.
  - Respect `InputFieldInfo.isSensitive` (password fields), incognito (`InputController.isIncognito`) and `InputController.learningAllowed`: nothing is learned there.
- **Do NOT run adb or emulators, and never install anything on a device.** A personal phone is plugged into this PC. The orchestrator does all device testing.
- **No new pub or Gradle dependencies** beyond those your brief names. Ask in your report if you truly need one, with its licence and a no-network confirmation.
- **Contracts are read-only.** If a seam lacks something, work around it inside your area and describe the change in your report. Orchestrator-owned: `pigeons/`, `lib/src/core/`, `lib/src/bridge/`, `lib/src/engine/contracts.dart`, `lib/src/engine/lang/language_info.dart`, `registry.dart`, `cjk_rules.dart`, `lib/src/keyboard/**` (except the files C's brief names), `lib/src/packs/`, `lib/keyboard_main.dart`, `lib/src/app/routes.dart`, `app_services.dart`, `app.dart`, `l10n.dart`, `pubspec.yaml`, `l10n.yaml`, `analysis_options.yaml`, the manifests, `android/` except what a brief names.
- **Line endings: LF only.** Before each commit, compare `git diff --cached --stat` with `git diff --cached --stat --ignore-cr-at-eol`; they must match. Some older files are CRLF (`pubspec.yaml`, `pigeons/messages.dart`, `PlatformHostApiImpl.kt`, `kosha_settings.dart`): keep each file's style. Do not use `sed -i` on CRLF files (Git Bash's sed rewrites them as LF).
- **Quality gate**, in order:
  1. `flutter pub get` (also regenerates `lib/l10n/app_localizations*.dart`)
  2. `dart format --line-length 120 <your paths>`
  3. `flutter analyze`: zero issues, including infos.
  4. `flutter test`: all green, including the 1076 existing tests.
  5. If you touched `android/`: `flutter build apk --debug`, then `cd android; .\gradlew.bat :app:testDebugUnitTest` (105 tests, 5 skipped).
- **Commit on your branch** (the git identity is preconfigured) with a descriptive message. End it with a `Co-Authored-By:` line naming your own model. Commit early and often, because a usage limit may stop you mid-way. Do not merge or push.
- **UI quality:** Material 3 Expressive (grouped containers, large headers, rounded shapes, spring motion); semantics labels on every control; touch targets of at least 48 dp; light and dark mode; font scale 1.3; widget tests for the main flows. Every `MaterialApp` in a widget test passes `localizationsDelegates: koshaLocalizationsDelegates` (`package:kosha/src/app/l10n.dart`).
- **Final message is your report, at most 400 words:**
  - what you built
  - the files you touched
  - test results (counts)
  - measured sizes and timings
  - known gaps and what the orchestrator should check on the emulator
  - requested contract or dependency changes
