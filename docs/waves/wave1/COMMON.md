# Wave 1: common rules for every agent

You are one of 5 parallel Wave 1 agents building **Myna**, a private, fully offline, multilingual Android keyboard written in Flutter.

**Stack:**
- Flutter 3.50.0 stable and Dart 3.14.
- Material lives in the standalone `material_ui` package: `import 'package:material_ui/material_ui.dart'`.
- Available packages: flutter_riverpod 3.5, path_provider, collection, meta, characters. Dev: mocktail and pigeon 30.
- Android: AGP 9.3, Kotlin 2.4, compile/target SDK 36, minSdk 26.

You run in your own git worktree, a copy of the repo on a branch made from `main`.
- Work only in your current directory. Do NOT edit the original checkout at `C:\Users\kgnan\keyboard`.
- The machine runs Windows. Use PowerShell or Git Bash.
- You may use the network on this dev machine to download data, fonts and source. The app itself must never use the network.

## Read before coding

1. `docs/PARALLEL_WORK.md`: rules and file ownership. Follow them strictly, because 4 other agents edit other folders at the same time.
2. The approved plan, `C:\Users\kgnan\.claude\plans\i-want-to-create-greedy-treehouse.md`. Read the sections for your area; they list many small details to implement.
3. The contracts:
   - `lib/src/engine/contracts.dart`
   - `lib/src/core/input_field_info.dart`
   - `lib/src/bridge/input_sink.dart`
   - `lib/src/bridge/ime_events.dart`
   - `lib/src/bridge/messages.g.dart`
   - `lib/src/core/keyboard_services.dart`
   - `lib/src/settings/myna_settings.dart` (plus `sections/`)
   - `lib/src/theme/keyboard_theme_data.dart`
   - `lib/src/theme/theme_resolver.dart`
   - `lib/src/keyboard/layout/layout_model.dart`
   - `lib/src/keyboard/gesture_layer/gesture_trail.dart`
   - `pigeons/messages.dart`
   - `test/support/fake_editor.dart`

## What Wave 0 proved on an API 37 emulator

- The Flutter keyboard renders in the IME window and commits text.
- Dart owns the total input-view height. `WindowLayoutMessage.heightDp` includes the bottom inset that Flutter applies as `viewPadding`.
- Kotlin→Dart Pigeon calls are callback style. Dart `ImeFlutterApi` handlers return `Future<void>`.
- The entrypoint `keyboardMain` lives in `lib/main.dart`.

## Hard rules

- **Privacy first.**
  - No network code and no new permissions.
  - Never log typed text, words, paths or clipboard content. Use `MynaLog` with events, sizes and timings only.
  - Learned data is persisted only through `SecureBlobStore`.
- **Do NOT run adb or emulators, and never install anything on a device.** A personal phone is plugged into this PC. The orchestrator does all device testing.
- **No new pub dependencies.** Request any you need in your report.
- **Quality gate**, in order:
  1. `flutter pub get`
  2. `dart format --line-length 120 <your paths>`
  3. `flutter analyze`: zero issues.
  4. `flutter test`: all green, including existing tests.
- **Commit on your branch** (the git identity is preconfigured) with a descriptive message whose last line is `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Commit early and often, because a usage limit may stop you mid-way. Do not merge or push.
- **Final message is your report, at most 400 words:**
  - what you built
  - the files you touched
  - test results (counts)
  - measured performance
  - known gaps
  - requested contract or dependency changes
