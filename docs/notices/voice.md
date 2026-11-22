# Voice typing: third-party notices (Wave 3-D)

Everything below ships with the app or is staged for the orchestrator to sign as voice packs. Nothing here
is downloaded by the app; the staging script (`tool/packs/voice/stage_whisper.ps1`) runs on the dev machine only.

## 1. sherpa-onnx native library and Kotlin API

| Item | Value |
|---|---|
| Project | sherpa-onnx, https://github.com/k2-fsa/sherpa-onnx |
| Release | **v2.0.1** (published 2026-10-26), asset `sherpa-onnx-v2.0.1-android.tar.bz2` |
| Licence | Apache-2.0 (`LICENSE` in the release source, `sherpa-onnx-2.0.1/LICENSE`) |
| Copyright | Copyright (c) the sherpa-onnx authors, including Xiaomi Corporation (Kotlin API headers) |
| Built against | onnxruntime 1.28.2 (`libonnxruntime.so` inside that bundle, NOT shipped; see section 3) |
| SHA-256 of the bundle | `39003753ec293425ed56723ea9b972b98841a490af3311670c3060548d654330` |

Shipped native libraries (only `libsherpa-onnx-jni.so`; the `c-api`/`cxx-api` libraries and the bundled
`libonnxruntime.so` are not copied):

| ABI | File | Bytes | SHA-256 |
|---|---|---|---|
| arm64-v8a | `app/src/main/jniLibs/arm64-v8a/libsherpa-onnx-jni.so` | 4,609,320 | `5db8f89f12b2c900a98c9e01e00c475c59db35e9437a62e36e27839ec48b5575` |
| armeabi-v7a | `app/src/main/jniLibs/armeabi-v7a/libsherpa-onnx-jni.so` | 3,381,796 | `d45f377249d5c3191b91de6ba6edffcd83e4cf7e109bc523b212db341581c2a8` |
| x86_64 (emulator) | `app/src/main/jniLibs/x86_64/libsherpa-onnx-jni.so` | 5,053,592 | `878d61116f244131263eec24297ef05bf508d02bccdede2a4e3ad3202bbdaa48` |

`libsherpa-onnx-jni.so` has one dependency, `libonnxruntime.so`. It is provided by the Maven artifact
`com.microsoft.onnxruntime:onnxruntime-android:1.28.0` (MIT). The sherpa C API level is the same for all 1.28 releases, so the
1.28.2 build loads against 1.28.0 (1.29+ adds telemetry, so it is not used). The JNI library is not loaded on the JVM, so the load itself was not
exercised on this machine; the orchestrator checks it on the emulator (see the Wave 3-D report).

Kotlin API files copied unmodified (apart from a two-line provenance comment at the top) into
`app/src/main/kotlin/app/myna/keyboard/voice/sherpa/`, from `android/SherpaOnnxAar/sherpa_onnx/src/main/java/com/k2fsa/sherpa/onnx/`
of the same tag: `FeatureConfig.kt`, `HomophoneReplacerConfig.kt`, `QnnConfig.kt`, `OfflineRecognizer.kt`,
`OfflineStream.kt`, `Vad.kt`. Their package stays `com.k2fsa.sherpa.onnx` because the JNI symbols bind to it.

### Build from source (for Wave 5's reproducible builds; not yet run)

1. Get the sources of the same tag: `https://github.com/k2-fsa/sherpa-onnx/archive/refs/tags/v2.0.1.tar.gz`.
2. Get onnxruntime 1.28.0 for Android from Maven (`onnxruntime-android-1.28.0.aar`) and unzip it. Its `headers/`
   folder is the include dir, and `jni/<abi>/libonnxruntime.so` is the lib dir for each ABI.
3. Install the Android NDK matching `flutter.ndkVersion` and set `ANDROID_NDK`.
4. From the source root run, for each ABI, for example:
   `SHERPA_ONNXRUNTIME_LIB_DIR=<aar>/jni/arm64-v8a SHERPA_ONNXRUNTIME_INCLUDE_DIR=<aar>/headers ./build-android-arm64-v8a.sh`
   (`build-android-armv7-eabi.sh` and `build-android-x86-64.sh` for the others). The scripts use CMake and build
   the shared library, which links the AAR's `libonnxruntime.so`.
5. Take `libsherpa-onnx-jni.so` from the build output and compare its SHA-256 with the table above.

## 2. Whisper (speech recognition, multilingual, int8)

| Item | Value |
|---|---|
| Model | OpenAI Whisper, base and small, multilingual, exported for sherpa-onnx (int8 encoder and decoder) |
| Licence | MIT (Whisper weights and code, OpenAI) |
| Source | sherpa-onnx release `asr-models`: `sherpa-onnx-whisper-base.tar.bz2` and `sherpa-onnx-whisper-small.tar.bz2` |
| Archive SHA-256 | base `911b2083efd7c0dca2ac3b358b75222660dc09fb716d64fbfc417ba6c99ff3de` (207,557,382 bytes); small `486a46afbb7ba798507190ffe02fea2dd726049af212e774537efac6afb210a6` (639,387,718 bytes) |
| Files in a pack | `encoder.int8.onnx`, `decoder.int8.onnx`, `tokens.txt` (renamed from `base-*`/`small-*`) |
| Staged sizes | base: encoder 29,120,534; decoder 130,672,026; tokens 816,730 bytes. small: encoder 112,442,483; decoder 262,226,114; tokens 816,730 bytes |
| Languages | en, es, fr, de, pt-BR (pt), pt-PT (pt), id, ru, uk, hi, mr, bn, ta, te, ar, ur |

The brief's pinned hashes come from the first download. The Whisper archives have no digest in the GitHub
API, so re-pin only on purpose.

## 3. Silero VAD (voice activity detection)

| Item | Value |
|---|---|
| Model | Silero VAD (`silero_vad.onnx`, the sherpa-onnx release file of that name) |
| Licence | MIT (snakers4/silero-vad; confirm on the model card) |
| Source | sherpa-onnx release `asr-models`, `silero_vad.onnx` (2025-07-11) |
| SHA-256 | `9e2449e1087496d8d4caba907f23e0bd3f78d91fa552479bb9c23ac09cbb1fd6` (643,854 bytes; matches the API digest) |

## 4. Later packs (assessed, not built)

- **Dolphin** (Apache-2.0 per the brief; verify on the model card): sherpa-onnx has an offline Dolphin config (`OfflineDolphinModelConfig`). Hindi, Urdu and Arabic coverage to be checked
  on the model card before a pack is staged. Not built in Wave 3.
- **Moonshine** (licence to verify on the model card, believed MIT): English-only. sherpa-onnx has an offline Moonshine config (`OfflineMoonshineModelConfig`). Useful as a small English pack. Not built in Wave 3.
