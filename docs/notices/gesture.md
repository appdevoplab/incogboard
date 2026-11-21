# Gesture (swipe) typing: third-party notices

## Algorithm references (no code copied)

The swipe decoder in `lib/src/engine/gesture/` is an original implementation of ideas from these works. No source code
was copied or ported from either project.

- **SHARK² (Shorthand-Aided Rapid Keyboarding)**: P.-O. Kristensson and S. Zhai, "SHARK2: A Large Vocabulary Shorthand
  Writing System for Pen-Based Computers", ACM UIST 2004. Source of the template-matching approach (word templates
  through key centres, resampled to equal arc-length points, a location channel and a shape channel).
- **FlorisBoard `StatisticalGlideTypingClassifier`**: https://github.com/florisboard/florisboard (Apache-2.0).
  Inspiration for combining the channels as Gaussian likelihoods with a language-model prior and for pruning candidates
  by the first and last key. If any of its code is ever ported, keep the Apache-2.0 notice and attribute it here.

## Test data (not shipped in the app)

`test/engine/gesture/fixtures/en_words.tsv.gz` is a derived, compacted copy of the American English word list of the
Android Open Source Project's LatinIME keyboard:

- Source: https://android.googlesource.com/platform/packages/inputmethods/LatinIME/+/refs/heads/main/dictionaries/en_US_wordlist.combined.gz
- License: Apache License 2.0 (AOSP), compatible with GPL-3.0.
- Copyright: The Android Open Source Project.
- Modification: kept only plain word entries (no bigrams, no flagged abbreviations or profanity), the 50,000 entries with
  the highest frequency byte `f` (0 to 255), stored as `word<TAB>f`, gzip-compressed.
- Use: only by the unit tests, to build a realistic 50k-word vocabulary for accuracy and latency measurements.
