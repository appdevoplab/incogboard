# Wave 2-D: emoji, clipboard and text-editing panels

Read `docs/waves/wave2/COMMON.md` first. Plan sections to read: "Panels and modes", "Privacy and security" (clipboard rules), "Typing feel" (selection chips), "Languages" (the language list).

## Ownership

**You own:**
- `lib/src/features/**`, EXCEPT `lib/src/features/shortcuts/**`, which belongs to Wave 2-B.
  - Keep `createPanelsFeature()` in `lib/src/features/features.dart`, which `keyboard_main.dart` calls.
  - Suggested folders: `emoji/`, `clipboard/`, `editing/`.
- `tool/build_emoji.dart` (new) and `assets/emoji/**`. The folder is already declared in `pubspec.yaml`.
- `lib/src/settings/sections/clipboard_settings.dart`: you may add optional fields.
- `docs/notices/emoji.md`.
- Tests: `test/features/**` (except `shortcuts/`), `test/tool/build_emoji_test.dart`.

Everything plugs in through the seams. **Never edit `lib/src/keyboard/**`.** Use:
- `KeyboardFeature.attach(session)`, which returns `KeyboardHooks(onEmoji, onClipboard, onEditing)`
- `session.openPanel` / `closePanel`, using `PanelPlacement.full` for the panels and `.strip` for emoji search
- `session.showChip` / `removeChip`
- `session.input.decorators`, `insertText`, `finishComposing`, `editor`, `resyncAfterExternalEdit`
- `session.services.events.clipboard` (Kotlin's clipboard watcher), `events.selection`, `events.settingsChanged`
- `session.services.host.getPrimaryClip()` / `setPrimaryClip()`, and `session.services.platform.hasGlyphs()`

The panels must look native to the keyboard. Paint with `KeyboardThemeData` (the `PanelContext.theme`):
- background and fills from the theme
- `keyCornerRadius`, labels from `fontFamily` and `labelWeight`
- strip-style top bars at `KeyboardMetrics.stripHeight` (44 dp)

## Build

### 1. Emoji data (`tool/build_emoji.dart`, run at dev time with network)

- **Sources:**
  - Unicode `emoji-test.txt`, the latest released version, from https://unicode.org/Public/emoji/latest/.
  - CLDR `annotations` and `annotationsDerived` XML (latest release, from GitHub `unicode-org/cldr`) for all 17 planned languages: en, es, fr, de, pt, id, hi, mr, bn, ta, te, ar, ur, ru, uk, zh, ja.
  - The licence is Unicode License v3. Record exact versions and URLs in `docs/notices/emoji.md`.
- **Output** in `assets/emoji/`:
  - `emoji.bin` or a gzipped JSON. It holds the groups and subgroups in order, and the fully-qualified emoji with their skin-tone variants grouped under the base emoji. It also holds the Unicode version each emoji arrived in (so old fonts can be filtered fast) and the English name.
  - `keywords_<lang>.gz` per language: keyword to emoji indices, plus the short name.
- **Size budget:** all files together at most 2.5 MB. Measure it and put it in your report.
- **Loading:** lazily, off the UI isolate (`compute` / `Isolate.run`), only for `settings.languages.enabled` plus English.
- Build-tool tests use a tiny fixture: parsing `emoji-test.txt` lines, skin-tone grouping, ZWJ sequences and annotation merging.

### 2. Emoji panel (`PanelPlacement.full`)

- **Top bar:** search button, category tabs (Recents, Smileys & People, Animals & Nature, Food, Activities, Travel, Objects, Symbols, Flags), kaomoji tab, symbols tab.
- **Bottom bar:** "ABC" (close), space, and a delete key that calls `session.input.onBackspace()`, repeating on hold. It must delete a whole emoji grapheme; the controller handles grapheme clusters.
- **Grid:** lazy (`GridView.builder` or a `CustomPainter` per page), about 8 columns on phones, smooth at 60/120 Hz. Tapping inserts with `input.insertText(emoji)` and a haptic tick (`host.performHaptic(HapticKind.keyTap)` when haptics are on).
- **Skin tones:** long-press an emoji that has variants to get a popup with the 5 tones plus the default. The choice is remembered per emoji, and the last choice becomes the default for new ones.
- **Recents:** ranked by frequency with decay, at most 32. Stored in `DataBlobs.emoji` with skin-tone choices, saved with a debounce, never written while incognito.
- **Unsupported emoji:** hide what the device font cannot draw.
  - Use the emoji's Unicode version against `getAppInfo().sdkInt` for a fast first cut.
  - Then call `platform.hasGlyphs()` in batches of 200 for the rest, on first open.
  - Cache the result in the emoji blob, keyed by `sdkInt` plus the app version.
- **Kaomoji tab:** about 150 curated entries, grouped (happy, sad, love, angry, …). Write your own list; do not copy one.
- **Symbols tab:** maths, arrows, currency, punctuation and Greek letters, from Unicode blocks you choose.
- **Search** (`PanelPlacement.strip` with a `KeyRedirect`):
  - The strip becomes a search field showing the query, with matching emoji next to it. The keyboard's own keys type into it; the redirect receives `onText`, `onSpace`, `onBackspace` and `onEnter`.
  - Results: prefix match on keywords in all enabled languages, best first. Update on every key, within 5 ms.
  - Tapping a result inserts it and keeps search open. Enter or a back arrow returns to the emoji panel.
- **Emoji suggestions** (`TypingSettings.emojiSuggestions`): a `SuggestionDecorator`. When `query.composing` exactly matches a keyword or short name in an enabled language (for example "pizza", "love", "प्यार"), add ONE `Suggestion(emoji, kind: SuggestionKind.emoji)` at the end.
  - Picking it gives "pizza 🍕 "; the controller already does this.
  - Next-word predictions do not get emoji.
  - Budget: under 0.3 ms per call (a precomputed map).

### 3. Clipboard

Follow the plan's privacy rules exactly.

- **History store:** `DataBlobs.clipboard`, holding items `{id, text, timestamp, pinned}`.
  - Text only, up to `maxItems` (30), and the 20k-character cap Kotlin already applies.
  - Recorded from `events.clipboard` only when `clipboard.history` is on, the keyboard is not incognito, and the clip is not `isSensitive`.
  - Duplicates move to the top.
  - Unpinned items older than `expiryMinutes` are pruned on load and every time the panel opens. Pinned items never expire.
  - Debounced saves.
  - Reload on `DataSections.clipboard` / `all`, for example after the privacy center wipes it.
- **Recent-copy chip** (`clipboard.recentChip`): after a new clip, show a `StripChip` for 60 s: id `clipboard.recent`, label `Paste "<first 20 chars>…"` with newlines shown as ⏎. Tapping inserts the full text.
  - **Sensitive clips** (`isSensitive`): never stored and never shown. The chip label is `Paste ••••`, and tapping reads the clip again with `host.getPrimaryClip()` at that moment, then inserts it.
- **Clipboard panel** (`PanelPlacement.full`):
  - Top bar with back, a history on/off switch and "Clear all", which asks to confirm and keeps pinned items.
  - Items as cards, newest first: tap to paste, pin/unpin, delete.
  - An empty state that explains the 1-hour expiry and that passwords are never saved.
  - When the store cannot be read because the phone is locked, show "Unlock your phone to see clipboard history".
  - Long items show 3 lines with an ellipsis.
  - The panel never opens in password fields; the session already blocks that.

### 4. Text-editing panel (`PanelPlacement.full`, from `onEditing`)

- **Buttons:** arrows ◀ ▶ ▲ ▼ (DPAD key events, repeating on hold), Select (toggles selection mode: arrows send Shift+DPAD), Select all, Cut, Copy, Paste, Undo (Ctrl+Z), Redo (Ctrl+Shift+Z), Home, End, and a back key.
  - Use `editor.sendDownUpKeyEvent(keyCode, metaState:)` with the Android key codes and meta states (define the constants you need in your folder).
  - Cut, Copy, Paste and Select all use `editor.performContextMenuAction`.
  - Call `input.finishComposing()` before each action and `input.resyncAfterExternalEdit()` after.
- **Layout:** a large arrow cluster, M3 tonal buttons, labels and icons, semantics labels.
- **Selection chips:** when `events.selection` reports a non-empty selection (`newSelStart != newSelEnd`) outside password fields, show chips `Cut`, `Copy` and `Select all` (ids `editing.cut` and so on, priority 10). Remove them when the selection collapses or the field changes.

### 5. Wiring (`createPanelsFeature`)

- `attach(session)` creates the stores, subscribes to events, adds the emoji decorator, and returns `KeyboardHooks(onEmoji:, onClipboard:, onEditing:)`.
- `detach()` cancels subscriptions and flushes stores.
- The emoji key in the bottom row (Wave 2-E adds it to the layouts) fires `hooks.onEmoji` through the existing `KeyType.emoji`.

## Tests

- Build-tool parsing, with fixtures.
- Emoji panel: tap inserts, skin-tone popup and memory, recents ranking, `hasGlyphs` filtering with a fake platform, search via the redirect with a fake session (see `test/keyboard/seams_test.dart` for how to pump `KeyboardApp` with a feature).
- Emoji decorator: exact keyword, other language, setting off.
- Clipboard: recording rules (sensitive, incognito, history off), expiry, pin, max items, dedupe, chip text and expiry, reload notification.
- Editing: each button sends the right key events and calls `finishComposing`/`resyncAfterExternalEdit`; selection chips appear and disappear.

## Report extras

- Asset sizes and load times (emoji index load, search latency, panel first-open time).
- What the orchestrator should check on the emulator: emoji rendering on API 37, skin tones, a copy in another app then the chip, the editing keys in the testbed.
