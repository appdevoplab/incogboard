# Wave runbook (orchestrator)

## Merge checklist (after each wave)

1. For each agent branch, in this order: E (android), D (theme), B (text engine), C (gesture), A (keyboard view):
   - `git merge --no-ff <branch>`
   - Resolve conflicts. There should be none, because ownership is disjoint; `docs/notices/*` are separate files.
2. Fold `docs/notices/*.md` into `THIRD_PARTY_NOTICES.md`.
3. Run checks:
   - `dart format --line-length 120 lib test pigeons`
   - `flutter analyze`
   - `flutter test`
4. Build `flutter build apk --debug`, then smoke-test on emulator-5554 only (`$env:ANDROID_SERIAL='emulator-5554'`; `. .\tool\adb_ime.ps1`):
   - Type in each testbed field.
   - Check passwords (no suggestions; screenshot shows a black keyboard).
   - Check email/url pages and swipe ("hello", "world").
   - Check suggestions and autocorrect ("teh " → "the ").
   - Check themes in light and dark mode.
5. Release check: `flutter build apk --release --split-per-abi`, then aapt2 permissions must show no INTERNET.
6. Commit the merge, and update the memory file myna-project.md with the wave status.

## Wave 2: product (5 agents)

**Status:**
- The setup is done (commit `bcdcc10`): image_picker and local_auth, the Pigeon additions, and the keyboard and settings-app seams with 18 seam tests.
- Briefs are in `docs/waves/wave2/`; ownership is in `docs/PARALLEL_WORK.md`.
- Launch with `model: sonnet`, `effort: high` and `isolation: worktree`, using a short prompt that points at `COMMON.md` plus the agent's brief.

**Merge order:** B, C, D, E, A. A goes last because its shell links to everyone's screens.

**After merging:**
- Wire anything B reports for `SettingsActivity` (document pickers).
- Replace stubs if an agent left one.
- Run the Wave 1 checklist, plus emulator checks:
  - onboarding
  - theme photo and a custom theme in the keyboard
  - emoji panel and search
  - the clipboard chip after copying in another app
  - the editing keys
  - one-handed, floating and resize
  - cursor drag and backspace swipe
  - app lock and backup round trip
  - privacy center sizes and wipe

| Agent | Owns | Brief |
|---|---|---|
| A | `lib/src/app/shell,onboarding,settings,languages/**` | Settings shell (M3E grouped containers, large headers). Onboarding: enable, then switch, then the "may collect text" explainer, then pick languages and theme, then try it, illustrated with the Myna mascot. Typing, feel and panels settings screens. Implement AppFlutterApi so the app reloads settings. Optional `material_3_expressive` package only after a licence/code audit. |
| B | `lib/src/app/privacy/**`, `lib/src/security/**`, Kotlin backup crypto under `android/.../security/backup/` | Privacy center: proof of no internet, stored-data sizes, incognito rules per app, wipe per category, learned-words viewer and editor, personal shortcuts. App lock with local_auth (strong biometric or device credential), a timeout, and FLAG_SECURE plus no recents thumbnail on sensitive screens. Encrypted `.mynabackup` file: PBKDF2-SHA256 with 600k iterations, AES-256-GCM, SAF picker, preview, then merge or replace. |
| C | `lib/src/app/themes/**`, plus theme repository additions in `lib/src/theme/custom/**` | Theme gallery as an M3 carousel. Editor with a live preview of the real keyboard widget and a try-typing field. Photo background through the Photo Picker, with crop and pre-rendered blur/dim saved to app storage. Custom themes stored as JSON. |
| D | `lib/src/features/emoji,clipboard,editing/**`, `tool/build_emoji.dart`, `assets/emoji/**` | Emoji from `emoji-test.txt` plus CLDR annotations (Unicode licence) for every planned language. Search uses the keyboard's own keys. Skin tone remembered per emoji, recents, hasGlyphs filtering, and kaomoji and symbols tabs. Clipboard panel: pins, expiry, recent-copy chip, masked sensitive items, all through SecureBlobStore. Editing panel: arrows, selection, cut/copy/paste, undo/redo, home/end. Emoji suggestions in the strip. |
| E | `lib/src/keyboard/modes/**` (A from Wave 1 hands over hooks) | One-handed (left/right, 80% width, swap/expand buttons). Floating (drag, resize, snap, uses Kotlin floating insets). Height adjust handle. Spacebar cursor drag with acceleration. Backspace swipe-left word delete with highlight and undo. Tablet/foldable split layout and landscape compact layout. |

## Wave 3: languages, voice and translation (5)

**Status (2026-11-22):**
- Setup done (commit `92ead05`): Pigeon voice/translation/pack calls, the Kotlin pack store (signed `.mynapack`) and service stubs, onnxruntime-android 1.31.1, the language registry and seams, and the strip's toolbar toggle (fixes the hidden toolbar).
- Briefs are in `docs/waves/wave3/` (A, B, C, D, T); ownership is in `docs/PARALLEL_WORK.md`.
- **User decisions (2026-11-21):**
  - The translator joins Wave 3 as agent T; brand (old E) moves to Wave 4.
  - Voice: sherpa-onnx + Whisper; no bundled model, packs only.
  - Indic: only hi/mr/bn/ta/te (no pack template for others).
  - Packs are signed with an ECDSA P-256 dev key (`%USERPROFILE%\.myna\keys\pack-dev.pem`, outside the repo); Wave 5 swaps in the release key.
  - The app name and the GitHub username wait for Wave 5.

**Merge order:** A, C, B, T, D. A first because it owns the text engine and the dictionary tool; D last because it adds native libraries.

**After merging:** sign the staged packs with `tool/make_pack.dart`, then run the checklist plus:
- languages: German + English blend, French spacing, Russian, the globe key and space-bar picker
- Hindi in English letters, Hinglish, InScript; Tamil/Telugu rendering
- Arabic and Urdu typing, the mirrored strip and panels, Eastern digits
- voice: permission prompt, no pack, then the base pack (partials, Stop, Cancel)
- translation: pack import, EN → ES in the panel, the selection chip

Original plan for the wave:

- **A:** es/fr/de/pt-BR/pt-PT/id/ru/uk:
  - Layouts: QWERTZ, AZERTY, ЙЦУКЕН, Ukrainian.
  - Dictionaries via `tool/build_dictionary`.
  - LanguageRules per language (French spacing, « », „“).
  - Multilingual blending (≤ 3), plus a language switcher (globe key, long-press space).
  - Locale currency and TLDs.
- **B:** Indic hi/mr/bn/ta/te:
  - Typing in English letters, using Aksharantar (CC0/CC-BY) plus rule-based fallback.
  - Hinglish output toggle.
  - Native layouts (phonetic plus InScript), ZWJ/ZWNJ, native digits.
  - Swipe over QWERTY romanisation.
  - Pack template for gu/kn/ml/pa/or.
- **C:** ar/ur:
  - Right-to-left strip and panels.
  - Arabic standard and Urdu phonetic layouts.
  - Harakat long-press and Arabic punctuation.
  - Eastern digits.
  - Dictionaries (CC BY 4.0; check the GPLv2 rows).
- **D:** voice:
  - whisper.cpp git submodule built with NDK/CMake.
  - JNI in Kotlin, AudioRecord at 16 kHz, VAD chunking, interim composing text.
  - Bundled base model (~60 MB), with import of the small model.
  - Mic panel (M3E animated shape, "On-device" badge).
  - Permission through a transparent non-exported activity.
  - Pigeon additions (voice start/stop/events), done by the orchestrator first.
- **T (was "translator, added 2026-11-21"):** offline English ↔ es/fr/de/pt/hi/ru, a translate panel plus translate-selection, models in separate packs. Plan: `docs/waves/translator.md`.
- **E (brand):** moved to Wave 4.

## Wave 4: CJK, brand and polish (5)

- **E (from Wave 3):** brand:
  - Myna adaptive icon (foreground, background, monochrome).
  - Splash.
  - Mascot poses (wave, lock, sing, sleep).
  - Play 512 icon, feature graphic, store screenshots template.

- **A:** Chinese pinyin, as a Dart lattice converter:
  - rime-ice dictionaries (GPL-3.0) and OpenCC tables (Apache-2.0).
  - Fuzzy pinyin, abbreviations, user phrases, candidate grid, full-width punctuation.
- **B:** Japanese:
  - Romaji (QWERTY) and 12-key flick input.
  - Viterbi conversion with the Mozc OSS dictionary (BSD-3/IPAdic), segment resize, predictions, 「」.
- **C:** TalkBack explore-by-touch, then localise the settings UI (en, es, fr, de, pt, id, hi first).
- **D:** performance and QA:
  - Budgets: first show < 600 ms, warm < 100 ms, key → commit < 30 ms, swipe p95 < 40 ms, memory < 120/250 MB.
  - Fuzz the InputController, check jank, and build an OEM matrix.

## Wave 5: release (3)

- **A:** security audit:
  - Threat model, `/security-review`, dependency licence audit, pin CI actions to SHAs.
- **B:** release engineering:
  - Signing, `play` and `foss` flavors, reproducible builds, fastlane metadata.
  - Privacy policy page, Data safety answers, F-Droid recipe, developer-verification notes.
- **C:** data packs:
  - Play on-demand asset packs for CJK, voice and extra Indic data.
  - FOSS: full build plus signed pack import.
