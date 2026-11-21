# Offline translator: plan

Status: planned 2026-11-21, not started. Fits Wave 3 or 4, next to offline voice (both need native code
and downloadable model packs).

## User decisions (2026-11-21)

- **Language pairs:** English ↔ Spanish, French, German, Portuguese, Hindi and Russian (12 directions).
  Other pairs go through English later.
- **Interface:** a translate panel in the keyboard, plus translating text the user selects in the app.
- **Models:** separate model packs. Play builds use on-demand asset packs; the F-Droid build imports a
  signed pack file. The app itself never gets the INTERNET permission.

## How it works

Gboard sends text to Google's servers. Myna translates on the phone with small neural models.

- **Engine (to verify first):** one of these two. Pick by licence, model availability for all 12
  directions, size and speed on the phone.
  1. Mozilla's Bergamot engine (`bergamot-translator`, built on Marian), with the small Firefox
     Translations models (roughly 15–40 MB per direction).
  2. OPUS-MT models (Helsinki-NLP) run through CTranslate2 with int8 weights, plus SentencePiece.
- **Native code:** built with the NDK and CMake, like whisper.cpp for voice. Kotlin wraps it through
  JNI and runs it on a background thread, one model loaded at a time.
- **Contract:** the orchestrator adds the Pigeon calls first:
  - `translate(text, from, to)`
  - `listTranslationPacks()`
  - `importTranslationPack(uri)` (F-Droid)

## Interface

- **Translate panel:** opened from the toolbar.
  - A row of language chips ("English → Español", swap button).
  - The user types with the keyboard's own keys into the panel's box, like emoji search. The panel
    shows the translation as you type, debounced at about 300 ms.
  - "Insert" puts the translation into the app; typed source text never goes into the app.
- **Translate selection:** when text is selected, the selection chips gain "Translate".
  - It reads only the selected text, and only on that tap.
  - It shows the translation in the strip, with "Replace" and "Insert after".
- **Missing pack:** the panel says which pack to get and opens the settings screen for it.
- **Settings → Translation:** installed packs with sizes, download (Play) or import (F-Droid), and
  delete.

## Privacy rules

- Never available in password fields or while incognito.
- No typed or translated text is stored, logged or learned from. The panel's text is not added to
  learned words or the clipboard history.
- Packs are verified (signature and hash) before loading. A pack is data only, never code.
- The privacy center lists the packs and their sizes.

## Work split (when the wave starts)

1. **Orchestrator:** Pigeon additions, the pack format and the signing key decision.
2. **Agent T1 (native):** engine choice report (licences, sizes, latency on the emulator), NDK build,
   JNI and Kotlin service, pack loading and verification, JVM tests.
3. **Agent T2 (Dart):** translate panel, selection chip, settings screen, privacy center entry,
   widget tests with a fake translator.
4. **Release (Wave 5):** Play asset packs and the F-Droid import file, shared with voice packs.

## Budgets and checks

- First translation after opening the panel: under 1.5 s. Later sentences: under 300 ms on a
  mid-range phone.
- Memory: one loaded model, under 150 MB extra.
- APK size unchanged; models only in packs.
- The release permission gate must still show no INTERNET.
- Licence notices for the engine and every model go into `THIRD_PARTY_NOTICES.md` and
  `assets/notices/`.

## Open questions

- The engine choice depends on T1's licence and size report.
- Who signs model packs, and with which key (shared with voice packs)?
