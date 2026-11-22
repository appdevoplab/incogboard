# Handoff: continue from here after /clear

State as of 2026-11-22 (evening):
- **Waves 0-3 are done and merged on `main`.** Wave 3 merged in the order A, C, B, T, D (`5e4e9c8`, `21fbdfd`, `b382e9f`, `6cb5d23`, `e61fd52`), then follow-ups `2e73d22` (merge fixes), `f05a2ed` (onnxruntime pin), `bcad579` (translate close, voice "base" fallback) and the Wave 3 finish commit (see "Wave 3 finish").
- Checks on `main`: `flutter analyze` 0 issues, `flutter test` 1020 pass, Android JVM tests 103 pass (5 real-model tests skipped without staged packs). Emulator smoke test done; release permission gate passes.
- The Wave 3 worktrees and branches are removed.
- **Wave 4 setup, part 1 done (2026-11-22 night):** the Myna → Kosha rename (`4a3c394`) and the BIS InScript layouts (`238cbcc`); `flutter test` 1053, JVM 103, release gate passes. **Next:** the Wave 4 seams (CJK candidate grid and dictionary packs, localisation, brand assets) and the five briefs in `docs/waves/wave4/`.
- Names in the Wave 0-3 sections of this file are historical (Myna, `.mynapack`, `MynaMascot`, …); the code now says Kosha.

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
- **onnxruntime pinned to 1.28.0 (`f05a2ed`):** 1.29.0+ ships `ai.onnxruntime.telemetry` (an HttpClient started by a `TelemetryInitializer` provider at app launch) and requests INTERNET and ACCESS_NETWORK_STATE. 1.28.0 has none of it. sherpa-onnx v2.0.1 (built on 1.28.2) did **not** load against it until its symbol-version need was patched (see "Wave 3 finish"). Never upgrade without checking the AAR manifest and classes; the release gate now also fails on the telemetry classes or provider.
- Dev packs (not in git) live outside the repo in `%USERPROFILE%\.kosha\packs\` (the dev key in `%USERPROFILE%\.kosha\keys\`): `signed\voice-whisper-base.koshapack` (161 MB) and `signed\translate-en-es.koshapack` (116 MB), re-signed after the rename, plus `staging\` with all 14 staged folders (voice base and small; translate en↔de/es/fr/hi/pt/ru; 1.8 GB) and `download\` with the raw downloads they were built from (`voice\`: the sherpa Whisper tarballs and silero_vad; `translate-hf-cache\`: the Xenova Hugging Face cache; 2.1 GB). Sign more with `tool/make_pack.dart --dir %USERPROFILE%\.kosha\packs\staging\<id>`.
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

## Wave 4 decisions (user, 2026-11-22 evening; briefs not written yet)

- **Name: Kosha** (Sanskrit/Hindi *kosha*, "treasury, a store of gold": your words are your treasure, kept with you). **Full rename** in the Wave 4 setup by the orchestrator, before agents start: app name, strings, docs, notices, Dart package `myna`→`kosha`, Kotlin packages and classes (`MynaImeService`→`KoshaImeService`, `MynaMascot`, `MynaLog`, …), backup/pack magic names where safe. **Done in `4a3c394`:** besides the code, the placeholder applicationId became `app.kosha.keyboard` (keeping `app.myna.keyboard` would have mismatched the Kotlin namespace in every adb script and IME id; Wave 5 sets `io.github.<username>.kosha`). Formats keep their byte lengths: pack magic `KOSHAPAK` (`.koshapack`), backup magic `KOSHBK` (`.koshabackup`); keystore alias `kosha.secure_store.v1`; theme ids `kosha_*`. Old dev data does not carry over: the emulator was reinstalled and both packs re-imported. The archived Wave 1-3 briefs keep the old name. Name not trademark-checked yet (Wave 5).
- **Brand: "treasure chest key"** icon: a small rounded treasure chest whose lock is a keyboard key, gold on Material You colours. No character mascot; the chest has the poses (open, locked, glowing, closed) in place of the myna bird.
- **InScript (done, `238cbcc`):** `tool/indic/make_inscript.dart` writes the 5 layouts from the BIS tables (xkeyboard-config `deva`, `ben_inscript`, `tam`, `tel`); 11 columns; extra characters on popups (listed in the tool); `test/keyboard/layouts_inscript_test.dart`. `make_layouts.py` now writes only translit and phonetic. On the emulator: Hindi नमस्ते, Tamil வணக்கம் (ண = Shift+ம). The phonetic layouts are still unchecked against any chart.
- **APK size:** the perf agent (D) builds a reduced-operator onnxruntime 1.28 (only the operators the Whisper and Opus-MT models use; no telemetry; keep the `VERS_1.28.0` symbol version or re-patch sherpa).
- **CJK data:** Chinese (rime-ice, OpenCC) and Japanese (Mozc) dictionaries ship as signed `.koshapack` packs, imported in Model packs, not in the APK.
- **Agents:** Haiku, high effort, for all five (brand, Chinese, Japanese, a11y/l10n, perf/QA).

## Wave 3 finish (2026-11-22 evening)

- Reran everything on `main` before and after the fixes: format clean, analyze 0 issues, `flutter test` 1020, JVM 103 (5 skipped).
- **Voice did not work on a device:** `libsherpa-onnx-jni.so` asks for `OrtGetApiBase@VERS_1.28.2`, our libonnxruntime 1.28.0 exports `@@VERS_1.28.0`, and Android's linker enforces symbol versions (`UnsatisfiedLinkError`, panel said "could not start"). Maven has no onnxruntime-android 1.28.2 (only 1.28.0 and 1.29.0). Fix: `tool/patch_sherpa_ort_version.dart` rewrites the one version need to `VERS_1.28.0` and its ELF hash (2 bytes per ABI); `test/tool/patch_sherpa_ort_version_test.dart` fails if an unpatched `.so` is committed. Safe because OrtGetApiBase is the only ORT symbol sherpa imports and the OrtApi level (28) is the same. Notices list both hashes (Apache-2.0 modification note). **Rerun the patch whenever the sherpa libs are re-copied.**
- **Urdu layout:** the v key typed `ۇ` (U+06C7, Uyghur/Kyrgyz, not Urdu), and `ش` was only on a long press. The key is now `ش` (popup ط ظ); the test's Urdu letter list had `ۇ` too and now forbids it.
- **Key semantics:** with Shift on, InScript keys spoke the unshifted letter (label ष, TalkBack "स"); with lowercase labels on, letters spoke lower case although they type upper case. Semantics now use `outputFor` with the real shift state.
- **ZWJ/ZWNJ popup cells** were blank; they now show "ZWJ"/"ZWNJ" (`displayLabel`) and have spoken names.
- **Release gate:** now exits 2 with no APK arguments (it used to pass silently) and fails on `ai/onnxruntime/telemetry` classes or a `TelemetryInitializer` provider.
- Emulator smoke test (API 37), all pass:
  - voice with the Whisper base pack and the old `modelId: "base"` setting: sherpa-onnx loads, model in 1175 ms, "Listening. Speak now.", On-device badge; Stop and Cancel close the panel and release the mic (each `rec start` has a `rec stop` in `dumpsys audio`); 5 s of silence ends the session by design (`silenceLimitSamples`). Recognition quality untested (the emulator mic gives silence).
  - password field: private-field chip only, no toolbar, no mic.
  - space-bar long press: picker lists the 5 enabled languages with their layouts, the selected one marked, then "Language settings" and "Switch keyboard" (scrolls).
  - Urdu: mirrored strip and toolbar, "Space, اردو", ، and ۔, "سلام" with suggestions, "شکریہ" after the fix.
  - Eastern digits: Urdu ۱۲۳, Arabic ١٢٣ on the symbols page; Latin digits when the setting is off.
  - Tamil "vanakkam" → வணக்கம், Telugu "namaskaram" → నమస్కారం (best in the centre); Telugu InScript క్క.
  - Hindi InScript: क + ् + ZWJ (hold the virama, slide to the second cell) + ष = U+0915 094D 200D 0937.
- Release (`--split-per-abi`): **arm64 79.0 MB** (82,844,008 bytes; about 49 MB gzip-compressed, roughly the download size), armeabi-v7a 67.9 MB, x86_64 86.4 MB. Was 25.4 MB. Biggest parts: libonnxruntime.so 27.3 MB (full build, stored uncompressed), libflutter 10.8, libapp 7.1, sherpa 4.4, dictionaries and translit data about 25 MB (en 3.0, most others 1.0-1.4 each).
- Permissions: VIBRATE, RECORD_AUDIO, USE_BIOMETRIC, USE_FINGERPRINT, app-private receiver. No INTERNET, ACCESS_NETWORK_STATE or ACCESS_WIFI_STATE.

## Wave 3: open items for the user

- Licences to confirm before release: the pt-BR word list (AOSP-derived, patched; see `docs/notices/european.md`) and the Arabic list (HeliBoard says CC BY 4.0 from Leipzig; not checked directly).
- Translation speed: 200-560 ms per sentence on this PC's CPU in Python; the 300 ms phone budget is not met yet. Not measured in Kotlin or on a phone.
- ~~InScript layouts wrong~~: fixed in the Wave 4 setup (`238cbcc`). The phonetic layouts were never checked against a chart.
- APK size: 79 MB arm64 (see above). A reduced-operator onnxruntime build, or moving dictionaries into packs, would cut it a lot.
- Toolbar holds up to 8 buttons (about 40 dp each, under 48 dp); Insert in the translate strip is 44 dp tall.
- Toggling translation on or off takes effect at the next keyboard start (hooks are fixed at attach).
- Not mirrored in RTL: the keyboard's own backspace and shift glyphs and the toolbar icons (orchestrator files).
- Urdu has no next-word data; Cyrillic vowel-confusion search is not applied.
- Auto-capitalisation did not trigger at the start of the testbed's text field (probably no CAP_SENTENCES flag there); check in a normal app.

## Emulator notes (learned this wave)

- `uiautomator dump --windows` includes the keyboard window; a plain dump does not. Helper script: `tool/ui_smoke.ps1` (Get-Ui, Show-Ui, Tap-Ui, Type-Keys; dot-source it after `tool/adb_ime.ps1` is reachable).
- Long-press popups have no accessibility nodes. Hold with `adb shell input motionevent DOWN x y`, wait ~900 ms, `MOVE` to the item (the first sits over the key, then one key width each), `UP`. A plain hold-and-release commits the first item.
- The voice panel closes itself after 5 s of silence, so tap Stop/Cancel by coordinates within that time (a `--windows` dump takes ~1.5 s).
- If the emulator is not running: `Start-Process "$env:ANDROID_HOME\emulator\emulator.exe" -ArgumentList '-avd','Medium_Phone_API_37.0','-no-snapshot-save'`, then `Wait-Device`.
- Reinstalling the APK, or force-stopping the app while Kosha is the keyboard, makes Android switch to Gboard: run `Enable-Kosha` after both, and force-stop before enabling, not after.
- Change languages quickly by editing `no_backup/data/settings.json` through `run-as app.kosha.keyboard` (force-stop first; a fresh install has no `settings.json` until a setting changes).
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

1. GitHub username, for `io.github.<username>.kosha`: deferred to Wave 5 (placeholder `app.kosha.keyboard` until then).
2. ~~The app name~~: decided 2026-11-22, **Kosha** (see "Wave 4 decisions").

Answered 2026-11-21: only hi/mr/bn/ta/te for Indic; voice uses sherpa-onnx + Whisper with no bundled model (packs only); the translator joins Wave 3; packs use a dev signing key until Wave 5.
