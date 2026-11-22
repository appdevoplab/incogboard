# Wave 3-D: offline voice typing

Read `docs/waves/wave3/COMMON.md` first. Plan sections: "Offline voice typing", "Privacy and security".

**User decisions (2026-11-21):**
- Engine: **sherpa-onnx** (Apache-2.0) running **Whisper** (MIT) multilingual models, because it can later run better models (Dolphin, Moonshine, Parakeet) as packs.
- **No bundled model.** Models ship only as signed model packs (`.mynapack`). The APK stays small.
- The one native inference runtime is `onnxruntime-android` 1.31.1 from Maven (already a dependency). **Never ship a second `libonnxruntime.so`.**

## Ownership

**You own:**
- Kotlin: `android/app/src/main/kotlin/app/myna/keyboard/voice/**`. Replace the stub body of `createVoiceService` and implement `MicPermission` and `MicPermissionActivity` (already declared in the manifest: transparent, not exported). Keep the `VoiceService` interface as is.
- `android/app/src/main/jniLibs/**` (the sherpa-onnx JNI library only).
- `android/app/build.gradle.kts`: only a `packaging { jniLibs { ... } }` block inside `android { }`, if you need one.
- Dart: `lib/src/features/voice/**` (keep `createVoiceFeature()`), `lib/src/app/screens/voice_screen.dart`, and `lib/src/settings/sections/voice_settings.dart` (optional fields only).
- `tool/packs/voice/**` (staging scripts) and `docs/notices/voice.md`.
- Tests: `android/app/src/test/kotlin/app/myna/keyboard/voice/**`, `test/features/voice/**`, `test/app/voice/**`.

## Build

### 1. Native library

- Use an **official sherpa-onnx release** (`https://github.com/k2-fsa/sherpa-onnx/releases`). Pick the newest release that is at least 2 weeks old and built against onnxruntime **1.31.1 or older** (the C API is backward compatible, so a newer runtime serves an older sherpa build). Put **only** `libsherpa-onnx-jni.so` for `arm64-v8a`, `armeabi-v7a` and `x86_64` (the emulator) into `jniLibs/<abi>/`. Do not copy its `libonnxruntime.so`: the Maven AAR provides it. If the JNI library cannot load against the AAR's runtime, explain why in your report and propose the smallest fix.
- Copy sherpa-onnx's Kotlin API sources that you need (the offline recognizer and VAD classes, Apache-2.0) into `voice/sherpa/`, with their licence header and the exact release tag.
- Record the release, file names and SHA-256 of every binary in `docs/notices/voice.md`. Add a short "build from source" recipe there (NDK + CMake against the AAR's headers), for Wave 5's reproducible builds.
- Check the size each ABI adds to the APK and report it.

### 2. Voice packs (staging script, run at dev time)

- `tool/packs/voice/stage_whisper.ps1` (or `.dart`): downloads sherpa-onnx's exported **Whisper base** and **Whisper small** multilingual int8 models and the **Silero VAD** model (MIT) from the sherpa-onnx releases, checks their SHA-256, and lays them out in `build/packs/staging/voice-whisper-base/` and `voice-whisper-small/`: `encoder.int8.onnx`, `decoder.int8.onnx`, `tokens.txt`, `silero_vad.onnx`. It then prints the exact `dart run tool/make_pack.dart ...` command for the orchestrator. Manifest: `kind: voice`, `engine: sherpa-onnx-whisper`, `license: MIT`, and `languages` = every Myna language Whisper supports (en, es, fr, de, pt-BR, pt-PT, id, ru, uk, hi, mr, bn, ta, te, ar, ur).
- Look at **Dolphin** (Apache-2.0; check Hindi/Urdu/Arabic support) and **Moonshine** (English) as later packs: a paragraph each in the report (licence, size, quality claim, sherpa-onnx support). Don't build them.

### 3. Kotlin voice service

- `start(request, events)`: find the pack (`request.packId`, or the first voice pack covering the language via `PackStore.find("voice", listOf(lang))`), else return `NO_MODEL`. Load the recognizer once and keep it warm (release after 60 s unused or on `release()`).
- Audio: `AudioRecord`, `MediaRecorder.AudioSource.VOICE_RECOGNITION`, 16 kHz mono PCM16, 100 ms reads, on a dedicated thread. If the mic is busy, emit `error` (`audio_busy`) then `stopped`.
- **VAD chunking:** Silero VAD splits speech. While speaking, re-decode the growing current segment about every 700 ms for a `partial` event (skip partials if one decode takes longer than that). When a segment ends, decode it and emit `finalText`. Silence for 5 s, or 60 s in total, stops the session.
- `level` events about 20 per second (RMS mapped to 0..1, smoothed).
- Language: map Myna ids to Whisper codes (pt-BR → pt, ...); `autoDetect` lets Whisper detect it.
- `stop()` finishes the current segment; `cancel()` drops it. Exactly one `stopped` event ends each session. All events on the main thread.
- **Privacy:** audio only in memory; zero every buffer after use; never log text; release the mic immediately on stop.

### 4. Mic panel (Dart)

- `createVoiceFeature().attach` returns `KeyboardHooks(onVoice:)`, so the toolbar's mic button (and a `KeyType.voice` key, if a layout has one) open the panel. Never open it in password fields or while incognito (show nothing; the toolbar button stays as it is).
- Flow: `host.hasMicPermission()` → if false, `host.requestMicPermission()` → `host.startVoice(VoiceRequestMessage(...))`. On `noModel`, the panel says "Voice needs a voice pack" with a button that opens the settings route `packs` (`host.openSettings(MynaRoutes.packs)`).
- Panel (`PanelPlacement.keys`, the strip stays): an M3 Expressive animated shape (morphing blob or rounded star) that grows with the `level` events, an "On-device" badge, the language chip (the active language; tap to cycle enabled languages or Auto), and **Stop** and **Cancel** buttons (48 dp). Respect `theme.motion.enabled` (no animation when motion is off).
- Text: call `input.finishComposing()` first. Show each `partial` as composing text through `input.editor` (`setComposingText`), commit `finalText` with a space between utterances (auto-capitalise the first letter when the cursor is at a sentence start), then `input.resyncAfterExternalEdit()`. Voice text is never learned.
- Listen to `session.services.events.voice`. Close the panel and cancel voice when the panel closes, the field changes or the keyboard hides.

### 5. Voice settings screen

- `voice_screen.dart`: on/off, the voice pack to use (from `platform.listPacks()`, kind voice, with sizes; "Automatic" = first matching), auto-detect language, a link to "Model packs" (route `packs`, built by Agent T), and a one-line privacy note ("Audio stays on this phone and is never saved").

## Tests

- JVM: the event sequencing (fake recognizer and fake audio source behind small interfaces), the language mapping, pack lookup, the buffer zeroing.
- Dart: the mic panel flow with a mocked `ImeHostApi` (permission denied, no model, partial → final, cancel), no voice in password fields or incognito, the settings screen.

## Report extras

- APK size added per ABI; model load time and decode speed on the dev machine if you can measure them (JVM tests can't load the Android `.so`: say how you measured).
- What the orchestrator should check on the emulator: the permission prompt, "noModel" with no packs, then with the base pack: speaking (the emulator mic can use the host mic), partials, Stop, Cancel, a password field.
