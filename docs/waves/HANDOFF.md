# Handoff: continue from here after /clear

State as of 2026-11-23 (evening). `main` is clean; nothing is pushed. **Waves 0-5 are merged** (Wave 5: A security audit, C data packs, B release engineering). What is left is the user's list ("Before the first store release") and the polish items.

## Renamed to IncogBoard (2026-11-24)

The app is now **IncogBoard** (was Kosha). Package and namespace `app.incogboard.keyboard` (placeholder applicationId, becomes `io.github.<username>.incogboard`), Dart package `incogboard`, Kotlin dir `app/incogboard`, classes `IncogBoardImeService`/`IncogBoardApplication`, functions `Install-IncogBoard`/`Enable-IncogBoard`, F-Droid recipe `metadata/app.incogboard.keyboard.yml`. Checks after the rename: format (width 120), analyze 0 issues, 1404 Flutter tests, JVM tests, foss and play release builds, permission gate.

**Deliberately unchanged** (persisted, signed or on the user's machine; changing them breaks existing data or keys): the pack format `.koshapack` and magic `KOSHAPAK`, the backup format `.koshabackup`, the Keystore alias `kosha.secure_store.v1`, every `KOSHA_*` environment variable and CI secret name, `%USERPROFILE%\.kosha\` (keys, packs, release), `kosha-release.p12` and alias `kosha-release`, and the known-answer plaintext "Kosha backup test vector" in `BackupCryptoTest`. Not rewritten (historical): `docs/waves/wave4`, `docs/waves/wave5`, `docs/PARALLEL_WORK.md`, `docs/waves/translator.md`, `docs/brand/trademark-check.md` (that trademark check was for "Kosha": redo it for "IncogBoard" before the store release). Stale pre-rename APKs without a flavour name may sit in `build/app/outputs/flutter-apk/`: gate only `app-*-foss-release.apk` and `app-*-play-release.apk`. Do not run plain `dart format .`: use `dart format --line-length 120 lib test pigeons tool/audit`.

Steps 1 to 4 below were NOT started in this session (the rename came first). Read paths below with `kosha` as `incogboard`.

## Emulator retest result (2026-11-24)

Foss release APK (`app-x86_64-foss-release.apk`, built after the Pigeon wiring) on emulator-5554 (`Medium_Phone_API_37.0`, API 37, started with `-port 5554`; it was not running at the start of the session). Results:

- Model packs screen shows the foss import-only state (so `packDelivery` answered 'import').
- Imported `dict-zh-rime-ice` and `dict-ja-mozc` from `%USERPROFILE%\.kosha\packs\signed` (release-key signed; pushed to /sdcard/Download): both accepted.
- Verify installed packs: "2 installed packs checked. All files match."
- Footer shows free space ("6924 MB free on this phone"), from `packStorage`.
- Chinese: "nihao" gives candidate 你好 first (10 candidates); tapping it commits 你好.
- Japanese (12-key flick layout, not romaji): flicks に ほ ん ご give 日本語 first (22 candidates).
- Delete: deleting the Japanese pack asks for confirmation, removes it, footer drops to 36 MB.
- Logcat: no FATAL EXCEPTION, no ANR, no `flutter` W/E lines.

Not covered: the play flavour on a device, store offers (no Play delivery yet), the voice and translation packs (release builds reject the old dev-signed copies still on the emulator's Download folder). The emulator was left running with the Chinese pack installed.

## Do next (in order)

1. **DONE 2026-11-24 (commit after 4c8961e): Pigeon wiring for pack maintenance** so Verify installed packs works (`docs/packs/README.md`, "Bridge additions"): add the methods to `pigeons/messages.dart`, regenerate (`dart run pigeon --input pigeons/messages.dart`, then `dart format --line-length 120 lib/src/bridge/messages.g.dart`), implement in `PlatformHostApiImpl.kt` (CRLF file: edit with Python, not sed), replace `UnavailablePackMaintenance`. Add a Dart-visible flavour value in the same change if cheap.
2. **DONE 2026-11-24 (see "Emulator retest result" below): Retest on the emulator** with the foss release APK (emulator-5554 only, `. .\tool\adb_ime.ps1`, `tool\ui_smoke.ps1`; release builds have no testbed and no `run-as`: type in Android Settings search, `am start -a android.settings.APP_SEARCH_SETTINGS`): Chinese "nihao", Japanese "nihongo" with both packs imported from `signed\`, Verify, delete a pack.
3. **Play bundle:** move `PlayAssetPackSource.kt.txt`, add the includes and `play` dependencies (patches in `docs/release/asset-packs.md`), remove the extra permissions with `tools:node="remove"`, `tool/packs/build_bundle.ps1`, bundletool `--local-testing` on the emulator, gate on the merged `play` manifest.
4. **Apply the remaining audit patches** (P2/P3/P6 and SEC-05/06/08-11/15) after the user answers D1, D2 and the SEC-03 question; change the onboarding disclosure text (all ARBs, x-review).
5. Polish items from "Open work" below; then, when the user has their GitHub username, `tool/release/set_application_id.ps1`, a clean-clone build, `tool/release/verify_reproducible.ps1`, and the store steps in `docs/release/checklist.md`.

## Wave 5 result (merged 2026-11-23)

- **A:** `docs/security/` (threat model, audit with 20 findings, licence audit: 157 of 158 components ok), `SECURITY.md`, hardened CI (actions pinned by SHA; I added `--flavor foss`), Dependabot, `tool/audit/`, `test/security/`, `docs/brand/trademark-check.md` (risk medium; closest is the App Store app "IncogBoard: Private Vault"; recommends "IncogBoard Keyboard" plus a professional class 9/42 search).
- **C:** pack key list (`PackKeys.trusted`; release key list in `ReleasePackKeys.kt`; dev key only in debuggable builds), `make_pack.dart --key` required (dev key only with `KOSHA_ALLOW_DEV_KEY=1`), `--verify`/`--key-id`, the Model packs screen (how to get, Copy link, Verify, free space), the Play asset-pack seam, four modules in `android/asset_packs/`, `tool/packs/build_bundle.ps1`.
- **B:** flavours `foss` and `play` (identical today), release signing from `android/key.properties` or `INCOGBOARD_*` variables, `tool/release/` (keys, application id swap, version bump, build, reproducibility check), fastlane texts (en-US full, six locales title and short text, machine drafts), F-Droid draft recipe, privacy policy, Data safety answers, `docs/release/` incl. `checklist.md`, a draft-only `release.yml`.
- **Orchestrator after the merge:**
  - Applied A's patches P1 (restore validates settings before writing), P4 (overflow-safe pack size), P5 (PBKDF2 cap 2M).
  - **Release keys generated** in `%USERPROFILE%\.kosha\release\` (`kosha-release.p12`, `release-keystore.password`, `key.properties`, `pack-release.pem`, `pack-release.pub.b64`/`.pub.pem`). Keystore SHA-256 `6E:07:C8:BC:...:7D:B4:1D`; pack key id `ec3c5b2aebea85ac`. **The user must back up that folder to two offline places.** `android/key.properties` is a git-ignored copy.
  - The pack public key is in `ReleasePackKeys.kt`; the JVM release-gate test passes with `KOSHA_RELEASE_GATE=1`.
  - All four dev packs (zh, ja, voice base, translate en-es) are re-signed with the release key in `%USERPROFILE%\.kosha\packs\signed\`; the dev-signed originals are in `signed\dev-signed\`. Only these four were re-signed; other staged packs (other translation pairs, voice small) were never signed.
- **Checks on merged `main`:** format clean, analyze 0, `flutter test` 1404 pass (5 skipped), JVM 104+ pass for foss, both flavours build per ABI (arm64 83,988,755 B = 80.1 MiB), permission gate and network audit pass, release APK signed with the release key (verified with apksigner).
- **Emulator (foss release, x86_64):** keyboard starts, Japanese romaji converts (にほんご candidates before the pack was imported); a release build rejects dev-signed packs (all showed "not installed") and accepts release-signed ones (zh and ja imported through the picker, Model packs screen shows how-to text and Copy link).
- **Not covered:** Chinese typing and Japanese conversion with the release-signed pack after reinstall (import worked, typing not retested), the Verify button (see below), the Play flow (no AAB yet), TalkBack.

## Before the first store release (user)

1. Back up `%USERPROFILE%\.kosha\release\` twice, offline; keep the password in a password manager.
2. GitHub username: run `tool/release/set_application_id.ps1 io.github.<username>.kosha`; fill the About source URL and the release-page URL (`https://example.invalid/incogboard/releases` placeholder in the packs screen) and `<contact email>` in `docs/release/privacy-policy.md`.
3. Decisions: D1 sensitive-field rule (password-only today, plan says wider: patch P2 in `docs/security/audit.md`); D2 confirm before a backup restore changes privacy settings (SEC-17); SEC-03 AAD on the secure store (patch P3, format v2, do before any real user data exists); keep the R8 log rule or strip `w`/`e` too (SEC-14); Play asset delivery library (Google terms; adds INSTALL_PACKAGES and foreground-service permissions that must be removed with `tools:node="remove"`); whether voice and translation packs go through Play or stay import-only; keystore in GitHub secrets or offline only; pack private key unencrypted or add a passphrase to `make_pack`; F-Droid route (committed prebuilt `.so` files need provenance; fallback is a GitHub release plus an own repo); developer account type and public name; Android developer verification (`docs/release/developer-verification.md`).
4. Licences to confirm: IPAdic terms in the Mozc dictionary, OFL font aggregation, Opus-MT CC-BY attribution, pt-BR and Arabic lists (`docs/security/licences.md`).
5. Trademark: professional search before submission (`docs/brand/trademark-check.md`).
6. Native-speaker review of every `x-review` string and the store texts.

## Open work for the orchestrator or a polish wave

- **Pigeon wiring for pack maintenance** (`docs/packs/README.md`, "Bridge additions"): the Verify installed packs button does nothing until `PackMaintenance` gets its Pigeon methods (check, checkAll, free space). Also not done: multi-select import, a size check before import, the signer key id in the import summary.
- Move `android/asset_packs/PlayAssetPackSource.kt.txt` into `src/play/kotlin/...`, add the asset-pack includes to `settings.gradle.kts` and the `play` dependencies, then build the AAB and test on-demand delivery with bundletool `--local-testing` (patches in `docs/release/asset-packs.md`).
- The onboarding warning text does not match Play's keyboard disclosure wording: proposed text in B's report ("A keyboard can collect everything you type, including passwords. IncogBoard has no internet access, so it cannot send anything you type anywhere."); change `onboardingWarningBody` in all ARBs (x-review).
- Browser auto-incognito is in the plan but not in the code (the privacy policy says so): implement or drop it.
- Remaining audit patches: P2, P3, P6 (track the Gradle wrapper with a checksum), SEC-05/06/08-11/15 in `docs/security/audit.md`.
- `device_bench.ps1` fix; Japanese segment-resize buttons and `symbols_ja`; 48 dp targets; locale to the keyboard engine; the reduced onnxruntime build (blocked); memory over budget (154 MB PSS with Japanese).
- Visible Dart flavour (needs a Pigeon method); builds without `--flavor` now fail, use `--flavor foss` (default for `flutter run`).

## Wave 4 state (historical, superseded by the sections above)

- **Merged on `main`:** E brand, D perf/QA, A Chinese, B Japanese, C a11y + l10n (`Merge Wave 4 C`). All agent branches are removed.
  - One empty folder, `.claude/worktrees/agent-a6b134817bc89dd83`, could not be deleted (a process held it open); it is not a registered worktree and is excluded from git. Delete it by hand after a reboot.
- **After-merge work done:**
  - Privacy center lists `learned_zh_phrases` / `learned_ja_words` ("Chinese phrases" / "Japanese words", size, no viewer) and the privacy screens use the `locked` chest.
  - Chinese and Japanese screens and the learned rows are in the ARBs (7 locales, all flagged `x-review`); `android:localeConfig` is in the manifest (the per-app language list works: German and Hindi checked).
  - Both dictionary packs are signed and copied to `%USERPROFILE%\.kosha\packs\signed\` (`dict-zh-rime-ice` 38.1 MB, `dict-ja-mozc` 20.3 MB; key `pack-dev.pem`).
  - Notices for Chinese, Japanese and onnxruntime are folded into `THIRD_PARTY_NOTICES.md` and `assets/notices/third-party-data.txt` (the per-area files stay, scripts reference them).
  - **Bug found on the emulator and fixed:** Japanese conversion never loaded its dictionary on a device (`Isolate.run` closure captured the composer, which holds a Future: "object is unsendable"). Host tests cannot catch this. `_loadDictionaryInIsolate` is now a top-level function. After the fix "nihongo" gives 日本語 first, 421 ms load. Chinese reads its files in an isolate through a top-level function and was fine.
- **Checks on merged `main`:** `dart format` clean, `flutter analyze` 0 issues, `flutter test` 1352 pass, `flutter build apk --debug`, JVM tests 105 (5 skipped), release build and gate pass (no INTERNET; VIBRATE, RECORD_AUDIO, USE_BIOMETRIC, USE_FINGERPRINT, app-private receiver). Release sizes: arm64 80.1 MB (83,988,099 bytes), armeabi-v7a 69.2 MB, x86_64 87.5 MB.
- **Emulator smoke test (emulator-5554, API 37):** both packs imported through Model packs (Downloads picker); English autocorrect ("teh i dont" gives "the I don't"); Hindi "namaste" gives नमस्ते; Arabic keys type Arabic; Chinese "nihao" gives 你好, "zhongguoren" gives 中国人 with the candidate grid, partial picks work; Japanese 12-key flick, multi-tap and ゛゜小 work (き, と, small ぃ), romaji "nihongo" converts to 日本語; settings app in German and Hindi; release build runs with the new theme; the voice panel opens and says a voice pack is needed for Japanese (the Whisper pack lists neither ja nor zh).
- **Not covered:** TalkBack on a device, Traditional output and full-width punctuation on the device, segment moves, the no-pack chip, the icon/splash in dark, voice and translation end to end (unchanged code, not rerun), `device_bench.ps1 -Phase voice`.
- **onnxruntime reduced build (D) is still BLOCKED:** GitHub returns 404 for `microsoft/onnxruntime` from this PC. Scripts are in `tool/onnxruntime/` (untested). The APK stays about 80 MB.
- **`tool/bench/device_bench.ps1` printed empty timing columns** (it clears logcat before reading it, and the PSS parse is wrong); numbers in `docs/perf/budgets.md` came from manual `dumpsys meminfo`. Fix the script.

## Wave 4 follow-ups (historical; the current list is at the top)

1. **Wave 5 option answers (user, 2026-11-23):** keep the placeholder `app.incogboard.keyboard` for now (swap to `io.github.<username>.kosha` at the end; the About source link waits for the username); add a trademark-check task for "IncogBoard" to Wave 5 (public registries and store listings, not legal advice); generate a new release keystore and pack-signing key outside the repo (the user backs them up; replace the dev pack key); build both flavours, `play` (on-demand asset packs) and `foss` (full build plus signed pack import).
2. **Wave 5 briefs are written** (`docs/waves/wave5/`: COMMON, A security audit + trademark check, B release engineering, C data packs). Launch the three agents (Agent, `isolation: worktree`, `model: haiku`, `effort: high`, background) with a short prompt pointing at COMMON.md and the brief; merge order A, C, B. After the merge: run `tool/release/make_release_keys.ps1` (generates the keystore and pack key outside the repo; the user backs them up), put the release pack key into `ReleasePackKeys.kt`, re-sign the packs, apply the patches the agents list for orchestrator files, run the full checks, the emulator test and the release gate for both flavours.
3. Small follow-ups that are not Wave 5: strip buttons for segment resize and `symbols_ja.json` (B's gaps); 48 dp touch targets and passing the locale to the keyboard engine (`docs/a11y/report.md`); fix `device_bench.ps1`; a native-speaker review of the `x-review` strings; speech for ja/zh (needs a Whisper pack that lists them).

## Wave 4 open items for the user

- **onnxruntime source unreachable** (GitHub 404 for microsoft/onnxruntime from this PC): the reduced build needs another network or a source mirror. The APK stays about 80 MB arm64 until then, well over the 60 MB target.
- **Memory:** release build with Japanese loaded is 154 MB PSS / 285 MB RSS for the whole app process, over the 120 MB keyboard budget. Chinese is similar (+57 MB on the PC). A smaller dictionary representation (or loading it lazily) is the next lever.
- **Licences to confirm:** the IPAdic terms inside the Mozc dictionary (a custom permissive licence with an ICOT clause; B asks whether it is fine for GPL-3.0-or-later). Tatoeba CC BY 2.0 FR is test data only, not shipped. The earlier Wave 3 items stand (pt-BR list, Arabic list).
- **Chinese (A):** no next-word predictions (rime-ice has no bigrams); no as-you-type completions ("nih" does not offer 你好); fuzzy pinyin is single-substitution only; Traditional conversion not checked byte for byte against OpenCC. Golden top-1 90.7%, top-5 99.7%. Pack 36.3 MB, load 84 ms on the PC.
- **Japanese (B):** pack 20.3 MB; conversion p95 0.83 ms on the PC; misses are homophones (飼って gives 買って). Segment resize needs strip buttons; `symbols_ja` is missing. Golden: top-1 83.7%, segment top-5 95.4%.
- **Translations are machine-made:** every non-English string is flagged `x-review`; Hindi in full. A native read is needed before release.
- **Perf (D, host):** key to commit p95 0.61 ms, suggest p95 1.14 ms (3 languages), swipe p95 1.19 ms. Device latency in-app was not captured (see the bench script note).

## Wave 4 decisions (user, 2026-11-22 evening)

- **Name: IncogBoard** (Sanskrit/Hindi *incogboard*, "treasury, a store of gold": your words are your treasure, kept with you). **Full rename** in the Wave 4 setup by the orchestrator, before agents start: app name, strings, docs, notices, Dart package `myna`→`incogboard`, Kotlin packages and classes (`MynaImeService`→`IncogBoardImeService`, `MynaMascot`, `MynaLog`, …), backup/pack magic names where safe. **Done in `4a3c394`:** besides the code, the placeholder applicationId became `app.incogboard.keyboard` (keeping `app.myna.keyboard` would have mismatched the Kotlin namespace in every adb script and IME id; Wave 5 sets `io.github.<username>.kosha`). Formats keep their byte lengths: pack magic `KOSHAPAK` (`.koshapack`), backup magic `KOSHBK` (`.koshabackup`); keystore alias `kosha.secure_store.v1`; theme ids `incogboard_*`. Old dev data does not carry over: the emulator was reinstalled and both packs re-imported. The archived Wave 1-3 briefs keep the old name. Name not trademark-checked yet (Wave 5).
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
- **l10n:** flutter_localizations + intl 0.20.3; `l10n.yaml`, `lib/l10n/app_en.arb` (generated `app_localizations*.dart` committed, excluded from analysis); `lib/src/app/l10n.dart` (`incogboardLocalizationsDelegates` with material_ui's Material delegate, `context.l10n`). Every test `MaterialApp` passes the delegates.
- After the merge: register blobs `learned_zh_phrases` and `learned_ja_words` (wipe, backup, privacy sizes); move A/B screen strings into the ARBs; apply E's `IncogBoardMascot(pose:)` call sites; add `android:localeConfig` (C) and `android:roundIcon` (E) to the manifest; sign the CJK dictionary packs.

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
- Reinstalling the APK, or force-stopping the app while IncogBoard is the keyboard, makes Android switch to Gboard: run `Enable-IncogBoard` after both, and force-stop before enabling, not after.
- Change languages quickly by editing `no_backup/data/settings.json` through `run-as app.incogboard.keyboard` (force-stop first; a fresh install has no `settings.json` until a setting changes).
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

1. GitHub username, for `io.github.<username>.kosha`: deferred to Wave 5 (placeholder `app.incogboard.keyboard` until then).
2. ~~The app name~~: decided 2026-11-22, **IncogBoard** (see "Wave 4 decisions").

Answered 2026-11-21: only hi/mr/bn/ta/te for Indic; voice uses sherpa-onnx + Whisper with no bundled model (packs only); the translator joins Wave 3; packs use a dev signing key until Wave 5.
