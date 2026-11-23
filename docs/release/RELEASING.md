# Releasing Kosha

This is the procedure for building, signing, checking and publishing Kosha. Nothing in the repository
publishes by itself. The steps that need a person (accounts, keys, store consoles) are listed in
`checklist.md`.

## Distributions

| Flavour | Who gets it | What it contains |
|---|---|---|
| `foss` | GitHub releases, F-Droid, the developer's own F-Droid repository | The full build: every dictionary and voice/translation runtime, signed-pack import from Model packs. No Google libraries. |
| `play` | Google Play | The same code. Large data (Chinese and Japanese dictionaries, voice and extra data) is delivered by Play on-demand asset packs (Wave 5-C). Until those modules land, `play` behaves exactly like `foss`. |

Both flavours share one distribution dimension (`distribution`) and one manifest. The only differences are
in Gradle (`android/app/build.gradle.kts`) and resources (`android/app/src/foss/`, `android/app/src/play/`).
Neither flavour requests `INTERNET`, and `play` must never add it. The permission gate runs on both.

The Dart code cannot see the flavour yet. Showing "Built for Google Play" in the About screen needs a Pigeon
method (for example `getDistribution()`) that returns the `kosha_distribution` resource. That change is not
made in Wave 5.

Commands:

```
flutter build apk --release --flavor foss --split-per-abi
flutter build apk --release --flavor play --split-per-abi
flutter run --flavor foss          # flutter run needs a flavour; foss is the default for development
```

APK names follow Flutter: `app-<abi>-<flavour>-release.apk` (for example `app-arm64-v8a-foss-release.apk`).

## applicationId and namespace

The applicationId is a placeholder: `app.kosha.keyboard`. It becomes `io.github.<username>.kosha` before the
first store release, once the username is known. The change is made in one command:

```
powershell -ExecutionPolicy Bypass -File tool\release\set_application_id.ps1 io.github.<username>.kosha -DryRun
powershell -ExecutionPolicy Bypass -File tool\release\set_application_id.ps1 io.github.<username>.kosha
```

The places that name the applicationId:

- `android/app/build.gradle.kts`: the constant `koshaApplicationId`. This is the only value the build reads.
- `tool/adb_ime.ps1`: `$script:Pkg`. The IME component (`<id>/.ime.KoshaImeService`) is derived from it.
- `tool/bench/device_bench.ps1`: the `-Package` default.
- `metadata/app.kosha.keyboard.yml`: the F-Droid recipe. The file is renamed to match the id.
- Release documents under `docs/release/`: every mention of the id, except lines that talk about the namespace.
- Not changed: the About source link (`KOSHA_SOURCE_URL`, a build define), which the user sets when the repository URL is final.

The namespace and Kotlin package stay `app.kosha.keyboard`. Android allows the applicationId and the namespace
to differ: the namespace is only the Kotlin package and the generated `R` class, and it does not appear on
the device. Changing it would mean renaming every Kotlin file and the JNI names, so it is deliberately kept.

After the change, the new id is a new app to Android. An install of the placeholder id cannot be upgraded to
the store id. Nothing has been installed to users yet, so this costs nothing before the first release.

## Versions

`pubspec.yaml` holds the version (`version: <name>+<build>`). It feeds `versionName` and `versionCode` in
`build.gradle.kts`. Flutter adds an ABI offset to the versionCode of split APKs (arm64 build 1 is `2001`
in `foss`); F-Droid and Play handle the offsets.

```
powershell -ExecutionPolicy Bypass -File tool\release\bump_version.ps1 -Name 1.0.0 -Build 1 -DryRun
```

The build number must go up on every published release. The script refuses a lower or equal number.
Each release also needs a changelog in `fastlane/metadata/android/<locale>/changelogs/<build>.txt`.

## Signing

Release signing reads, in this order:

1. `android/key.properties` (git-ignored): `storeFile`, `storePassword`, `keyAlias`, `keyPassword`. The
   `storeFile` must be an absolute path with forward slashes, outside the repository.
2. Environment variables: `KOSHA_KEYSTORE_PATH`, `KOSHA_KEYSTORE_PASSWORD`, `KOSHA_KEY_ALIAS`, `KOSHA_KEY_PASSWORD`.

With neither, `assembleRelease` falls back to the debug key and prints a warning. Such an APK is not for
publication. `build_release.ps1` labels the report "DEBUG KEY", and `release.yml` refuses to publish any APK
signed with the Android debug certificate.

### Making the keys (once, on the release machine)

```
powershell -ExecutionPolicy Bypass -File tool\release\make_release_keys.ps1
```

It creates these files in `%USERPROFILE%\.kosha\release` (outside the repository):

- `kosha-release.p12`: the upload and release keystore, RSA 4096, PKCS#12, valid 30 years.
- `release-keystore.password`: a random 256-bit password, readable only by the user. The store and key
  password are the same, because PKCS#12 keystores have one password.
- `key.properties`: ready to copy to `android\key.properties`.
- `pack-release.pem`: the ECDSA P-256 private key that signs model packs.
- `pack-release.pub.b64`: its public key, base64 SubjectPublicKeyInfo DER, in the format `PackStore.kt` embeds.

The script refuses to overwrite files and refuses a folder inside the repository. It prints SHA-256
fingerprints, never a password or a key. The POSIX twin is `tool/release/make_release_keys.sh`.

The pack private key is stored unencrypted, because `tool/make_pack.dart` calls `openssl dgst -sign` without a
passphrase. Its protection is the folder's ACL plus the offline backups. See the decisions in `checklist.md`.

Back up the folder to two offline places. Losing the keystore means existing installs can never be updated.

### Secrets for GitHub (`release.yml`)

Configure these in the repository's `release` environment. Values are never written to a file in the repo.

| Name | Kind | Value |
|---|---|---|
| `KOSHA_KEYSTORE_BASE64` | secret | base64 of `kosha-release.p12` |
| `KOSHA_KEYSTORE_PASSWORD` | secret | the password in `release-keystore.password` |
| `KOSHA_KEY_PASSWORD` | secret | the same password |
| `KOSHA_KEY_ALIAS` | secret | `kosha-release` |
| `KOSHA_SOURCE_URL` | variable | the public repository URL (About link) |
| `KOSHA_RELEASE_CERT_SHA256` | variable | the release certificate SHA-256 (checked after signing) |

Encode the keystore on the release machine, for example with `certutil -encode` or
`[Convert]::ToBase64String([IO.File]::ReadAllBytes(...))`, and paste it into the secret. Do not paste it into
chat, a commit or a log.

### Google Play App Signing

Enrol in Play App Signing. Play holds the app-signing key; `kosha-release.p12` is the **upload key**. Google Play
requires an AAB, not an APK, for `play`. The AAB task is not part of this release tooling yet: it needs the
asset-pack modules from Wave 5-C, and the `bundle<Flavour>Release` task has not been run.

### F-Droid signing

F-Droid signs its own build unless the reproducible build matches the developer's APK, in which case the
developer's signature is kept. Only the reproducible result below makes that possible. See `fdroid.md`.

## Pack-signing key rotation

Model packs are signed with ECDSA P-256. `PackKeys.kt` (orchestrator-owned) lists the public keys the app
trusts. Today it holds only the development key.

The procedure, implemented by Wave 5-C:

1. `PackKeys.kt` trusts a list of public keys: the release key first. The development key stays in the list
   only for debug builds, so packs made with it cannot be imported in a release build.
2. Release packs are signed with `tool/make_pack.dart --key <path to pack-release.pem>`. The default `--key`
   is the development key under `%USERPROFILE%\.kosha\keys\pack-dev.pem`; a release must always pass the
   release key explicitly.
3. After rotation, every pack that a user already imported keeps working only if it was signed by a trusted
   key. Re-sign the packs with the release key and publish them again.
4. The release key must never appear in the repository. Only `pack-release.pub.b64` is copied into code.

## Gates

`tool/release/build_release.ps1` runs, in order: a clean-tree check, the pinned Flutter version
(`tool/release/flutter-version.txt`), dart format, analyze, `flutter test`, the JVM unit tests, the release
build of each flavour with all ABIs, the permission gate through Git Bash, and the SHA-256 sums and size report.
Output goes to `build\release-report\`. Pass `-SkipChecks` to build only, and `-AllowDirty` only for local tests.

`tool/check_release_permissions.sh` (not changed in Wave 5) fails if an APK requests `INTERNET`,
`ACCESS_NETWORK_STATE` or `ACCESS_WIFI_STATE`, or contains onnxruntime telemetry classes.

Permissions in both flavours today: `VIBRATE`, `RECORD_AUDIO`, `USE_BIOMETRIC`, `USE_FINGERPRINT` (from the
`local_auth` plugin) and the app-private `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`.

Vital lint is disabled for release builds (`lint { checkReleaseBuilds = false }`). The lint tool crashes with
AGP 9.3 and Kotlin 2.4 on a dependency's Java source (a JavaDoc parser mismatch). Lint should be run on the
debug build until the tool is fixed.

## Reproducible builds

`tool/release/verify_reproducible.ps1` builds one commit twice, from two fresh clones in two different
folders, and compares the APKs entry by entry. It ignores the zip container, the signing block and
`META-INF/` signing files.

Pinned: Flutter 3.50.0 (`tool/release/flutter-version.txt`), NDK 28.2.13676358, Gradle 9.5.0 (wrapper),
Java 17 without a build-time JDK download (`org.gradle.java.installations.auto-download=false`), Dart packages
from `pubspec.lock`. Android dependencies are pinned by version in `build.gradle.kts` (the onnxruntime pin is 1.28.0).
Gradle dependency locking is **not** enabled: a lockfile written with all Flutter target platforms breaks an
arm64-only clean build (the engine artifacts differ per ABI; the first verification attempt failed on this), and one
written per target platform does not fit the split build. Lock the Android graph with Gradle's dependency verification
instead, once the decision is made (checklist). Build settings: no obfuscation and no
`--split-debug-info` (the app holds no secrets, and split symbols would be one more artifact to keep); no
`--dart-define` except `KOSHA_SOURCE_URL`; VCS information not used (not available for APK builds).

## Verification results

Commit `1f846aa`, flavour `foss`, `android-arm64`, 23 November 2026. The run uses `tool/release/verify_reproducible.ps1`.

**Run 1, two builds at two different paths** (the brief's default): 460 entries identical; 2 entries differ, and both
differences come from the build location:

- `lib/arm64-v8a/libapp.so` (Dart AOT snapshot, 1,077,368 bytes differ). The snapshot contains the absolute location of
  the build's `.dart_tool` as a source URI (`e:///C:/Users/…/<clone folder>/.dart_tool/flutter_build/…`). Each clone
  folder name therefore changes the library.
- `lib/arm64-v8a/libdartjni.so` (20 bytes differ). Those 20 bytes are the GNU build-id, which is a hash of the file and
  changes with the debug strings that carry the clone path.

**Run 2, two fresh clones at the same path**, built one after the other: 462 entries identical, 0 different, same entry
order, same timestamps. The whole-file hash still differs, so the differences are outside the entries (the zip container
and the signing block). These were not analysed further, because the verification compares entries by design.

Conclusion: the foss arm64 build is deterministic for a fixed commit and a fixed build path. It is **not** path
independent. F-Droid builds at one fixed path, which is the case that matters for its verification. Removing the
path from `libapp.so` was not tested; `--split-debug-info`, `--obfuscate` and a fixed build directory are the options to
try (not done). The `play` flavour has not been checked.

## Rebuild for F-Droid

`fdroid.md` describes the recipe. The build command is the same as the one above, so an F-Droid build and a
local build share the same inputs.

## Release steps (summary)

1. Merge the release work to `main`. Confirm CI is green.
2. `bump_version.ps1`, changelogs for every locale, commit.
3. `set_application_id.ps1` if the id is still the placeholder (once the username is known).
4. Run `build_release.ps1` locally with the release keys and read the report. Device checks (performance budgets,
   TalkBack, the emulator smoke test) are done by the orchestrator before anything is published.
5. Tag `v<name>` and push the tag. `release.yml` builds both flavours and creates a draft release.
6. Review the draft, attach nothing else, publish it yourself.
7. Upload the `play` AAB to Play Console, and submit the F-Droid merge request with the recipe.
8. Keep the tag, the commit hash and the SHA-256 sums with the backups.

`checklist.md` lists every step that needs an account or a decision.
