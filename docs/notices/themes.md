# Third-party notices: themes and design (Wave 1-D)

## Google Sans Flex (bundled font)

- **Files:** `assets/fonts/GoogleSansFlex.ttf` (variable font, axes `opsz`, `wdth`, `wght` 1-1000, `ROND` 0-100, `slnt`) and its licence `assets/fonts/OFL.txt`.
- **Version:** 5.000 (release v5.000, upstream commit `cedf1e9`, 2026-10-09).
- **Source:** `https://github.com/google/fonts/tree/main/ofl/googlesansflex`, file `GoogleSansFlex[ROND,opsz,slnt,wdth,wght].ttf`. Upstream project: `https://github.com/googlefonts/googlesans-flex`.
- **Integrity:** git blob SHA-1 of the TTF is `1d8d8ae5a7c6d0e48312d2a0a478bad92caee73a` and of `OFL.txt` is `3e50f6cb72e58f01997d1e608195e8fdbc0eb8b4`, both identical to the files in google/fonts.
- **Licence:** SIL Open Font License 1.1. Copyright 2015 Google LLC / The Google Sans Flex Authors. The font is bundled unmodified and under its own name, so the Reserved Font Name clause is respected. The font is declared in `pubspec.yaml` as family `GoogleSansFlex` and is never downloaded at runtime (the `google_fonts` package is not used).
- **Non-Latin scripts:** not covered by this font; the keyboard falls back to the device's Noto fonts.

## Other

No other third-party code or data. Colour schemes come from `ColorScheme.fromSeed` in the `material_ui` package (already a dependency); the Material You role mapping follows the public Material 3 baseline tone assignments.
