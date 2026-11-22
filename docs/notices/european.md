# Third-party notices: European languages (Wave 3-A)

The dictionaries in `assets/dict/{es,fr,de,pt-BR,pt-PT,id,ru,uk}.mdict` are built from word lists by
`tool/build_dictionary.dart`, using `tool/european/prepare_wordlist.py` and `tool/european/build_dictionaries.py`.
The layouts `assets/layouts/{qwerty_es,azerty,qwertz,qwertz_umlaut,jcuken_ru,jcuken_uk}.json` are written by
`tool/european/make_layouts.py` from the shared rows of `qwerty.json`. No network code is involved.

## Source of the word lists

- **Project:** HeliBoard dictionaries (`aosp-dictionaries`, maintained by Helium314), the `wordlists/*.combined`
  files and their `.source` descriptions.
- **URL:** https://codeberg.org/Helium314/aosp-dictionaries (raw files under `wordlists/`)
- **Retrieved:** 22 November 2026 (the repository's README lists its last update per language).
- **Attribution:** word lists by the Leipzig Corpora Collection (Wortschatz Leipzig), as credited by the
  aosp-dictionaries project.

## Per language

| Language | Source file | Licence | Words | Bigrams | Size (bytes) |
|---|---|---|---|---|---|
| Spanish (`es`) | `wordlists/main_es__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 70,000 | 70,000 | 1,430,689 |
| French (`fr`) | `wordlists/main_fr__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 62,000 | 60,000 | 1,400,411 |
| German (`de`) | `wordlists/main_de.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 56,000 | 46,000 | 1,438,489 |
| Portuguese, Brazil (`pt-BR`) | `wordlists/main_pt_BR.combined` | See the note below | 70,000 | 0 | 1,296,162 |
| Portuguese, Portugal (`pt-PT`) | `wordlists/main_pt_PT__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 66,000 | 62,000 | 1,432,261 |
| Indonesian (`id`) | `wordlists/main_id__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 58,000 | 38,000 | 1,442,903 |
| Russian (`ru`) | `wordlists/main_ru__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 78,000 | 0 | 1,431,798 |
| Ukrainian (`uk`) | `wordlists/main_uk__experimental.combined` | CC BY 4.0 (Wortschatz Leipzig lists) | 85,000 | 0 | 1,459,689 |

Every file is under the 1.5 MB budget. Word counts are the words kept after cleaning; the builder drops
junk tokens (for example 436 in Spanish, 12,434 in French). Only the most frequent words are kept, and the
experimental lists also carry next-word (bigram) data, which is kept where it fits the size budget.

### Portuguese, Brazil: licence to confirm

`main_pt_BR` is the AOSP pt_BR list (2014) as patched by joaohcopetti in
https://github.com/joaohcopetti/aosp-dict-pt-br-patched (grammar corrections with Hunspell). The HeliBoard
`.source` file only says "AOSP dictionary modified". The AOSP project is Apache-2.0, but the repository
states no licence for the patched list, and we did not verify the licence of the underlying word data.
**Before release the orchestrator must confirm this file's licence**, or replace it with a CC BY or CC0 Brazilian
Portuguese list. The build removes 36 words that are Portugal-only from it (for example *autocarro*, *equipa*)
and `pt-PT` removes 29 Brazil-only words (for example *ônibus*, *trem*), so each variant keeps its own vocabulary.

## Licence summary

- CC BY 4.0: Wortschatz Leipzig word lists, as credited by the HeliBoard project. Attribution is this notice.
- Apache-2.0 / unconfirmed: the pt-BR list (see above).
- GPL-3.0-or-later: the tools in `tool/` and the Dart code in this area.
