# Handoff: continue from here after /clear

State as of 2026-11-21:
- Waves 0 and 1 are done and merged on `main`.
- **The Wave 2 setup is committed** (`bcdcc10`): deps, Pigeon additions and integration seams. 482 tests pass, the emulator smoke test passed, and the release gate passes.
- **The Wave 2 briefs are written:** `docs/waves/wave2/COMMON.md` plus `A-settings.md`, `B-privacy.md`, `C-themes.md`, `D-panels.md` and `E-modes.md`. Ownership is in `docs/PARALLEL_WORK.md`.
- **Wave 2 agents relaunched 2026-11-21 at 3 PM on Haiku, high effort** (the user's new rule). The first Sonnet launch hit the 5-hour usage limit before changing anything. They work in `.claude/worktrees/agent-<id>`:

  | Agent | Branch |
  |---|---|
  | A settings | `worktree-agent-a515b739ac5f148ff` |
  | B privacy | `worktree-agent-a71dfb98893eda54f` |
  | C themes | `worktree-agent-a0b14899291deeb30` |
  | D panels | `worktree-agent-a8b8e5778d29ca903` |
  | E modes | `worktree-agent-a11af2d621e17b2b8` |

  **Relaunched again 2026-11-21 (evening):** the 3 PM run also stopped with no commits or edits. New branches (each first merges its old one):

  | Agent | Branch |
  |---|---|
  | A settings | `worktree-agent-aa0675f1822502b9b` |
  | B privacy | `worktree-agent-aa85a143d79081023` |
  | C themes | `worktree-agent-ab2c58978d55113ff` |
  | D panels | `worktree-agent-a83889688141ebfd1` |
  | E modes | `worktree-agent-a6c3bd99d0431fea0` |

  The old empty branches above can be removed after the merge.

  Next: review each branch (line endings, ownership), then merge in the order B, C, D, E, A per `docs/waves/README.md`. If one stopped unfinished, commit its leftovers and relaunch it with `git merge <old-branch>` first.
- **User decisions for Wave 2 (2026-11-21):**
  - clipboard history on by default
  - the incognito picker lists "apps you've typed in" (encrypted `seen_apps` blob)
  - emoji keywords for all 17 languages
  - app lock offered in the privacy center only
- **Release permissions now:** VIBRATE, USE_BIOMETRIC, USE_FINGERPRINT (from local_auth; needed for the Android 8.x fingerprint path) and androidx.core's app-private receiver permission. No INTERNET.

## Wave 1 result

- Checks on merged `main`: `flutter analyze` 0 issues, `flutter test` 464 pass, Android JVM tests 31 pass.
- Release build: `flutter build apk --release --split-per-abi` gives arm64 at 21.1 MB. The permission gate passes: VIBRATE plus androidx.core's app-private `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, and no INTERNET.
- Emulator smoke test (API 37), all pass:
  - typing, with autocorrect ("teh"→"the", "i dont"→"I don't")
  - the suggestion strip
  - swipe ("hello", "world", "keyboard")
  - password field: no autocorrect, and the keyboard is black in screenshots
  - email/URL layouts and no autocorrect there
  - light and dark themes
- Fixed during the merge: empty email/URL fields showed prose next-word predictions ("The / I / Thanks").
- Approved by the user: `androidx.autofill:autofill:1.3.0`, which styles the inline autofill chips.

## Wave 1 carry-over (now covered by the Wave 2 setup and briefs)

- **Contract (E):** add an optional Dart→Kotlin call carrying the keyboard background colour, so nav-bar icon contrast does not follow system night mode.
- **Settings (B):** wire `TypingSettings.blockOffensiveWords` to `MynaTextPredictor.blockOffensive`. The default is true on both sides today.
- **Themes (D):**
  - Custom themes load only through `resolveKeyboardThemeFromSpec`; the editor must register them by id.
  - The trail width and fade are not in the theme spec.
  - Image backgrounds must paint the `dim` toward black.
- **Keyboard (A), not done yet:**
  - emoji, voice and globe keys
  - per-user touch offset, long-press on a suggestion, and cut/copy chips
  - hardware-keyboard mode, tablet width cap, RTL layouts, and reopening a word after backspace
  - active languages fixed to `['en']` until Wave 3
- **Gesture (C):**
  - Only one template set is cached, so rotating the screen rebuilds it.
  - Accuracy was measured on synthetic English swipes only.
  - Indic and Chinese need a romanisation path (Wave 3).
- **Unverified on a device:**
  - inline autofill chips
  - floating mode (`FlutterTextureView` swap)
  - the engine-restart watchdog
  - Keystore when the device is locked
  - the font's `ROND` axis
- **Line endings:** agents A and E committed CRLF files, which were normalised before the merge. Tell every Wave 2 agent to write LF only. Consider a `.gitattributes` with `* text=auto eol=lf`; 13 older files on main are still CRLF.
- Agents put their own model name in the `Co-Authored-By` line, not the Opus line in `COMMON.md`.

## How to run a wave

1. Write each brief as a file under `docs/waves/wave<N>/`, with a `COMMON.md`.
2. Launch ≤5 agents with `isolation: worktree`, `model: haiku` and `effort: high` (user's rule since 2026-11-21), and a short prompt that points at the brief.
3. Before merging, check each branch:
   - `git log main..<branch>`
   - `git diff --stat` against `--ignore-cr-at-eol` to spot line-ending churn
   - cross-branch file overlap
4. Merge with the checklist in `docs/waves/README.md`.
5. Remove worktrees: unlock, then `git worktree remove --force`, then `git branch -d`.
6. If an agent stops unfinished, commit its leftovers on its branch. Then relaunch it and tell it to `git merge <old-branch>` first.

## Cautions

- A personal TECNO phone may be connected over USB. Always set `$env:ANDROID_SERIAL='emulator-5554'`, and never install on the phone without asking.
- The emulator AVD is `Medium_Phone_API_37.0`. It needs `adb shell settings put secure show_ime_with_hard_keyboard 1` once.
- `adb` is not on PATH. Use `. .\tool\adb_ime.ps1` (`Invoke-Adb`) or `$env:ANDROID_HOME\platform-tools\adb.exe`.
- In PowerShell, `bash` means WSL, which isn't installed. Run `tool/check_release_permissions.sh` through the Git Bash tool.
- Pigeon output must be reformatted: `dart format --line-length 120 lib/src/bridge/messages.g.dart`. Otherwise the whole file shows as changed.
- Reinstalling the APK while a field is focused hides the keyboard. Tap the field again.

## Open questions for the user

1. GitHub username, for `io.github.<username>.myna`. The current applicationId is the placeholder `app.myna.keyboard`.
2. Which extra Indian languages "Something else" meant. The default is gu/kn/ml/pa/or as follow-up packs.
3. Voice model size: bundled base (~60 MB) plus an optional small model?
