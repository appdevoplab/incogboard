# Wave 5-B: flavours, signing, reproducible builds, store and F-Droid material

Read `docs/waves/wave5/COMMON.md` first. Plan sections: "Distribution", "Verification".

## Ownership

**You own:**
- `android/app/build.gradle.kts` (flavours, signing configs, release build settings, `versionName`/`versionCode` wiring, the applicationId constant, reproducibility flags), `android/gradle.properties` additions, and `android/settings.gradle.kts` **only** for repository and version-catalog lines (Agent C owns the asset-pack `include` lines: leave a marked comment where they go).
- Flavour source sets: `android/app/src/play/**`, `android/app/src/foss/**` (resources, a flavour manifest if needed, flavour-only Kotlin).
- `.github/workflows/release.yml` (new; Agent A owns `ci.yml` and every other workflow).
- `tool/release/**` (new): `make_release_keys.ps1` (and a `.sh` twin), `build_release.ps1`, `verify_reproducible.ps1`, `bump_version.ps1`.
- `fastlane/metadata/android/**` (new): the F-Droid / Triple-T layout, en-US first.
- `metadata/app.kosha.keyboard.yml` (new): the F-Droid fdroiddata build recipe (named after the applicationId placeholder; the file is renamed when the id changes).
- `docs/release/**` (new): `RELEASING.md`, `privacy-policy.md`, `data-safety.md`, `fdroid.md`, `developer-verification.md`, `store-listing.md`, `checklist.md`.
- `docs/brand/**` additions only for the store listing texts (Agent E's brand files exist; do not change them).
- `.gitignore` entries for keystores and signing properties.
- Tests: `test/release/**` (new names only) and Gradle/JVM tests you add under `android/app/src/test/**/release/`.

## Part 1: flavours

- Two product flavours on one dimension `distribution`: **`foss`** (GitHub and F-Droid: the full build, signed-pack import from Model packs, no Google libraries, no Play-specific code) and **`play`** (Google Play: same code, but the large data is delivered by Play on-demand asset packs, which Agent C builds; until C is merged the `play` flavour behaves like `foss` and the asset-pack hooks are no-ops).
- The flavour must be visible to Dart through one `--dart-define` or a `BuildConfig` flag passed over the existing contract only if it needs no Pigeon change; otherwise describe the Pigeon change you would need and make the flavour affect only Gradle and resources. Do not add Google Play libraries to `foss`. **`play` must not add INTERNET either**: asset pack delivery works through the Play Store app, not the keyboard. Verify with the release gate on both flavours.
- `applicationId` stays `app.kosha.keyboard` (placeholder, decided). Put it and the namespace in one clearly marked place, and write `tool/release/set_application_id.ps1 <new id>` that changes every place (Gradle, manifest `tools:replace` if any, Kotlin package-qualified strings the build refers to, the IME service component in `tool/adb_ime.ps1`, the F-Droid recipe file name and contents, fastlane docs, the About source link define). The Kotlin source package stays `app.kosha.keyboard` (applicationId and namespace may differ in Android; say so in `RELEASING.md`).
- Flavour-specific labels are not needed. Debug builds get the suffix `.debug`? **No**: the adb scripts and the emulator keyboard id depend on the id; keep debug unsuffixed.
- Update `tool/check_release_permissions.sh` calls in your docs and workflow for per-flavour APK names (do not edit that script; Agent A may).

## Part 2: signing

- Release signing config reads from `android/key.properties` (git-ignored) **or** environment variables (`KOSHA_KEYSTORE_PATH`, `KOSHA_KEYSTORE_PASSWORD`, `KOSHA_KEY_ALIAS`, `KOSHA_KEY_PASSWORD`). With neither present, `assembleRelease` falls back to the debug key and prints a loud warning (so CI and contributors can build), and `release.yml` refuses to publish an artifact signed with the debug key.
- `tool/release/make_release_keys.ps1`: the orchestrator runs it on this PC after the merge. It generates, **outside the repo** (default `%USERPROFILE%\.kosha\release\`): an upload/release keystore (RSA 4096 or EC P-256, validity 30 years, `keytool`), a random password stored in a file readable only by the user, and a new ECDSA P-256 **pack-signing key** with its public key in the format `PackStore.kt` embeds. It prints the SHA-256 fingerprints, never the passwords, and tells the user to back up the folder (two copies, offline). It refuses to overwrite an existing key. A throwaway-folder test (`-OutDir`) proves it works; never run it against the real folder yourself.
- **Pack key rotation:** `PackStore.kt` embeds the dev public key. Do not edit it (Agent C owns pack code). Describe in `docs/release/RELEASING.md` the exact procedure Agent C implements (a list of trusted public keys: release first, dev key only in debug) and where `tool/make_pack.dart --key` is used. Coordinate through the report, not by editing C's files.
- Google Play App Signing: document "enrol, use the upload key", and that F-Droid signs its own build unless reproducible builds let the developer's signature be used (see below).

## Part 3: reproducible builds

F-Droid and verifiers must be able to rebuild the `foss` APK byte-for-byte (or close enough for their verification).
- Fix what makes builds differ: timestamps in the APK (`-Pandroid.…` and the zip entry times), the R8 mapping, build paths in native libraries and Dart snapshots, `--obfuscate`/`--split-debug-info` choices (decide; document), `--dart-define` values, sorted resource and asset order, the Flutter version pinned in a file (`.fvmrc` or `tool/release/flutter-version.txt`), the NDK version and Gradle wrapper pinned, no `+dev` Git describe in the version, dependency locking (`gradle.lockfile` via `dependencyLocking`, `pubspec.lock` committed).
- `tool/release/verify_reproducible.ps1`: builds the `foss` arm64 release twice from clean clones in different directories and compares the APKs with a normalising diff (`apkdiff`-style: unzip, compare entry hashes, ignore only the signature block). Run it once and put the result, with the list of remaining differences and why, in `docs/release/RELEASING.md`. Be honest if a native binary blocks it (the patched sherpa `.so` files are committed binaries: F-Droid needs their provenance; see Part 5).
- The permission gate and a size report run in `build_release.ps1`.

## Part 4: privacy policy, store listing and Data safety

- `docs/release/privacy-policy.md`: plain language, accurate to the code: no network permission and no data leaves the device; what is stored on the device (learned words, clipboard history if enabled, themes, seen-apps list for incognito, packs) and that all of it is encrypted with a Keystore key where applicable and in the app's private storage; the microphone is used only while the voice panel is open and audio is never saved or sent; backups are user-initiated, encrypted with the user's passphrase and saved where the user chooses; no analytics, ads or crash reporting; no accounts; how to delete everything (privacy center, uninstall); children; the licence; the contact (a placeholder `<contact email>` the user fills in). Check every claim against the code (read it) and list in `docs/release/checklist.md` any claim you could not verify.
- `docs/release/data-safety.md`: the answers for Google Play's Data safety form, question by question (data collected: none; shared: none; encryption in transit: not applicable because no transmission; deletion: yes), plus the answers for the permissions declaration (RECORD_AUDIO foreground use, USE_BIOMETRIC), the **IME/keyboard policy** requirements (a keyboard may not collect or transmit typed text; a prominent in-app disclosure that a keyboard "can collect all the text you type" before enabling, which onboarding already shows: confirm it matches the policy wording), and the content rating questionnaire answers.
- `fastlane/metadata/android/en-US/`: `title.txt` (30 chars max), `short_description.txt` (80), `full_description.txt` (4000), `changelogs/<versionCode>.txt` (500), and image placeholders pointing at `assets/brand/` (the icon 512 and feature graphic exist from Wave 4 agent E: check `docs/brand/` and `assets/brand/` and reference them, do not redraw). Add the same for `es-ES`, `fr-FR`, `de-DE`, `pt-BR`, `id`, `hi-IN` using short, simple, accurate translations of the title and short description only (mark them machine-made in `docs/release/checklist.md` for a native review). Descriptions must not overclaim (say what is tested; say Chinese and Japanese need the dictionary pack download from the user's own files in the `foss` build and arrive through Play in the `play` build once Agent C lands).
- `docs/release/store-listing.md`: categories, tags, content rating, the screenshot plan (which screens, languages, themes), and the keyboard-specific Play review notes (how the reviewer enables the keyboard).

## Part 5: F-Droid and developer verification

- `docs/release/fdroid.md` and `metadata/app.kosha.keyboard.yml`: the recipe (Flutter build with the pinned version via `srclibs`/`sudo`/`prebuild` as F-Droid expects, `rm` of anything non-free, `AntiFeatures` if any: the bundled data files and models are free licences; check the Mozc/IPAdic and any non-FOSS item from Agent A's audit before declaring none), the `Binaries` and `UpdateCheckMode`, and what F-Droid will object to: the **committed prebuilt binaries** (`libsherpa-onnx-jni.so` patched, `libonnxruntime.so` from the Maven AAR). Document how to rebuild each from source (`docs/notices/voice.md` has the sherpa build notes; the onnxruntime build is blocked from this PC) and say clearly that this may delay F-Droid inclusion; propose the fallback (a GitHub release APK signed by the developer, with the published fingerprint, and an own F-Droid repo via `fdroidserver`, with the exact commands).
- `docs/release/developer-verification.md`: Android's developer verification requirements for sideloaded and F-Droid apps (research the current rules on the web: dates, what must be registered, the free tier for hobbyists, what it means for an app distributed outside Play) and the steps the user must take. State the date you checked and link the sources; mark anything you could not confirm.
- `.github/workflows/release.yml`: triggered by a version tag, builds both flavours, runs the gates, attaches APKs, SHA-256 sums and the permission report to a **draft** release. Signing comes from encrypted repository secrets (named in `RELEASING.md`; never in the file). Pin actions by SHA like Agent A does (copy the SHAs from the current `ci.yml` only after A's version lands; if it has not landed, pin with the same method yourself). Nothing publishes by itself.

## Done

- `./gradlew assembleFossRelease assemblePlayRelease` (via `flutter build apk --release --flavor foss|play --split-per-abi`) builds, both pass the permission gate, and sizes are in the report.
- Debug flows still work: `flutter build apk --debug` (with or without a flavour; `flutter run` needs a default flavour: choose `foss` and say so).
- JVM tests 105 (5 skipped) and `flutter test` still pass; your new tests pass.
- `docs/release/checklist.md`: a numbered, ordered checklist for the user (accounts to create, the key generation step, where to back up keys, the Play Console steps, the F-Droid MR, the tag and release, what to put in `<contact email>`, the applicationId swap), each marked "user" or "orchestrator".
- Report: build times, APK sizes per flavour and ABI, what the reproducibility check showed, and the open decisions.
