# Handoff: continue from here after /clear

State as of 2026-11-23 (morning). `main` is clean; nothing is pushed. **Wave 4 is mid-merge: E, D, A, B are merged; C is not finished.**

## Where things stand

- **Merged on `main`:** E brand (`05d71a7`), D perf/QA (`a9d8a4b`), A Chinese (`47248ec`), B Japanese (`d0ab376`). Their worktrees and branches are removed.
- **C (a11y + l10n) is NOT done.** It was stopped by a usage limit, resumed, then stopped by the orchestrator when the user paused. Its work is on branch `worktree-agent-a01a391e601d1c4ef` (worktree `.claude/worktrees/agent-a01a391e601d1c4ef`, still present):
  - `96c0287`: the TalkBack part (done).
  - `e82a126` and `463a8b5`: WIP string/ARB work (47 files, unverified, quality gate not run).
  - When stopped it was working on Hindi/Indonesian "needs review" flags in the ARBs, a hard-coded-string scanner test, and a Flutter warning that German is not supported by all localisation delegates.
  - Its edits outside `lib/src/app/**`, `lib/l10n`, `a11y` are all on its allowed list (strip, candidates, clipboard panel, keys_painter, key_visuals). Check whether it changed `lib/src/app/app.dart` (orchestrator-owned; it was told to revert unless string-only).
- **After-merge work already on `main`:**
  - `830b8fb`: fixed D's two InputController bugs (a restart over a composing word dropped it; insertText over a composer preedit lost the preedit). Repros unskipped; the fuzz test now exercises both paths. D's test files converted to LF; `dart_test.yaml` declares the `perf` tag; manifest has `android:roundIcon` (E).
  - `.claude/worktrees/` is in `.git/info/exclude` (a `git add -A` had picked up the worktree gitlinks once).
  - Chinese pack staging now writes `NOTICE.txt` (rime-ice GPL-3.0 and OpenCC Apache-2.0 texts). Re-staged in `%USERPROFILE%\.kosha\packs\staging\dict-zh-rime-ice`: zh.kdict 36.8 MB, s2twp.tsv 1.2 MB, NOTICE.txt. **Not signed yet.**
  - `326b31f`: Japanese golden corpus replaced. The Aozora corpus (pre-war spellings, top-1 20%, ruby licence unclear) became Tatoeba furigana (CC BY 2.0 FR, `tool/japanese/build_golden_tatoeba.py`, raw data in `%USERPROFILE%\.kosha\packs\download\tatoeba`). The test counts kana/kanji spelling variants (下さい/ください) as right and checks top-5 for whole kanji words only. Result: top-1 83.7% (exact 64.0%), segment top-5 95.4%.
  - `67d81ec`: `DataBlobs.learnedZhPhrases`, `learnedJaWords`, `learnedOpaque`, `isLearnedWords`. Wipe and sizes already covered both (prefix `learned_`), but backup restore decoded them as LearnedData, which would have erased them. Now they are restored byte for byte (a merge keeps the phone's copy). Tests added.
- **Not run yet on merged `main`:** full `flutter analyze` and `flutter test`, JVM tests, debug build, emulator, release gate. Only targeted suites ran: fuzz + keyboard (340), security (50), Japanese golden.
- **onnxruntime reduced build (D, Part 1) is BLOCKED:** from this PC GitHub returns 404 for `microsoft/onnxruntime` (repo page, tags, archive; the orchestrator confirmed it), while other repos work. D left `tool/onnxruntime/{model_ops.py,model_ops.txt,check_aar.ps1,build_android.ps1}` (39 operators over 30 models; build script untested). `build.gradle.kts` is unchanged, so the APK stays about 79 MB.

## Do next (in order)

1. **Finish C.** Launch one agent (`Agent`, `isolation: "worktree"`, `model: "haiku"`, `effort: "high"`, background) with this prompt:
   `You are Wave 4 agent C (accessibility and localisation) on the Kosha keyboard. A previous run was stopped mid-way. First run: git merge worktree-agent-a01a391e601d1c4ef. Then read docs/waves/wave4/COMMON.md and docs/waves/wave4/C-a11y-l10n.md, check what is already done (the TalkBack part is committed; the ARB/string move is WIP), and finish it: review flags for hi and id, the hard-coded-string scanner, the German localisation-delegate warning, then the full quality gate. Do not edit lib/src/app/app.dart. Do not localise lib/src/app/chinese/, lib/src/app/japanese/ or the learned rows in privacy_format.dart and privacy_center_screen.dart: the orchestrator does those. Commit early and often. End with the report COMMON.md asks for.`
   After it reports: `git log main..<branch>`, `git diff main...<branch> --stat` vs `--ignore-cr-at-eol`, files outside its ownership; then `git merge --no-ff`. Remove both C worktrees and branches (unlock, `git worktree remove --force`, `git branch -d`).
2. **Remaining after-merge chores:**
   - Privacy center: `privacy_center_screen.dart` (`learnedBlobNames`) and `privacy_format.dart` must use `DataBlobs.isLearnedWords` for the learned-words viewer list, and show `learned_zh_phrases` / `learned_ja_words` as "Chinese phrases" / "Japanese words" with their size and no viewer.
   - Move A's and B's screen strings (`lib/src/app/chinese/chinese_screen.dart`, `lib/src/app/japanese/japanese_screen.dart`) into the ARBs (all 7 locales).
   - E's mascot: `lib/src/app/privacy/privacy_widgets.dart:15` gets `pose: KoshaPose.locked`; the other call sites keep the default (open). Consider `glowing` for voice/translation and `quiet` for incognito and empty states.
   - Manifest: `android:localeConfig="@xml/locales_config"` (C's `res/xml/locales_config.xml`).
   - B's gaps: segment resize needs a button pair in the candidate strip (orchestrator file; the composer already handles `segmentShorter`/`segmentLonger`); `symbols_ja.json` is not built.
   - **Sign the packs** (key `%USERPROFILE%\.kosha\keys\pack-dev.pem`; check `dart run tool/make_pack.dart --help` for the key flag), then copy them to `%USERPROFILE%\.kosha\packs\signed\`:
     - Chinese: `dart run tool/make_pack.dart --dir "C:\Users\kgnan\.kosha\packs\staging\dict-zh-rime-ice" --id dict-zh-rime-ice --kind dictionary --name "Chinese (Simplified) dictionary" --languages zh --engine rime-ice --license GPL-3.0-or-later --out build/packs/dict-zh-rime-ice.koshapack`
     - Japanese: staging exists from 2026-11-22 (japanese.lex.gz 18.3 MB, japanese.conn.gz 2.0 MB, NOTICE.txt). Rerun `tool/packs/japanese/stage_mozc.ps1` and use the make_pack line it prints (`dict-ja-mozc`, BSD-3-Clause).
3. **Checks on merged `main`:** `dart format --line-length 120 lib test pigeons`, `flutter analyze` (0 issues), `flutter test` (expect about 1230+), `flutter build apk --debug`, `cd android; .\gradlew.bat :app:testDebugUnitTest` (105, 5 skipped).
4. **Emulator smoke test** (emulator-5554 only: `$env:ANDROID_SERIAL='emulator-5554'`; `. .\tool\adb_ime.ps1`; `tool/ui_smoke.ps1`):
   - import both dictionary packs in Model packs;
   - typing regressions (English autocorrect, Hindi, Arabic);
   - Chinese "nihao", "zhongguoren", "nh", a partial pick, the grid, Traditional output, full-width punctuation, the no-pack chip;
   - Japanese flick, multi-tap, ゛゜小, romaji "nihongo" with conversion and segment moves;
   - TalkBack on the keys; the settings app in Hindi and German;
   - the new icon, themed icon, splash in light and dark;
   - voice and translation still work;
   - `tool/bench/device_bench.ps1 -Phase latin` and `-Phase voice` (D's script; refuses other serials), then fill the device table in `docs/perf/budgets.md`.
5. **Release gate:** `flutter build apk --release --split-per-abi`, then in Git Bash `bash tool/check_release_permissions.sh build/app/outputs/flutter-apk/*-release.apk`; note the arm64 size.
6. Fold `docs/notices/{chinese,japanese,onnxruntime}.md` (and C's, if any) into `THIRD_PARTY_NOTICES.md` and `assets/notices/third-party-data.txt`.
7. Update this file, `docs/waves/README.md` and memory. Summarise the open items for the user and **ask the Wave 5 option questions before writing anything**: GitHub username for `io.github.<username>.kosha`, a trademark check of the name "Kosha", the release signing key, plus the open items below.

## Wave 4 open items for the user (so far)

- **onnxruntime source unreachable** (GitHub 404 for microsoft/onnxruntime from this PC): the reduced build needs another network or a source mirror. The APK stays 79 MB arm64 until then.
- **Licences to confirm:** the IPAdic terms inside the Mozc dictionary (a custom permissive licence with an ICOT clause; B asks whether it is fine for GPL-3.0-or-later). Tatoeba CC BY 2.0 FR is test data only, not shipped.
- **Chinese (A):** no next-word predictions (rime-ice has no bigrams); no as-you-type completions ("nih" does not offer 你好); fuzzy pinyin is single-substitution only; Traditional conversion not checked byte for byte against OpenCC. Golden top-1 90.7%, top-5 99.7% (the corpus comes from the same dictionary, so it measures segmentation and ranking). Pack 36.3 MB, load 84 ms on the PC, RSS +57 MB.
- **Japanese (B):** pack 20.3 MB, load 201 ms on the PC, RSS +75 MB; conversion p95 0.83 ms. Misses are homophones (飼って→買って). Segment resize needs strip buttons; `symbols_ja` is missing.
- **Memory:** +57 MB (zh) or +75 MB (ja) on top of the keyboard is close to the 120 MB keyboard budget; measure on the emulator with `device_bench.ps1`.
- **Perf (D, host):** key → commit p95 0.61 ms, suggest p95 1.14 ms (3 languages), swipe p95 1.19 ms, frame p95 7.34 ms. Device numbers pending.

## Wave 4 decisions (user, 2026-11-22 evening)

- **Name: Kosha** (Sanskrit/Hindi *kosha*, "treasury, a store of gold": your words are your treasure, kept with you). **Full rename** in the Wave 4 setup by the orchestrator, before agents start: app name, strings, docs, notices, Dart package `myna`→`kosha`, Kotlin packages and classes (`MynaImeService`→`KoshaImeService`, `MynaMascot`, `MynaLog`, …), backup/pack magic names where safe. **Done in `4a3c394`:** besides the code, the placeholder applicationId became `app.kosha.keyboard` (keeping `app.myna.keyboard` would have mismatched the Kotlin namespace in every adb script and IME id; Wave 5 sets `io.github.<username>.kosha`). Formats keep their byte lengths: pack magic `KOSHAPAK` (`.koshapack`), backup magic `KOSHBK` (`.koshabackup`); keystore alias `kosha.secure_store.v1`; theme ids `kosha_*`. Old dev data does not carry over: the emulator was reinstalled and both packs re-imported. The archived Wave 1-3 briefs keep the old name. Name not trademark-checked yet (Wave 5).
- **Brand: "treasure chest key"** icon: a small rounded treasure chest whose lock is a keyboard key, gold on Material You colours. No character mascot; the chest has the poses (open, locked, glowing, closed) in place of the myna bird.
- **InScript (done, `238cbcc`):** `tool/indic/make_inscript.dart` writes the 5 layouts from the BIS tables (xkeyboard-config `deva`, `ben_inscript`, `tam`, `tel`); 11 columns; extra characters on popups (listed in the tool); `test/keyboard/layouts_inscript_test.dart`. `make_layouts.py` now writes only translit and phonetic. On the emulator: Hindi नमस्ते, Tamil வணக்கம் (ண = Shift+ம). The phonetic layouts are still unchecked against any chart.
- **APK size:** the perf agent (D) builds a reduced-operator onnxruntime 1.28 (only the operators the Whisper and Opus-MT models use; no telemetry; keep the `VERS_1.28.0` symbol version or re-patch sherpa).
- **CJK data:** Chinese (rime-ice, OpenCC) and Japanese (Mozc) dictionaries ship as signed `.koshapack` packs, imported in Model packs, not in the APK.
- **Agents:** Haiku, high effort, for all five (brand, Chinese, Japanese, a11y/l10n, perf/QA).

## Wave 4 setup seams (`f2fd99a`)

- **Composer:** `lib/src/keyboard/input/composer.dart` (`TextComposer`, `ComposerState/Step/Candidate`, `ComposerKeys`). `InputController.composer`/`composerState`/`composerActive`/`selectCandidate`/`onCustomKey`; it runs in text fields only (not passwords, email/URL, forceAscii); swipe, the predictor and autocorrect are off meanwhile; outside edits and new fields reset it; cursor moves go to it while it holds text.
- **Candidates:** `lib/src/keyboard/candidates/` (strip replaces suggestions while the composer has state; grid is a `PanelPlacement.keys` panel).
- **Flick:** `KeyDef.flick` keys show `FlickGuideState` and type the direction (a third of a key width, dominant axis); flick keys never swipe; `KeyType.custom` → `onCustomKey`; `KeyDef.spoken` for TalkBack. Checked on the emulator: あ/い/お/く.
- **Languages:** zh (`pinyin_zh`) and ja (`kana12_ja` default, `romaji_ja`) seeded in agent files; `CjkRules`; `LayoutChoice.composes` (blend = active only). The 12-key layout has its own globe key (`withLanguageKey` skips narrow space keys).
- **Packs:** `PackKind.dictionary`, `PlatformHostApi.getPackDirectory`, `lib/src/packs/installed_packs.dart`, a Dictionaries group on Model packs.
- **Settings:** `chinese`/`japanese` sections, routes with stub screens linked from Languages ("Language options").
- **l10n:** flutter_localizations + intl 0.20.3; `l10n.yaml`, `lib/l10n/app_en.arb` (generated `app_localizations*.dart` committed, excluded from analysis); `lib/src/app/l10n.dart` (`koshaLocalizationsDelegates` with material_ui's Material delegate, `context.l10n`). Every test `MaterialApp` passes the delegates.
- After the merge: register blobs `learned_zh_phrases` and `learned_ja_words` (wipe, backup, privacy sizes); move A/B screen strings into the ARBs; apply E's `KoshaMascot(pose:)` call sites; add `android:localeConfig` (C) and `android:roundIcon` (E) to the manifest; sign the CJK dictionary packs.

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
