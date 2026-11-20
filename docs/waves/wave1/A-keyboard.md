# Wave 1-A: keyboard view and input controller

Read `docs/waves/wave1/COMMON.md` first. Plan sections to read: Typing feel, Suggestions, Swipe, Themes.

## Ownership

**You own:**
- `lib/src/keyboard/**`, EXCEPT `lib/src/keyboard/gesture_layer/**`, which belongs to Wave 1-C. In `layout_model.dart` you may only ADD optional fields or helpers, keeping the JSON format backward compatible.
- `assets/layouts/**`
- `test/keyboard/**`

Replace the placeholder in `lib/src/keyboard/keyboard_app.dart`, but keep `KeyboardApp({required KeyboardServices services})`.

**Other agents work in parallel behind contracts you only call.** Your code must work with today's stubs and with the real implementations later.
- `TextPredictor` and `LexiconSource` come from Wave 1-B. Today they are a prefix-completion stub.
- `GestureDecoder` and the trail painter come from Wave 1-C. Today the decoder does nothing.
- `resolveKeyboardTheme` comes from Wave 1-D. Today it returns a fallback.

## Build

### 1. Layouts

Files go in `assets/layouts/*.json`, using the format in `layout_model.dart`.

- **`qwerty`:**
  - Digit hints on the top row.
  - Long-press popups with the hinted digit plus Latin accents: é è ê ë ē ė ę / á à â ä æ ã å ā / í ì î ï ī / ó ò ô ö õ ø ō œ / ú ù û ü ū / ñ ń / ç ć č / ß ś š / ý ÿ / ž ź ż.
- **`symbols`:** a digit row plus @ # $ % & - + ( ) / * " ' : ; ! ?, and a currency key whose popup has ₹ € £ ¥ ₩ ₽ ₴ R$ Rp.
- **`symbols2`:** ~ ` | • √ π ÷ × ¶ ∆ £ ¥ € ¢ ^ ° = { } \ © ® ™ ✓ [ ] < >
- **`numpad`:** numbers, decimal and minus.
- **`phone`:** a phone pad with + * # , ;
- **Bottom row:** symbols key, comma, space, period, enter. Long-press on the period offers , ? ! ' " : ; - ( ) @ #.
- **Email fields:** replace the comma with @ and add a .com key. Its popup offers .net .org .in .co.id .de .fr .es .com.br .ru .ua .jp .cn.
- **URL fields:** use / and .com.

### 2. Layout engine

- Compute key rects for a given size:
  - row heights are relative
  - key widths are in units
  - row padding comes from the layout
  - key gaps come from the theme
- Support an optional number row (`TypingSettings.numberRow`).
- Build a `KeyboardGeometry` of the character keys, mapping lower-case output to a rect in keyboard-local logical px.
- When the geometry or languages change, call `predictor.setGeometry` and `gestureDecoder.prepare(geometry:, languages:, extraWords: predictor.learnedWords(lang))`.

### 3. Rendering

Paint from `KeyboardThemeData` only:
- Fills per key group: letter, function, action and space.
- Labels using `fontFamily`, `labelWeight`, `labelFontVariations` and `labelScale`.
- Hint labels when `theme.showHints && TypingSettings.hintLabels`.
- Corner radius = `keyCornerRadius` × the key's shorter side; plus `keyGap` and `borderWidth`.
- Background colour, gradient or image, with dim.

**Press animation:**
- A spring (`SpringSimulation` using `MotionSpec.stiffness` and `dampingRatio`) that scales the key to `pressScale`, with a slight corner-radius morph.
- No animation when `motion.enabled` is false.

**Performance:** keep rebuilds cheap. Use a per-key `RepaintBoundary` or a `CustomPainter`, and never rebuild every key on each keystroke.

**Accessibility:** add Semantics labels such as "Shift, on", "Delete" and "Space".

### 4. Touch

**Keys:**
- Read raw pointers through a `Listener`.
- Hit-testing picks the nearest key centre within the touched row band, so there are no dead zones in the gaps.
- Show the pressed state on pointer down and commit on pointer up.
- Multi-touch rollover: when a second finger lands, commit the first key.

**Popups:**
- A long-press after `TypingSettings.longPressDelayMs` opens the alternatives popup. Slide to choose, release to commit; the first item is preselected.
- Show a key preview popup on press, unless `TypingSettings.keyPopups` is false or `field.isSensitive`.
- Popups must stay inside the keyboard view, because the IME window has no space above it. Top-row popups overlap the suggestion bar.

**Special keys:**
- Backspace repeats with acceleration: first repeat after 400 ms, then the interval shrinks from 60 to 25 ms. After about 2 s it switches to deleting whole words. Leave clean hooks for Wave 2's swipe-to-delete-words and spacebar-cursor gestures.
- Long-press on space calls `host.showInputMethodPicker()`.

**Feedback:**
- Haptics on key down (`host.performHaptic`, with a `HapticKind` per action).
- Sounds per key type (`host.playKeySound`).
- Push `FeedbackSettings` through `host.setFeedbackConfig` at start and whenever settings change.

### 5. Shift

- Tap for one-shot; double-tap within 300 ms for caps lock.
- Auto-capitalize from `InputSink.getCursorCapsMode` at field start and after sentence ends. Respect `TypingSettings.autoCapitalize`, the field's cap flags, and `LanguageRules.hasCase`.
- Labels follow the case unless `TypingSettings.lowercaseLabels` is set.
- Shift icon states: outline, filled, filled with underline.

### 6. InputController

Pure Dart, in `lib/src/keyboard/input/`, unit-tested with `FakeEditor`.

**Composing and committing:**
- Keep the current word as composing text (`setComposingText`) so suggestions can replace it. Separators commit it.
- On a separator, apply `SuggestionResult.autoCorrection` when `TypingSettings.autoCorrect && field.allowsAutoCorrect`.
- Backspace right after an auto-correction reverts to the typed word and calls `predictor.onAutoCorrectionReverted`.
- Picking a suggestion replaces the composing word and adds one space.
- Use `beginBatchEdit`/`endBatchEdit` around multi-step edits.

**Spacing and enter:**
- Double space becomes ". " (`TypingSettings.doubleSpacePeriod`).
- Punctuation swallows the preceding auto-space and adds one after it (`services.rulesFor(lang)`).
- After a space typed on a symbols page, return to letters.
- Enter inserts a newline when `field.enterInsertsNewline`; otherwise it calls `performEditorAction(field.editorActionId)`.

**Special field types:**
- Raw key mode (`field.isRawKeyMode`): use `sendDownUpKeyEvent` for enter and backspace, and `commitText` without composing.
- Sensitive (password) fields: no composing, no suggestions, no learning, no popups. Call `host.setSecureWindow(true)` while the field is focused, then restore `PrivacySettings.hideFromScreenshots`.

**Editor events:**
- A cursor jump on `events.selection` finishes composing and resets state.
- `events.startInput` resets per field and picks the initial page from `field.preferredPage`.

**Context and learning:**
- Keep up to 3 previous words: from `getTextBeforeCursor(64)` at field start, then from commits.
- Call `predictor.onWordCommitted(word, previousWords:, allowLearning: field.allowsLearning && privacy.learning && !privacy.incognito && !privacy.incognitoApps.contains(field.packageName))`.

### 7. Suggestion strip (44 dp)

- 3 slots, best in the centre, tap to apply. Show the typed word in quotes when it's unknown.
- When not composing, show next-word predictions (`TypingSettings.nextWordPrediction`).
- When suggestions aren't allowed, show a toolbar row of icon buttons for Wave 2 to wire: emoji, clipboard, theme, and settings (`host.openSettings(null)`).
- Show a "Private field" lock chip for sensitive fields, and an incognito indicator.

### 8. Gesture typing (contracts only)

**Detection and trail:**
- A gesture starts when a single pointer lands on a letter key and moves more than 0.6 × key width before lifting. Only when `SwipeSettings.enabled`, and never in sensitive fields.
- Feed `TouchPoint`s into a `GestureTrailController`. Use keyboard-local coordinates, the same space as `KeyboardGeometry`.
- Stack `GestureTrailLayer(controller:, theme:, trailWidth:, fadeMs:, showTrail:, showPreview:)` above the keys.
- When `SwipeSettings.livePreview`, throttle `gestureDecoder.preview(...)` to about every 50 ms into `controller.preview`.

**Committing a swipe:**
- On lift, call `gestureDecoder.decode(path, previousWords:)`.
- Commit the top candidate with smart spacing: add a space before it when the previous character is a letter. Show the other candidates in the strip.
- Backspace right after a swipe deletes the whole word.
- A swipe right after Shift gives a Capitalised word.

### 9. Window height

- Content = suggestion strip + rows. Each row is about 56 dp × `AppearanceSettings.heightScale` (`landscapeHeightScale` in landscape). Add `MediaQuery.viewPadding.bottom`.
- Send `host.setWindowLayout(WindowLayoutMessage(mode: WindowMode.docked, heightDp: total))` only when the value changes.
- Paint the background under the bottom inset too.

### 10. Theme

`resolveKeyboardTheme(appearance:, systemColors:, systemDark:, disableAnimations:)`, where:
- `systemColors` comes from `platform.getSystemColors()`, refreshed on `events.systemColorsChanged`.
- `disableAnimations` comes from `MediaQuery.disableAnimations`.

### 11. Settings and languages

- React to `services.settings`, which is a `ChangeNotifier`.
- Call `predictor.setActiveLanguages(['en'])` for now; more languages arrive in Wave 3.

## Tests (`test/keyboard/`)

**InputController scenarios**, using `FakeEditor` plus a fake predictor and decoder:
- typing and composing
- autocorrect apply and revert
- suggestion pick
- double-space period
- punctuation spacing
- caps behaviour
- enter per field type
- password rules
- raw key mode
- swipe commit
- backspace after a swipe

**Other tests:**
- Layout engine geometry: rects, no dead zones, the number row.
- A widget test that pumps `KeyboardApp` with fake services and taps keys. The fakes are `FakeEditor`, mocktail mocks for `ImeHostApi` and `PlatformHostApi`, `SettingsStore.memory()` and `InMemorySecureBlobStore`.
- Measure key-handling time in a benchmark-style test and report it.
