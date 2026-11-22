# Wave 4-C: TalkBack on the keyboard, then the settings app in 7 languages

Read `docs/waves/wave4/COMMON.md` first. Plan sections: "Settings app, onboarding and privacy center", "Verification" (TalkBack works), "Typing feel".

## Ownership

**You own:**
- Keyboard accessibility:
  - `lib/src/keyboard/view/keys_painter.dart` (its semantics) and `lib/src/keyboard/view/key_visuals.dart` (spoken names).
  - Anything new under `lib/src/keyboard/a11y/**`.
  - **Labels only** (semantics labels, hints and tooltips, no layout or behaviour changes) in `lib/src/keyboard/view/suggestion_strip.dart`, `lib/src/keyboard/candidates/**`, `lib/src/keyboard/modes/**` and `lib/src/features/{emoji,clipboard,editing,shared,translate,voice,languages,indic}/**`.
- Settings app localisation:
  - `lib/l10n/*.arb` (`app_en.arb` is the template).
  - Replacing user-visible string literals with `context.l10n.<key>` in `lib/src/app/**`, **except** `lib/src/app/chinese/**`, `lib/src/app/japanese/**` (Agents A and B write those in English at the same time) and `lib/src/app/onboarding/kosha_mascot.dart` (Agent E).
  - `assets/notices/**` stays English (licence texts are never translated).
- `android/app/src/main/res/xml/locales_config.xml` (new; Android 13+ per-app language). Ask in your report for the manifest's `android:localeConfig` attribute.
- `docs/a11y/**`.
- Tests: `test/keyboard/a11y/**`, `test/app/l10n/**`. Existing tests under `test/app/**` may only be edited where a string they look for changed.

`lib/src/app/l10n.dart` (the delegates and the `context.l10n` extension) is orchestrator-owned. If you need a helper there, ask in your report.

## Part 1: TalkBack on the keyboard (do this first)

TalkBack users type on an IME by exploring with one finger: each key is announced on touch, and lifting the finger (TalkBack's default IME typing mode) or a double tap types it.
- **Every key is a semantics node** (the painter's `SemanticsBuilderCallback`): label from `KeyVisual.semantics`, a `button` role, `onTap` → `KeyboardViewController.activateKey`, and the current state (shift "on", "caps lock on", the selected page). Check the node order (row by row, left to right, even for RTL languages, since the rows keep their physical order) and that nodes follow layout changes (shift, page, language, one-handed and floating modes).
- **Long-press alternatives** (accents, ZWJ/ZWNJ, popups): expose them as `customSemanticsActions` on the key ("Type é", "Type ZWJ"), so they need no long press.
- **Flick keys** (12-key Japanese): one custom action per direction ("Type い", ...), with the centre on tap. Spoken names come from the output, or the key's `spoken` field when the layout sets it.
- **Spoken names:** extend `spokenName` and the `_spoken` table for symbols, currency signs, Indic marks (virama "halant", nukta, anusvara, visarga, chandrabindu), Arabic harakat ("fatha", "kasra", ...), and the CJK marks (`、` "comma", `。` "full stop", `ー` "long vowel mark"). Speak a combining mark by its name, not as a lone mark.
- **Announcements** (the current `SemanticsService` announcement API, polite): page changes ("Symbols", "Letters"), language switch ("Deutsch"), caps lock, swipe-typed word, panel open and close. No typed text, ever (privacy): announce the event, not the content. The editor already reads committed text.
- **Strip and candidates:** labels say what a tap does ("Suggestion: the", "Candidate 你好, 1 of 12"), and the toolbar buttons have labels. Add `liveRegion` where it helps.
- **Panels:** an audit pass for labels and focus order in emoji, clipboard, editing, voice and translate. Only label changes there.
- **Touch targets** under 48 dp (toolbar buttons about 40 dp, the 44 dp strip): list them in `docs/a11y/report.md` with a proposed fix. The strip height is orchestrator-owned.
- Write `docs/a11y/talkback.md`: how to test on a phone, and what the orchestrator should try.

### Tests (part 1)

With `tester.ensureSemantics()` and `SemanticsHandle`:
- every key has a label and a tap action;
- a tap action types;
- custom actions type the alternatives and the flick directions;
- shift and caps states are in the labels;
- an announcement follows page and language changes, and no announcement contains typed text.

## Part 2: The settings app in en, es, fr, de, pt (Brazil), id, hi

- Move every user-visible string in `lib/src/app/**` (outside the exceptions above) into `app_en.arb` with a `@key` description for translators: where it appears and its length limit. Use placeholders (`{count}`, `{size}`) and ICU plurals, never string concatenation. Keep key names stable and descriptive (`privacyWipeConfirmTitle`).
- Write `app_es.arb`, `app_fr.arb`, `app_de.arb`, `app_pt.arb` (Brazilian Portuguese), `app_id.arb` and `app_hi.arb` with natural, short translations in the app's tone (plain words, no jargon). Mark every string you are unsure of with `"x-review": true` in its `@key` entry, so a native speaker can check it later.
- Language names keep using `LanguageInfo` (native names are never translated); English names come from the ARB files.
- Keep `Kosha` untranslated. Licence texts stay English.
- Layout checks: German and Hindi strings are long, so run the screens at font scale 1.3 in `de` and `hi` with no overflow.
- The app follows the device language (`supportedLocales`), and Android 13+ users can pick it per app (`locales_config.xml`).

### Tests (part 2)

- Every key in `app_en.arb` exists in every other ARB file, placeholders match, and nothing is empty.
- Golden-free smoke tests: each main screen builds in each of the 7 locales at font scale 1.3 without overflow (use `koshaLocalizationsDelegates` and `locale:`).
- No literal user-visible strings left in `lib/src/app/**` outside the exceptions: write a test that scans the sources for `Text('...')`, `title: '...'` and similar, with a short allow-list.

## Report extras

- Key count, string count per locale, the strings marked for review.
- What to check on the emulator: TalkBack on, explore the QWERTY and 12-key layouts, an accent through the actions menu, a page change announcement, and the settings app in Hindi and German.
