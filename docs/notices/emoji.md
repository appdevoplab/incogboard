# Emoji data notice (Wave 2-D)

The emoji panel, emoji search and emoji suggestions use data built offline by `tool/build_emoji.dart`
into `assets/emoji/`. The app never fetches anything at runtime.

## Sources

| Data | Version | URL | Licence |
|---|---|---|---|
| Emoji test data (`emoji-test.txt`) | Unicode Emoji 18.0 (file dated 2026-04-30) | https://unicode.org/Public/emoji/latest/emoji-test.txt | Unicode License v3 |
| CLDR annotations and annotationsDerived (17 languages) | CLDR release-49 (published 2026-10-21) | https://github.com/unicode-org/cldr/tree/release-49/common/annotations and `annotationsDerived` | Unicode License v3 |

Languages: en, es, fr, de, pt, id, hi, mr, bn, ta, te, ar, ur, ru, uk, zh, ja.

The Unicode License v3 text is at https://www.unicode.org/license.txt. Unicode, CLDR and their data are
(c) Unicode, Inc. Myna changes the data only by reshaping it (grouping skin-tone variants, indexing keywords).

## Generated files

| File | Contents | Size (bytes) |
|---|---|---|
| `assets/emoji/emoji.gz` | Groups, subgroups and base emoji with English names, Unicode versions and skin-tone variants (2,338 items) | 28,685 |
| `assets/emoji/keywords_<lang>.gz` | Keyword index and CLDR short names for one language (17 files) | 80,680 to 140,900 each |

Total: 1,805,966 bytes, under the 2.5 MB budget. Rebuild with:

    dart run tool/build_emoji.dart --cache=.dart_tool/emoji_src --out=assets/emoji

The tool downloads the sources into `--cache` once and reuses them. Pass `--cldr-tag=<tag>` to pin another CLDR release.

## Attribution

Emoji artwork is not bundled: the device's own emoji font draws every emoji.
