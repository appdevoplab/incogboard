# Wave 1-C: gesture (swipe) typing

Read `docs/waves/wave1/COMMON.md` first. Plan sections to read: Swipe (glide) typing, Performance budgets, Do more languages make it slow?.

## What you own

- `lib/src/engine/gesture/**`. Keep `createGestureDecoder({required LexiconSource lexicons})` unchanged.
- `lib/src/keyboard/gesture_layer/**`. Keep every public constructor and method signature in `gesture_trail.dart`, and implement the bodies.
- `test/engine/gesture/**`
- `docs/notices/gesture.md`

## How you fit in

- The keyboard view (Wave 1-A, working in parallel) detects gestures, feeds `GestureTrailController`, stacks `GestureTrailLayer` above the keys and calls your decoder.
- Real lexicons arrive later from Wave 1-B through `LexiconSource`. Until then, develop against `InMemoryLexicon` and your fixtures.

## Build

### 1. Decoder facade

- Implement `GestureDecoder` on top of ONE long-lived background isolate:
  - Use `Isolate.spawn` with a `SendPort` request/response protocol keyed by ids.
  - Send bulk data with `TransferableTypedData`.
- Never block the UI isolate.
- For preview requests, the latest request wins; don't let requests pile up.

### 2. `prepare(geometry, languages, extraWords)`

- Load the lexicons via `LexiconSource`: the top ~60k words per language by frequency, plus `extraWords` (learned words).
- Build the templates in the isolate. For each word:
  - Build a key-centre polyline:
    - Collapse repeated consecutive letters.
    - Map accented letters to their base key (é→e).
    - Ignore apostrophes, so a "dont" path yields "don't".
    - Skip words whose characters aren't on the layout.
  - Resample it to 64 equidistant points.
  - Precompute the normalized shape: translate to the centroid, then scale by the bounding-box diagonal.
- Index the templates by (first key, last key).
- Cache by `geometry.cacheKey` plus languages, and rebuild lazily.

### 3. `decode(path, previousWords, maxResults)`

- Resample the gesture to 64 points.
- Prune candidates by:
  - start and end key neighbourhoods (about 1.2 key widths)
  - path-length ratio
  - bounding box
- Score SHARK²-style:
  - location channel: mean point distance divided by keyWidth
  - shape channel
  - combine them as Gaussian log-likelihoods, plus λ·(logProb + bigram with the last previous word)
- Return the top results as `Suggestion(kind: SuggestionKind.gesture, language:)`.
- For very short or one-key paths, return empty. The controller treats those as taps.
- References: Kristensson & Zhai's SHARK², and FlorisBoard's StatisticalGlideTypingClassifier (Apache-2.0). If you port any code, attribute it in `docs/notices/gesture.md`.

### 4. `preview(partialPath)`

- A cheap top-1 guess for the live floating preview, in about 10 ms or less.
- Reuse the same index with fewer candidates and an early exit.

### 5. Trail painter

- Draw a smoothed path (Catmull-Rom or quadratic):
  - width is `trailWidth`
  - gradient runs from `theme.trailStart` to `theme.trailEnd`
- Fade the tail: points older than `fadeMs` (by `TouchPoint.t`) fade out.
- After `end()`, fade the whole trail out quickly.
- When `showPreview` is on, draw a floating M3 pill bubble (`theme.popupFill` / `theme.popupLabel`) above the finger, showing `controller.preview`.
- When `showTrail` is off, draw only the preview.
- Repaint only through the controller. Allocate nothing per frame beyond the path, so it stays 120 fps-friendly.

### 6. `trimMemory()` / `dispose()`

Free the templates and stop the isolate.

## Tests (`test/engine/gesture/`)

Use a realistic vocabulary:

- **Word list fixture:** the top 20k–50k English words with frequencies, saved under `test/engine/gesture/fixtures/` from a GPL-3-compatible source.
  - Use the AOSP LatinIME en_US wordlist (Apache-2.0): `https://android.googlesource.com/platform/packages/inputmethods/LatinIME/+/refs/heads/main/dictionaries/en_US_wordlist.combined.gz?format=TEXT`.
  - The download is base64. Try `master` if `main` fails.
  - Attribute it in `docs/notices/gesture.md`.
- **Test geometry:** a QWERTY layout with rows of 10, 9 and 7 keys, about 1080 px wide, with realistic key sizes.

**Synthetic gestures:** generate them for about 300 common words. Each path goes through the key centres with:
- Gaussian noise (σ ≈ 0.25 key width)
- start/end jitter
- variable sampling density and speed

**Assertions and measurements:**
- Top-1 accuracy must be at least 75%, and top-3 at least 90%.
- Measure decode latency. The target is p95 under 40 ms on a phone, so aim far lower on desktop.

**Also test:**
- learned `extraWords` can be decoded
- accents and apostrophes
- isolate lifecycle (prepare twice, then dispose)
- `preview` returns quickly
