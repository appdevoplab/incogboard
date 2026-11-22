# Kosha performance budgets

Owner: Wave 4-D (performance and QA). Budgets come from the approved plan ("Performance budgets").
Host numbers come from `flutter test test/perf` (tag `perf`) in the JIT test VM on the dev PC, so
a phone in release mode should do better. Device numbers come from `tool/bench/device_bench.ps1`,
which the orchestrator runs on the emulator (never on the personal phone).

## Budgets

| Measure | Budget | Test |
|---|---|---|
| Key tap -> text committed (InputController, real en dictionary) | < 30 ms | `test/perf/perf_budgets_test.dart` |
| `suggest()` with 1 language, p95 | < 8 ms | same |
| `suggest()` with 3 languages (en, de, fr), p95 | < 8 ms | same |
| Swipe decode with 3 languages, p95 (incl. isolate hop) | < 40 ms | same |
| Keyboard frame while typing | 16 ms on a phone; test ceiling 50 ms | same (`testWidgets`) |
| Memory: RSS deltas after loading dictionaries | rough guide; guard < 512 MB | same |
| First show after cold start (engine, dictionaries) | to be set from device runs | `device_bench.ps1` |
| APK arm64 release size | <= 60 MB (target from the reduced onnxruntime) | `build.gradle.kts`, `docs/notices/onnxruntime.md` |

## Host results (this PC, JIT test VM)

Run: `flutter test test/perf -r expanded`, 2026-11-22.

| Measure | Median | p95 | Max | Result |
|---|---|---|---|---|
| Key tap -> commit (en, 1330 keys) | 0.20 ms | 0.61 ms | 11.0 ms | within 30 ms |
| `suggest()` 1 language (en) | 0.21 ms | 0.53 ms | 1.0 ms | within 8 ms |
| `suggest()` 3 languages (en, de, fr) | 0.57 ms | 1.14 ms | 3.9 ms | within 8 ms |
| Swipe decode 3 languages (60 synthetic swipes) | 0.43 ms | 1.19 ms | 1.3 ms | within 40 ms |
| Keyboard frame while typing (43 frames) | 4.05 ms | 7.34 ms | 9.4 ms | within 50 ms test ceiling |

Notes:
- The swipe check also decodes 10 synthetic swipes once for accuracy: 10 of 10 top-1 correct.
- Dictionary loads (not in the budgets): en 147k words in 32-62 ms, de 54k in 14-28 ms, fr 59k in 14-15 ms,
  hi 50k in 13 ms. Gesture template build for 3 languages: about 1.1 s, once per language set.
- Memory (RSS, `ProcessInfo.currentRss`, so noisy; a GC can make a delta negative):
  en +31.1 MB; de + hi -71.8 MB (GC during the step); hi transliteration data +0.7 MB.
  Treat these as a rough guide only. The Dart heap is not measured separately.

## Device results (emulator, `tool/bench/device_bench.ps1`)

Not run yet. The orchestrator runs it with the emulator attached and no other device:

```
powershell -ExecutionPolicy Bypass -File tool\bench\device_bench.ps1 -Phase latin
powershell -ExecutionPolicy Bypass -File tool\bench\device_bench.ps1 -Phase voice
```

Paste the printed tables here, with the `[Boot]` / `[Keyboard]` / `[dict]` log lines for cold and
later shows.

| Measure | Latin only | Voice loaded | Budget |
|---|---|---|---|
| First show, cold engine | pending | pending | to set |
| Later show | pending | pending | to set |
| Key -> commit (in-app, `[Keyboard]`) | pending | pending | < 30 ms |
| Janky frames while typing | pending | pending | to set |
| TOTAL PSS | pending | pending | to set |

## APK size (onnxruntime)

The arm64 release APK was 79.0 MB, with `libonnxruntime.so` at 27.3 MB (full operator set).
The stock onnxruntime-android 1.28.0 AAR, from the Gradle cache, has these `.so` sizes:

| ABI | Stock `libonnxruntime.so` | Reduced build |
|---|---|---|
| arm64-v8a | 28,637,280 bytes (27.3 MiB) | not built |
| armeabi-v7a | 20,388,560 bytes | not built |
| x86_64 | 34,640,104 bytes | not built |

The reduced build could not start: the onnxruntime v1.28.0 source is not downloadable from GitHub
from this PC. See `docs/notices/onnxruntime.md`. The APK target (<= 60 MB) is open until that is resolved.
