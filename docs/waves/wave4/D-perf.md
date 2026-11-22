# Wave 4-D: performance and QA (and a smaller onnxruntime)

Read `docs/waves/wave4/COMMON.md` first. Plan sections: "Performance budgets", "Do more languages make it slow?", "Verification", "Risks and mitigations".

## Ownership

**You own:**
- In `android/app/build.gradle.kts`: only the onnxruntime dependency lines (`implementation(...)`, `testImplementation(...)`) and their comment.
- `android/app/libs/**` (new: the reduced onnxruntime AAR).
- `tool/onnxruntime/**`, `tool/bench/**`.
- `docs/perf/**`, `docs/notices/onnxruntime.md`.
- Tests: `test/perf/**`, `test/fuzz/**`.

Everything else is read-only for you. Report bugs you find in other code (with a failing test in `test/fuzz/` or `test/perf/` marked `skip:` and the reason) instead of fixing them.

## Part 1: a reduced onnxruntime (APK size)

The arm64 release APK is 79.0 MB, and `libonnxruntime.so` is 27.3 MB of it (the full operator set). Kosha runs only these models: Whisper base and small (int8 encoder and decoder) and Silero VAD through sherpa-onnx's C API, and OPUS-MT encoders and decoders (12 pairs) through the `ai.onnxruntime` Java API.

- Build **onnxruntime v1.28.0** from source (https://github.com/microsoft/onnxruntime, tag `v1.28.0`, MIT) for Android with:
  - `--android --android_abi <abi> --android_api 26 --android_ndk_path <the installed NDK 28.2> --build_java`;
  - `--include_ops_by_config <your config>`, `--config MinSizeRel`, `--skip_tests`, `--parallel`;
  - for arm64-v8a, armeabi-v7a and x86_64 (the emulator).
  Package an AAR (`tools/ci_build/github/android/build_aar_package.py`, or its steps by hand) at `android/app/libs/onnxruntime-kosha-1.28.0.aar`, and switch `implementation(...)` to `files("libs/...")`. Keep `testImplementation("com.microsoft.onnxruntime:onnxruntime:1.28.0")` for JVM tests.
- **The op config:** generate it with onnxruntime's `tools/python/create_reduced_build_config.py` over every model in `%USERPROFILE%\.kosha\packs\staging\` (voice-whisper-base, voice-whisper-small, all translate-* folders; read only, never modify them). Keep ONNX model support: no `--minimal_build`, because the packs ship `.onnx` files and sherpa-onnx loads them through the ONNX loader. Check the config in at `tool/onnxruntime/ops.config`, with the script that made it.
- Write `tool/onnxruntime/build_android.ps1` so the orchestrator can redo the build, and `tool/onnxruntime/check_aar.ps1`, which fails unless:
  1. every ABI's `libonnxruntime.so` exports `OrtGetApiBase@@VERS_1.28.0` (llvm-readelf from the NDK);
  2. the AAR has no `ai/onnxruntime/telemetry` classes and no `<uses-permission>`;
  3. every op used by every staged model is in the build (compare the models' op list with the config).
- **No network code and no telemetry:** check the build flags for anything that adds them, and say so in `docs/notices/onnxruntime.md` (licence, version, flags, the SHA-256 of each `.so`).
- **Targets:** arm64 APK ≤ 60 MB. Report the size per ABI and of each `.so` before and after.
- **If the Windows toolchain blocks you** (CMake, Ninja, Python or NDK problems) for more than about an hour, stop. Report the exact error, what you tried and what to install, and go on with parts 2 and 3. Do not change `build.gradle.kts` unless the AAR passes `check_aar.ps1`.

## Part 2: performance budgets

Host benchmarks in `test/perf/` (tagged `@Tags(['perf'])`, run by default with loose limits so CI catches big regressions):
- key tap → commit through `InputController` with the real English dictionary (< 30 ms budget; report the median and p95 on this PC);
- `suggest()` with 1 and 3 blended languages (< 8 ms p95);
- swipe decode with 3 languages (< 40 ms p95);
- layout and paint of the keyboard view (`KeyboardApp` pumped, frame build time);
- memory: the Dart heap after loading en, en + de + hi, and en + Indic transliteration (`ProcessInfo.currentRss` deltas, as a rough guide).

`tool/bench/device_bench.ps1` (the orchestrator runs it): set `$env:ANDROID_SERIAL='emulator-5554'` and refuse any other serial. Use `dumpsys meminfo app.kosha.keyboard`, `dumpsys gfxinfo` jank stats while it types through `input tap`, and the `[Boot]`/`[Keyboard]`/`[dict]` timings the app already logs. It covers first show (cold engine) and later shows, key → commit, and memory with Latin only and with voice loaded. Write the budgets and a results table to `docs/perf/budgets.md`.

## Part 3: fuzzing and QA

- `test/fuzz/input_controller_fuzz_test.dart`: seeded random sequences (10k steps, several seeds) of `onText` (letters, digits, punctuation, emoji, combining marks, Indic, Arabic), `onSpace`, `onBackspace`, `onEnter`, `deleteWordBackward`, `moveCursor`, selection changes, `startInput` with different fields (password, URL, number, no-suggestions), `finishInput`, suggestion picks, and setting or clearing a fake `TextComposer`. Invariants:
  - no exception;
  - the `FakeEditor` composing region equals the controller's composing word or the composer's preedit;
  - nothing is learned in password fields, incognito or when learning is off;
  - the text never loses characters except through deletes.
  On a failure, print the seed and the shortest failing sequence.
- `docs/perf/oem_matrix.md`: what to check per device family (Samsung One UI, Xiaomi HyperOS, Pixel, TECNO HiOS, a 2 GB RAM phone, a foldable, a tablet): insets and gesture navigation, Keystore when locked, clipboard access, floating mode, TalkBack, and the voice and translation packs.

## Report extras

- APK sizes before and after, per ABI; build flags; check results.
- Host benchmark numbers against the budgets; the fuzz seeds and any bugs found.
- What to check on the emulator: voice (sherpa loads, a model loads), translation EN → ES with the reduced runtime, and `device_bench.ps1`.
