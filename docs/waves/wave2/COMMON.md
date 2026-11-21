# Wave 2: common rules for every agent

You are one of 5 parallel Wave 2 agents building **Myna**, a private, fully offline, multilingual Android keyboard written in Flutter. Wave 1 is merged: the keyboard types, autocorrects, swipes and has themes. Wave 2 builds the product around it: the settings app, the privacy center, the theme editor, the emoji/clipboard/editing panels, and the keyboard modes.

**Stack:**
- Flutter 3.50.0 stable and Dart 3.14.
- Material lives in the standalone `material_ui` package: `import 'package:material_ui/material_ui.dart'`.
- Available packages:
  - flutter_riverpod 3.5, path_provider, collection, meta, characters
  - **new in Wave 2:** `image_picker` (Android Photo Picker) and `local_auth` (BiometricPrompt)
  - dev: mocktail and pigeon 30
- Android: AGP 9.3, Kotlin 2.4, compile/target SDK 36, minSdk 26.

You run in your own git worktree, a copy of the repo on a branch made from `main`.
- Work only in your current directory. Do NOT edit the original checkout at `C:\Users\kgnan\keyboard`.
- The machine runs Windows. Use PowerShell or Git Bash.
- You may use the network on this dev machine to download data and source, and to read package source in the pub cache. The app itself must never use the network.

## Read before coding

1. `docs/PARALLEL_WORK.md`: rules and the **Wave 2 ownership table**. Follow it strictly, because 4 other agents edit other folders at the same time.
2. The approved plan, `C:\Users\kgnan\.claude\plans\i-want-to-create-greedy-treehouse.md`. Read the sections your brief names; they list many small details to implement.
3. The Wave 2 seams, which the orchestrator built so you never need to edit someone else's files:
   - `lib/src/keyboard/panels/keyboard_panel.dart`: `KeyboardPanel`, `PanelContext`, `StripChip`, `KeyboardFrame`, `KeyboardFeature`.
   - `lib/src/keyboard/keyboard_session.dart`: `openPanel`, `closePanel`, `showChip`, `removeChip`, `seenApps`.
   - `lib/src/keyboard/input/input_controller.dart`, its "Wave 2 seams" and "Panel editing API" sections:
     - `redirect`, `decorators`
     - `insertText`, `finishComposing`, `editor`, `resyncAfterExternalEdit`
     - `moveCursor`, `deleteWordBackward`
   - `lib/src/keyboard/view/keyboard_hooks.dart`: toolbar and drag hooks, `KeyboardHooks.merge`.
   - `lib/keyboard_main.dart`: how features are attached.
   - `lib/src/app/app_services.dart`, `routes.dart`, `common/settings_widgets.dart`: the settings app's services, routes and shared widgets.
   - `lib/src/core/data_sections.dart` and `seen_apps.dart`: encrypted data names and cross-engine reload notifications.
   - `pigeons/messages.dart`: the Kotlin↔Dart contract, including the new Wave 2 calls.
4. The tests in `test/keyboard/seams_test.dart` show how each seam is used.

## How the two engines share data

- The keyboard (IME) and the settings app are **two Flutter engines in one process**, with separate isolates and no shared Dart memory.
- **Settings:** `SettingsStore.update(..., sections: [...])` saves a JSON file and tells the other engine, which reloads.
- **Encrypted data:** blobs live in `SecureBlobStore` under the names in `DataBlobs`.
  - After one engine changes a blob, it calls `platform.notifySettingsChanged([DataSections.x])`. The settings app uses `AppServices.notifyDataChanged`.
  - The other engine reloads: the keyboard via `services.events.settingsChanged`, the app via `AppServices.dataChanges`.
- **Plain files** (custom themes and their images) live under `PlatformHostApi.getDataDirectory()`, which the keyboard has as `KeyboardServices.dataDirectory`.

## Hard rules

- **Privacy first.**
  - No network code and no new permissions.
  - Never log typed text, words, clipboard content, app names or paths. Use `MynaLog` with events, sizes and timings only.
  - Anything learned or remembered (clipboard, emoji recents, shortcuts, apps) is persisted only through `SecureBlobStore`.
  - Respect `InputFieldInfo.isSensitive` (password fields) and incognito (`InputController.isIncognito`): nothing is recorded there.
- **Do NOT run adb or emulators, and never install anything on a device.** A personal phone is plugged into this PC. The orchestrator does all device testing.
- **No new pub or Gradle dependencies.** If you truly need one, ask in your report, with its licence and a confirmation that it has no network code.
- **Contracts are read-only.** If a seam is missing something, work around it inside your area and describe the change you need in your report. The orchestrator owns `pigeons/`, `lib/src/core/`, `lib/src/bridge/`, `lib/src/engine/contracts.dart`, and `keyboard_panel.dart`. It also owns the keyboard's own view, session and controller files.
- **Line endings: LF only.** Agents committed CRLF files in Wave 1. Before each commit, check `git diff --cached --stat` against `git diff --cached --stat --ignore-cr-at-eol`; the two must match. A few older files on main are CRLF: keep each file's existing style.
- **Quality gate**, in order:
  1. `flutter pub get`
  2. `dart format --line-length 120 <your paths>`
  3. `flutter analyze`: zero issues, including infos.
  4. `flutter test`: all green, including existing tests.
  5. If you touched `android/`, run `flutter build apk --debug`, and the JVM tests too: `cd android; .\gradlew.bat :app:testDebugUnitTest`.
- **Commit on your branch** (the git identity is preconfigured) with a descriptive message. End it with a `Co-Authored-By:` line naming your own model. Commit early and often, because a usage limit may stop you mid-way. Do not merge or push.
- **UI quality:**
  - Material 3 Expressive look: grouped containers, large headers, rounded shapes, spring motion.
  - Every control has a semantics label, and touch targets are at least 48 dp.
  - It must work in light and dark mode and at font scale 1.3.
  - Write widget tests for the main flows.
- **Final message is your report, at most 400 words:**
  - what you built
  - the files you touched
  - test results (counts)
  - measured performance where relevant
  - known gaps and what the orchestrator should check on the emulator
  - requested contract or dependency changes
