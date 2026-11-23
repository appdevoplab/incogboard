# Wave 5-C: data packs for Play and for FOSS, pack key rotation

Read `docs/waves/wave5/COMMON.md` first. Plan sections: "Distribution", "Voice", "Translation", "Languages".

## Ownership

**You own:**
- `android/app/src/main/kotlin/app/kosha/keyboard/packs/**` (the pack store, signature verification, install and delete), and new files beside it for asset-pack delivery.
- New Gradle modules under `android/asset_packs/**` (one folder per Play asset pack, each with its own `build.gradle.kts`) and a documented `include` snippet for `android/settings.gradle.kts` (Agent B owns that file; give the exact lines in your report and in `docs/release/asset-packs.md`; do not edit it).
- `lib/src/packs/**` and `lib/src/app/packs/**` (Dart pack access and the Model packs screen), `tool/make_pack.dart`, `tool/packs/**`, `docs/packs/**` (new), `docs/release/asset-packs.md` (new).
- `lib/src/app/packs/**` strings go through the ARBs: you may add keys to `lib/l10n/app_*.arb` for your own screen only (new keys, marked `x-review` in the non-English files; run `flutter gen-l10n`; keep the generated files formatted).
- Tests: `test/packs/**`, `android/app/src/test/**/packs/**`.

**Not yours:** `build.gradle.kts` (Agent B: flavours, signing), `pigeons/` and `lib/src/bridge/` (orchestrator: if you need a new Pigeon call, write the exact addition in your report and implement everything else against the interface you propose, behind a Kotlin/Dart seam that compiles today).

## Part 1: pack signing key rotation (do this first)

Today `PackStore.kt` trusts one embedded dev public key; the matching private key sits in `%USERPROFILE%\.kosha\keys\pack-dev.pem`. Before release a new release key is generated (by the orchestrator, using Agent B's script).
- Make `PackStore` trust a **list** of public keys: the release key (placeholder constant file `ReleasePackKeys.kt` with a clearly marked "REPLACE WITH RELEASE KEY" and a test that fails the release build gate when the placeholder is still in a release variant... implement as a Gradle/JVM test the release gate can run), and the dev key **only in debug builds** (`BuildConfig.DEBUG`). Record the key id (the first 8 bytes of the SHA-256 of the public key) in the pack manifest signature block if the format has room; if it needs a format change, keep it backward compatible (old packs signed by the dev key still install in debug) and bump nothing the Dart side reads without a test.
- `tool/make_pack.dart`: `--key` already exists; add `--key-id` printing and a `--verify <pack>` command that checks a pack against a public key file. Keep the dev default only when no `--key` is given and the environment variable `KOSHA_ALLOW_DEV_KEY=1` is set; otherwise it refuses, so a release pack cannot be signed with the dev key by accident.
- Tests: valid pack under each key, a pack from an unknown key, a flipped bit in the manifest, a flipped bit in a file, a path-traversal file name, a duplicate name, a size field larger than the data, more than 64 files, a truncated pack. All must be rejected without leaving files behind (check the staging directory is cleaned up).

## Part 2: FOSS import experience

`foss` ships without the big data. The Model packs screen must make that smooth, with no network:
- Clear empty-state text for each language that needs a pack (Chinese, Japanese, voice, translation) and a plain explanation: "Packs are files you add yourself. Download them from the project's release page on another device, copy them to this phone, then import." (the URL placeholder lives in one constant; Agent B's docs fill it at the end). Remember: the app has no INTERNET permission, so it cannot open links itself; it may show the text and let the user copy it. A "Copy link" button using the clipboard is fine; an intent that opens a browser is also acceptable (`ACTION_VIEW` needs no permission) only if it is a clear, user-tapped action; decide and justify in the report.
- Import progress, a checksum summary of the pack (name, version, signer key id, size), a failure message that says what was wrong ("not signed by a trusted key", "damaged file", "too large") without paths, and removal. Multi-select import of several `.koshapack` files at once.
- A "Verify installed packs" action that re-checks every installed pack's files against its manifest hashes and reports damage (a pack folder can be corrupted by storage errors).
- Storage: show free space before a large import and refuse if there is not enough room for the pack plus a safety margin.
- Widget tests for each state. Every `MaterialApp` passes `localizationsDelegates: koshaLocalizationsDelegates`.

## Part 3: Play on-demand asset packs for the `play` flavour

Google Play delivers large data as asset packs. Plan: the same `.koshapack` content, delivered by the Play Store and then installed through the same verification path, so the trust model is identical.
- Which packs (sizes from `%USERPROFILE%\.kosha\packs\signed\` and `docs/perf/budgets.md`): `dict-zh-rime-ice` (38 MB), `dict-ja-mozc` (20 MB), `voice-whisper-base` (161 MB; a pack over 150 MB per asset pack is allowed in install-time or on-demand packs up to 1.5 GB total, check the current limits at developer.android.com and quote them), `translate-en-es` (116 MB) and the later translation pairs. On-demand delivery mode for all of them, one asset pack each, named `pack_dict_zh`, `pack_dict_ja`, `pack_voice_base`, `pack_translate_en_es`.
- The Play Asset Delivery library (`com.google.android.play:asset-delivery` and `asset-delivery-ktx`) is a Google-proprietary dependency. This is the one dependency this wave allows, **only in the `play` flavour** (`playImplementation`), with no change to the manifest permissions (verify: the merged `play` manifest must not gain INTERNET or ACCESS_NETWORK_STATE; if the library's manifest adds anything, report it with the exact `tools:node="remove"` patch). The `foss` flavour must not contain it. Research and write down: the library's licence, what it contacts (the Play Store app, not the keyboard), and whether the library itself needs a network permission: it must not.
- Code: a Kotlin `PackSource` seam in `packs/`: `FilePackSource` (SAF import, exists today) and `PlayAssetPackSource` (flavour source set `android/app/src/play/kotlin/...`, Agent B owns the flavour folders but you add files under `src/play/kotlin/app/kosha/keyboard/packs/` only; `src/foss/` gets a no-op `PlayAssetPackSource` stub so the main code compiles in both). The Play source requests a pack, reports progress and, when ready, **verifies and installs it through the same `PackStore` path** (never trust the Play copy without the signature check) and then asks Play to remove its copy if the API allows.
- UI: on `play` the Model packs screen shows "Get" buttons (download through Play) beside "Import a file". The screen asks the source for its capabilities, so the Dart side stays flavour-agnostic. Progress and "needs Wi-Fi/mobile data" states come from Play's status; show them as text. Because the keyboard itself has no network, the download is done by Play: say so in the UI text.
- The asset pack modules: a Gradle module per pack with the `com.android.asset-pack` plugin and `assetPack { packName; dynamicDelivery { deliveryType = "on-demand" } }`, and a build step that copies the signed `.koshapack` into the module's `src/main/assets/` from `%USERPROFILE%\.kosha\packs\signed\` (or a path given by `-PkoshaPacksDir`) without ever committing them (add to `.gitignore`). Provide `tool/packs/build_bundle.ps1` that builds an `.aab` for `play` with the asset packs and runs `bundletool` (download the jar on the dev machine, check its licence, Apache-2.0) to produce and validate universal and device-specific APK sets, and `bundletool build-apks --local-testing` for the orchestrator's emulator test of on-demand delivery through a local test server (document how: `bundletool install-apks`, and that the Play fake delivery needs `--local-testing`).
- Do not edit `build.gradle.kts` or `settings.gradle.kts`: give exact patches (`playImplementation(...)`, `assetPacks = [":pack_dict_zh", ...]`, the `include` lines) in your report and in `docs/release/asset-packs.md`. Make your Kotlin compile without them (the seam is behind an interface; the `play` source set file uses the library, so keep it outside the default source sets until B's flavours land: put it at `android/asset_packs/PlayAssetPackSource.kt.txt` with a one-line instruction to move it, and unit-test the seam with a fake).

## Part 4: extra data packs (only after Parts 1-3 are green)

- **Indic data** (gu, kn, ml, pa, or) pack template: the Wave 3 registry has a pack template for these languages. Build the staging script `tool/packs/indic_extra/stage_*.ps1` for **one** language end to end if the data is available under a compatible licence (Aksharantar CC0/CC-BY has these languages; Wikipedia frequency lists CC BY-SA 4.0). Record sources in `docs/notices/` (new file `indic_extra.md`) and say honestly which languages you finished. If it would take more than the remaining effort, stop after documenting the plan; do not ship half-checked data.
- **More translation pairs** (en-fr, en-de, en-pt, en-hi, en-ru) are staging scripts only (`tool/packs/translate/` exists): confirm each Opus-MT model's licence (CC-BY-4.0 / Apache), and list the sizes. Do not build them unless the scripts already exist.

## Done

- `flutter test` (new pack tests included), JVM tests, `flutter build apk --debug`, the release build and permission gate for the default flavour as it exists when you branch.
- `docs/packs/README.md`: pack format reference (header, manifest, signature block, key ids), the trust model, how to build, sign and verify a pack, how to rotate keys.
- Report: the exact patches for B's files and the Pigeon additions, the Play library's licence and manifest effect, pack sizes and limits quoted from Google's documentation (with the date), what the orchestrator must test on the emulator (import, verify, delete, the Play local-testing flow), and decisions for the user.
