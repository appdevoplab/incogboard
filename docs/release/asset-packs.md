# Play on-demand asset packs (play flavour)

Owner: Wave 5-C. Status: code and build scripts written; **not yet compiled into the app** (the play flavour
does not exist on this branch yet). Facts below were checked on 2026-11-23.

## What is delivered this way

Large packs go through Google Play as on-demand asset packs. Each carries one signed `.koshapack` file, which
the app installs through the same verification path as an imported file (`DeliveredPacks.install`). The
keyboard never downloads anything. Play does the download, and the app only asks Play and reports the state.

| Pack id | Asset pack | `.koshapack` size (bytes) | Engine |
|---|---|---|---|
| `dict-zh-rime-ice` | `pack_dict_zh` | 38,052,531 (38 MB) | Chinese dictionary (rime-ice, GPL-3.0-or-later) |
| `dict-ja-mozc` | `pack_dict_ja` | 20,267,768 (20 MB) | Japanese dictionary (Mozc, BSD-3-Clause) |
| `voice-whisper-base` | `pack_voice_base` | 161,253,965 (161 MB) | sherpa-onnx Whisper base (MIT) |
| `translate-en-es` | `pack_translate_en_es` | 115,635,262 (116 MB) | OPUS-MT (Apache-2.0) |

Total: 335,209,526 bytes (about 320 MiB) of `.koshapack` files. Play compresses the bundle, so the download
size differs. Measure it with `bundletool get-size total` after the first bundle build.

The four ids and asset pack names are in `StoreCatalog` (`packs/PackSource.kt`). The Gradle modules are in
`android/asset_packs/<name>/`, and `tool/packs/copy_asset_packs.ps1` copies the signed packs into each module's
`src/main/assets/`. Those copies are gitignored.

## Play Asset Delivery library

| Item | Finding |
|---|---|
| Artifacts | `com.google.android.play:asset-delivery:2.3.0`, `com.google.android.play:asset-delivery-ktx:2.3.0` |
| Repository | Google Maven (`maven.google.com`) |
| Licence | Play Core Software Development Kit Terms of Service (POM `<license>`, https://developer.android.com/guide/playcore/license). This is **not** an open-source licence. Using it means accepting those terms. Google may change the terms with notice; changes are not retroactive. |
| Network | The library talks to the Play Store app over IPC. It adds no `INTERNET` or `ACCESS_NETWORK_STATE`. Checked in the AAR's binary `AndroidManifest.xml` (no hits for either, in either string encoding) and in `classes.jar` (no HTTP or socket classes). |
| Components it declares | `AssetPackExtractionService`, `ExtractionForegroundService`, `SessionStateBroadcastReceiver`, provider `com.google.android.play.assetdelivery` |
| Permissions it adds | `android.permission.INSTALL_PACKAGES`, `android.permission.FOREGROUND_SERVICE`, `android.permission.FOREGROUND_SERVICE_DATA_SYNC` |

**Effect on the merged manifest.** These three permissions would reach the `play` build, which breaks the rule
"no new permissions". `INSTALL_PACKAGES` is a signature/privileged permission, so a normal app cannot be
granted it. Removing it is the right default. Patch for Agent B's `android/app/src/play/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INSTALL_PACKAGES" tools:node="remove" />
```

Foreground-service permissions: the extraction service runs as a foreground service while Play copies a pack.
If the emulator test shows extraction still works without them, remove them too. Otherwise keep them, list them
in the Data safety and permissions notes, and ask the user to decide. The orchestrator checks the merged
`play` manifest with `tool/check_release_permissions.sh` after the patch.

## Size limits (quoted 2026-11-23)

From the Google Play size limits page (https://support.google.com/googleplay/android-developer/answer/9859372),
which measures compressed download size:

- Individual asset pack: **1.5 GB**.
- Cumulative total of install-time asset packs and modules: 4 GB.
- Cumulative total of on-demand and fast-follow asset packs: **30 GB**.
- Overall maximum app download size: 34 GB.
- Mobile data: an app above **200 MB** shows a non-blocking dialog on mobile data. The 150 MB figure in the
  Wave 5 brief is out of date. Re-check the page before release.

The "2 GB" figure that appears in older OBB and Play Games pages is not a per-pack limit, and it is not used here.

## Build

`tool/packs/build_bundle.ps1` does the whole flow:

1. copies the signed packs into the modules (`copy_asset_packs.ps1`; `-PubKey` verifies each pack first);
2. `flutter build appbundle --flavor play --release`;
3. downloads bundletool 1.18.3 to `%USERPROFILE%\.kosha\tools\` (Apache-2.0, the licence of the bundletool
   repository) and prints its SHA-256 (record it here on first run);
4. `bundletool validate`, `build-apks --mode=universal` (`universal.apks`), and
   `build-apks --local-testing` (`local-testing.apks`).

Outputs go to `build/packs/bundle/`, which is not committed.

## Emulator test of on-demand delivery (orchestrator)

Real Play delivery needs a Play account and an uploaded release, so testing uses bundletool's local testing:

```
bundletool install-apks --apks=build/packs/bundle/local-testing.apks
```

Then, in the app: Model packs, the "Get" buttons (play flavour) show the four packs. Tapping "Get" calls
`AssetPackManager.fetch`. With `--local-testing` the packs are installed locally, so the state goes to
`COMPLETED` at once. Check that `installDeliveredPack` verifies and installs each pack, that "Verify installed
packs" passes, and that deleting a pack works. Also check a damaged `.koshapack` inside the local set is
rejected and nothing is left behind.

The `local-testing` set is a development artefact. Do not upload it.

## Patches for Agent B's files (not applied by Wave 5-C)

`android/settings.gradle.kts`:

```kotlin
include(":pack_dict_zh", ":pack_dict_ja", ":pack_voice_base", ":pack_translate_en_es")
project(":pack_dict_zh").projectDir = file("asset_packs/pack_dict_zh")
project(":pack_dict_ja").projectDir = file("asset_packs/pack_dict_ja")
project(":pack_voice_base").projectDir = file("asset_packs/pack_voice_base")
project(":pack_translate_en_es").projectDir = file("asset_packs/pack_translate_en_es")
```

`android/app/build.gradle.kts` (check the property type for the AGP version in use; `+=` assumes a mutable collection):

```kotlin
android {
    assetPacks += listOf(":pack_dict_zh", ":pack_dict_ja", ":pack_voice_base", ":pack_translate_en_es")
}

dependencies {
    "playImplementation"("com.google.android.play:asset-delivery:2.3.0")
    "playImplementation"("com.google.android.play:asset-delivery-ktx:2.3.0")
}
```

`android/app/src/play/AndroidManifest.xml`: the `INSTALL_PACKAGES` removal above.

Kotlin, in the play flavour:

1. move `android/asset_packs/PlayAssetPackSource.kt.txt` to
   `android/app/src/play/kotlin/app/incogboard/keyboard/packs/PlayAssetPackSource.kt`;
2. in `packs/PackSource.kt`, change `PackSources.forBuild` to `return PlayAssetPackSource(context)` (this is the
   only change in main code; the foss build keeps `FilePackSource`).

The `play` source set is the only place that uses the library, so the foss build never contains it.

## Known gaps

- The Play source (`PlayAssetPackSource`) is written against the library's documented API but has not been
  compiled, because the play flavour does not exist yet. Check the class names (`AssetPackState`,
  `AssetPackStatus`, `AssetPackLocation.assetsPath`) against the 2.3.0 classes when moving the file.
- The Dart bridge calls for store delivery are not in Pigeon yet (see `docs/packs/README.md`, "Bridge additions").
- The asset-pack names must stay in step with `StoreCatalog`, the Gradle module names and
  `tool/packs/copy_asset_packs.ps1`. A unit test checks the catalogue; nothing checks the Gradle files.

## Decisions for the user

1. Remove `INSTALL_PACKAGES` (recommended) and, if the emulator test allows, the two foreground-service
   permissions.
2. Ship the voice and translation packs through Play, or keep them import-only in every build?
3. Upload to a Play internal test track before the first public release, to test real delivery (needs the
   Play Console account and the release key).
