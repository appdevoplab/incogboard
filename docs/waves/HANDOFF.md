# Handoff: continue from here after /clear

State as of 2026-11-22 (midday):
- **Waves 0, 1, 2 and 3 are merged on `main`.** Wave 3 merged in the order A, C, B, T, D (`5e4e9c8`, `21fbdfd`, `b382e9f`, `6cb5d23`, `e61fd52`), then follow-ups `2e73d22` (merge fixes) and `f05a2ed` (onnxruntime pin), plus the voice/translate fixes listed under "Wave 3: still to do".
- Checks on `main` after the merges: `flutter analyze` 0 issues, `flutter test` 1009 pass, Android JVM tests 102 pass (5 real-model tests skipped without staged packs).
- **The Wave 3 emulator smoke test is half done and the release gate has not run yet.** See "Wave 3: still to do".

## Wave 3 result

- Agents (Haiku, high effort): A European, B Indic, C Arabic/Urdu, D voice, T translator. Brand moved to Wave 4. All branches stayed inside their ownership; no overlapping files, no CRLF churn.
- B stopped repeatedly while its Wikipedia word counts ran; the orchestrator built bn/te data (`fe50fcd`) and stopped the agent. T's first report was empty; its work was safety-committed (`5512661`).
- **User decisions (2026-11-21):** translator in Wave 3; voice = sherpa-onnx + Whisper, no bundled model (signed packs only); Indic only hi/mr/bn/ta/te; packs signed with an ECDSA P-256 dev key at `%USERPROFILE%\.myna\keys\pack-dev.pem` (outside the repo; Wave 5 swaps the release key); app name (Koel, Sarika, Wren, Pipit, Lark, Kestrel suggested) and GitHub username wait for Wave 5.
- Fixed while merging (`2e73d22`):
  - ar/ur dictionaries rebuilt: the old dictionary tool dropped every 1-3 letter word in caseless scripts (في، من، على). A had already fixed the tool.
  - `foldKey` drops Arabic harakat and tatweel, so a word typed with vowel marks matches.
  - Translate selection chip: priority 11 (Cut/Copy/Select all filled all 3 slots) and only shown when a translation pack is installed.
  - R8 keep rules for `com.k2fsa.sherpa.onnx.**` and `ai.onnxruntime.**`.
  - Wave 3 notices folded into `THIRD_PARTY_NOTICES.md` and `assets/notices/`.
- **onnxruntime pinned to 1.28.0 (`f05a2ed`):** 1.29.0+ ships `ai.onnxruntime.telemetry` (an HttpClient started by a `TelemetryInitializer` provider at app launch) and requests INTERNET and ACCESS_NETWORK_STATE. 1.28.0 has none of it; sherpa-onnx v2.0.1 (built on 1.28.2) loads against it. Never upgrade without checking the AAR manifest and classes.
- Signed dev packs (not in git): `build/packs/voice-whisper-base.mynapack` (161 MB) and `build/packs/translate-en-es.mynapack` (116 MB). Staging folders are in the D and T worktrees (`.claude/worktrees/agent-a8904fc33dde9aeb9|agent-a12470156dd569215/build/packs/staging/`); copy them out before removing the worktrees.
- Emulator smoke test so far (API 37), all pass:
  - English autocorrect ("recieve wierd thnaks" → "receive weird thanks"); "teh"/"dont" are no longer corrected only because Myna learned them from repeated test typing
  - password field shows the private-field chip
  - German QWERTZ with the globe key and "Deutsch" on the space bar; German + English blend ("ich bin hungry")
  - Hindi in English letters: "namaste dosto" → "नमस्ते दोस्तों"
  - Arabic "مرحبا بكم", with the strip mirrored (best in the centre, second on the right)
  - Russian "привет как дела"
  - Model packs screen: imported both packs through the system file picker (264 MB)
  - translate panel: "where is the station" → "¿Dónde está la estación?", Insert; the keyboard logs no text
  - mic permission prompt through the transparent activity; mic panel with the On-device badge and language chip

## Wave 3: still to do (in this order)

1. **Fixes committed at the end of the last session (analyze clean; seam, voice and translate tests pass; full suites not rerun):**
   - The translate panel had no way out (keys stayed redirected): added a "Close translation" button (`translate_panel.dart`) and a test.
   - Voice said "Voice needs a voice pack" with Whisper installed: old settings hold `voice.modelId: "base"`. `VoiceSettings.fromJson` now maps "base"/"small" to "" (automatic), and `resolveVoicePack` falls back to the automatic choice when the named pack is missing. Tests updated in `VoiceLanguagesTest.kt` and `test/keyboard/wave3_seams_test.dart`.
   - First rerun the full `flutter test` and `cd android; .\gradlew.bat :app:testDebugUnitTest` (VoiceLanguagesTest changed).
2. **Finish the emulator smoke test** (emulator-5554 only; rebuild and reinstall first):
   - voice: open the mic panel with the base pack, check that sherpa-onnx loads (no UnsatisfiedLinkError in logcat), Stop, Cancel, and a password field (no mic). The emulator mic cannot produce speech here, so recognition quality is untested.
   - space-bar long press (language picker), Urdu, Tamil/Telugu rendering, InScript with a ZWJ, Eastern digits.
3. **Release gate:** `flutter build apk --release --split-per-abi`, then `tool/check_release_permissions.sh` (Git Bash tool). Expect VIBRATE, RECORD_AUDIO, USE_BIOMETRIC, USE_FINGERPRINT and the app-private receiver permission; **no INTERNET and no ACCESS_NETWORK_STATE**. Record the arm64 APK size (25.4 MB before Wave 3; onnxruntime and sherpa-onnx add native libraries). Consider adding ACCESS_NETWORK_STATE and the `ai/onnxruntime/telemetry` classes to the gate.
4. Update `docs/waves/README.md` (Wave 3 done), this file and the memory file; remove the five Wave 3 worktrees and branches (unlock, `git worktree remove --force`, `git branch -d`).

## Wave 3: open items for the user

- Licences to confirm before release: the pt-BR word list (AOSP-derived, patched; see `docs/notices/european.md`) and the Arabic list (HeliBoard says CC BY 4.0 from Leipzig; not checked directly).
- Translation speed: 200-560 ms per sentence on this PC's CPU in Python; the 300 ms phone budget is not met yet. Not measured in Kotlin or on a phone.
- The Indic InScript/phonetic key positions were written from memory by the agent; verify against the BIS chart.
- ZWNJ/ZWJ show as blank popup keys on the virama.
- Toolbar holds up to 8 buttons (about 40 dp each, under 48 dp); Insert in the translate strip is 44 dp tall.
- Toggling translation on or off takes effect at the next keyboard start (hooks are fixed at attach).
- Not mirrored in RTL: the keyboard's own backspace and shift glyphs and the toolbar icons (orchestrator files).
- Urdu has no next-word data; Cyrillic vowel-confusion search is not applied.
- Auto-capitalisation did not trigger at the start of the testbed's text field (probably no CAP_SENTENCES flag there); check in a normal app.

## Emulator notes (learned this wave)

- `uiautomator dump --windows` includes the keyboard window; a plain dump does not. Helper script: `tool/ui_smoke.ps1` (Get-Ui, Show-Ui, Tap-Ui, Type-Keys; dot-source it after `tool/adb_ime.ps1` is reachable).
- Reinstalling the APK, or force-stopping the app while Myna is the keyboard, makes Android switch to Gboard: run `Enable-Myna` after both, and force-stop before enabling, not after.
- Change languages quickly by editing `no_backup/data/settings.json` through `run-as app.myna.keyboard` (force-stop first).
- The testbed field is the EditText under its label (tap y≈142 for `text`), not the label.

- **User decisions for Wave 2 (2026-11-21):**
  - clipboard history on by default
  - the incognito picker lists "apps you've typed in" (encrypted `seen_apps` blob)
  - emoji keywords for all 17 languages
  - app lock offered in the privacy center only
- **Release permissions now:** VIBRATE, USE_BIOMETRIC, USE_FINGERPRINT (from local_auth; needed for the Android 8.x fingerprint path) and androidx.core's app-private receiver permission. No INTERNET. Release arm64 APK: 25.4 MB.

## Wave 2 result

- The Wave 2 agents ran on Haiku (high effort). The first two launches stopped with nothing done; the third finished all five in 13 to 55 minutes. Every branch stayed inside its ownership, with LF line endings and no overlapping files.
- Fixed while merging:
  - **Backup vs clipboard:** B's codec expected `{text, ts, pinned}` but D stores `{v:1, items:[{id,text,time,pinned}]}`. Backups would have dropped pinned clips. The codec now uses D's layout.
  - **Backup vs theme photos:** C keeps photos in `themes/images/<uuid>.png`; B's file list only read `themes/`. `CustomThemeFiles` now includes `images/`.
  - **Emoji assets:** Android's packager strips `.gz` and inflates the file, so the panel said "Emoji are not available" on the device. The files are now `assets/emoji/*.dat`. Host tests could not catch this.
  - E's requests: split (>= 600 dp, setting on) and compact (landscape phone, 44 dp rows) are wired in `keyboard_view.dart` and `KeyboardMetrics`. With swipe-delete on, backspace deletes on release instead of touch-down.
  - Privacy screens use `MynaMascot`. The emoji notice is folded into `THIRD_PARTY_NOTICES.md` and `assets/notices/third-party-data.txt`.
- Emulator smoke test (API 37), all pass:
  - typing and autocorrect ("teh i dont" → "the I don't"); password field (no autocorrect, black screenshot); email/URL layouts with the toolbar
  - backspace tap, swipe-delete of one word and its Undo chip
  - emoji panel (index 73 ms, 19 emoji hidden by the glyph check) and inserting an emoji
  - modes bar and one-handed left, swap and full-width
  - settings app: onboarding end to end, Home, privacy center sizes, theme gallery, dark theme reaching the keyboard
- Second emulator pass (all pass after fixes): clipboard selection chips, recent-copy chip and paste, clipboard panel with pin; editing panel (paste, select all, cut, undo, redo); emoji search ("cat"); space-bar cursor drag; floating drag, pass-through taps and dock; height bar with reset; compact landscape on a phone; split on a 720 dp tablet (density 240); app lock without a screen lock (asks to set one); encrypted backup to Downloads (MYNABK header, no plain text), clipboard wipe, merge restore, keyboard reload; theme editor with Photo Picker, crop, blur and the photo theme in the keyboard.
- Fixed in that pass:
  - Floating window was only as tall as the docked keyboard (MediaQuery inside the IME is the window); `FrameInfo.screenSize` now uses the real screen height (`d48cb3f`).
  - Split applied to landscape phones too; it now needs smallestScreenWidthDp >= 600 (`05e5bbe`).
  - Theme gallery cards ignored taps on a device: `CarouselView` covers items with its own InkWell unless `enableSplash: false`. The editor could not be opened.
  - The restore dialog showed the export-only "Off unless you turn it on" note for clipboard.
- Not covered: app lock with a real PIN or fingerprint (the emulator has no screen lock, and setting one changes device security settings), lock timeout, FLAG_SECURE in recents, emoji skin-tone picker.
- Seen once and not reproduced: after a backspace that reverted an autocorrection, swipe-delete Undo restored "don't " instead of "dont".
- Open decisions for the user:
  - The toolbar (clipboard, editing, modes, themes, settings) shows only when the strip has nothing to suggest. Ordinary text fields always show predictions, even when empty, so there the panels are reachable only through the emoji key.
  - Panel tab and modes-bar buttons are 44 dp tall (the strip height is fixed), below the 48 dp rule.
  - The About source link appears only with `--dart-define=MYNA_SOURCE_URL=<url>`, so it needs the GitHub username.
  - Email/URL layouts keep the emoji key next to ?123 (`LayoutVariants.forField`).
  - The recent-copy chip is hidden in incognito (not in the brief).

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

1. GitHub username, for `io.github.<username>.myna`: deferred to Wave 5 (placeholder `app.myna.keyboard` stays).
2. The app name: keep Myna or rename (Koel, Sarika, Wren, Pipit, Lark, Kestrel were suggested): decide in Wave 5.

Answered 2026-11-21: only hi/mr/bn/ta/te for Indic; voice uses sherpa-onnx + Whisper with no bundled model (packs only); the translator joins Wave 3; packs use a dev signing key until Wave 5.
