# Wave 2-E: keyboard modes, cursor control and swipe-delete, layouts

Read `docs/waves/wave2/COMMON.md` first. Plan sections to read: "Panels and modes", "Typing feel" (space and backspace), "Performance budgets".

## Ownership

**You own:**
- `lib/src/keyboard/modes/**`. Keep `createModesFeature()` in `modes.dart`, which `keyboard_main.dart` calls.
- `lib/src/keyboard/layout/layout_engine.dart` (split and compact layouts) and `assets/layouts/**` (bottom-row keys).
- `lib/src/settings/sections/mode_settings.dart`: you may add optional fields.
- Tests: `test/keyboard/modes/**`, plus `test/keyboard/layout_test.dart` for your layout changes.

**Read-only for you** (the seams, owned by the orchestrator):
- `keyboard_app.dart`, `keyboard_session.dart`, `panels/keyboard_panel.dart`, `view/**`, `input/**`
- `layout/layout_model.dart` (the JSON format)

You plug in through `KeyboardFeature`:
- `attach(session)` returns `KeyboardHooks(onSpaceDrag:, onBackspaceDrag:, onModes:)`.
- `frame` returns your `KeyboardFrame`.

The Kotlin side of floating mode is done (Wave 1-E):
- `onComputeInsets` keeps the app below from resizing.
- Only `floatingRect` takes touches.
- The window is transparent while floating.

Read `MynaImeService.applyWindowLayout` / `onComputeInsets` to see exactly how `WindowLayoutMessage` is applied.

## Build

### 1. The frame (`KeyboardFrame.build`)

It receives `FrameInfo` (settings, theme, screen size, landscape, bottom inset, content height) plus the `keyboard` and `background` widgets. It returns the window layout and the widget tree. **Docked full-width must look and measure exactly as today:**
- height = content + bottom inset
- background behind everything, including the navigation-bar area
- keyboard at the top of the window

`test/keyboard/keyboard_app_test.dart` checks this, and it must still pass when your frame is active.

- **One-handed** (`modes.oneHanded` left/right, width `oneHandedWidth` 0.6–0.95, default 0.8):
  - The keyboard takes that width on one side.
  - The empty side holds a vertical strip of buttons: "Move to other side" (swap), "Full width" (expand, which turns one-handed off) and, optionally, a resize grip for the width.
  - Animate changes with a spring (respect `theme.motion.enabled`).
  - Docked window layout, same height.
- **Floating** (`modes.floating`, plus `floatingX`, `floatingY` and `floatingWidth`):
  - `WindowLayoutMessage(mode: floating, heightDp: H, floatingRect: rect)`.
    - H is the IME window height. Kotlin clamps it to 120–640 dp. Use `min(640, screen height × 0.85)` so the keyboard can move around a large area.
    - `rect` is the keyboard's rect inside that window, in dp, relative to the window's top-left.
  - Draw the keyboard in a rounded container (theme `keyCornerRadius` scale, elevation shadow), with the background inside the container only, since the window is transparent.
  - On top: a drag handle (pill) that moves it, snapping to the left, right and bottom edges within 16 dp.
  - A corner grip to resize the width, 60–100% of the screen, keeping the key aspect.
  - A "Dock" button.
  - Persist position and width in `ModeSettings` on drag end (`settings.update(..., sections: ['modes'])`). Clamp to the screen after rotation.
  - Leaving floating restores docked.
- **Height handle:** a "Resize" mode from the modes bar (section 2).
  - A bar on top of the keyboard with a grip.
  - Dragging changes `appearance.heightScale`, or `landscapeHeightScale` in landscape, within 0.7–1.5.
  - Live preview while dragging, written on release.
  - Done and Reset buttons.
- **Tablets and foldables** (`MediaQuery` width ≥ 600 dp):
  - Docked keyboard centred with a maximum width of 600 dp, or split when `modes.splitOnWideScreens` is on (section 4).
  - Folding or unfolding re-lays out without losing the composing text: the session and controller live above the frame, so just rebuild.
- **Landscape on phones:** the compact layout (section 4), and the keys keep a sensible maximum height.

### 2. Modes bar (`onModes` hook, which adds a "Keyboard modes" toolbar button)

Open a `KeyboardPanel` with `PanelPlacement.strip` and no `keyRedirect`, so the keys stay usable. It holds:
- One-handed left / right
- Floating
- Resize
- Close

Each is an icon button with a label and the selected state shown. Tapping applies the change through `settings.update` and closes the bar.

### 3. Space-bar cursor control and backspace swipe-delete

Both use the existing hooks, which Wave 1-A already calls after a horizontal drag starts on the key:
- `onSpaceDrag(dx, done:)`
- `onBackspaceDrag(dx, done:)`

- **Space drag** (`SwipeSettings.spaceCursorControl`):
  - Convert the total `dx` (dp) into cursor steps with acceleration: about 1 character per 12 dp when slow, up to 1 per 4 dp when fast. Track the speed from successive calls.
  - Apply only the difference since the last call through `session.input.moveCursor(delta)`, which finishes composing and sends DPAD events.
  - A light haptic tick every 1–2 steps (`HapticKind.repeatTick`, when haptics are on).
  - Vertical movement is ignored.
- **Backspace swipe-left** (`SwipeSettings.backspaceSwipeDelete`):
  - While dragging left, select whole words backwards from the cursor, one more word per ~24 dp, and highlight them in the editor with `editor.setSelection`. Get absolute offsets from `editor.getSurroundingText` (it returns `offset`), after `input.finishComposing()`.
  - Dragging back right shrinks the selection.
  - On release: delete the selection (`editor.commitText('')`), call `input.resyncAfterExternalEdit()`, and show an undo chip (`StripChip(id: 'editing.undo_delete', label: 'Undo', icon: Icons.undo, expiresAfter: 5 s)`). Undo re-inserts the deleted text with `insertText` and restores the cursor.
  - Releasing with zero words selected restores the original selection and does nothing.
  - Never in password or raw fields; the hook isn't called there anyway. Never log the deleted text.

### 4. Layouts (`layout_engine.dart`, `assets/layouts/`)

- **Emoji key in the bottom row:** add a `KeyType.emoji` key to the letters layouts (`qwerty`) and to `symbols`, between ?123 and the comma, about 1 unit wide, taking the width from space.
  - Email and URL variants keep their @ / .com keys; there, the emoji key moves to a long-press on the comma or @ key, or is dropped. Choose one and explain it.
  - The key's icon is painted by the existing painter (check `KeysPainter` handles `KeyType.emoji`; if it doesn't, report it rather than editing the painter).
  - Wave 2-D's `onEmoji` hook opens the panel.
- **Split layout** for wide screens: an engine option `split: true` that divides each letters row at its middle (by units) with a central gap of about 20% of the width. Space splits into two halves that both type a space. Character keys keep their spatial geometry for the predictor and decoder: `toGeometry` keeps working.
- **Compact landscape:** an engine option that caps the key height at 44 dp in landscape on phones (`smallestScreenWidthDp` < 600) and narrows the side padding.
- **Tests:** existing layout tests stay green, plus tests for split geometry (no overlaps, the gap, hit-test into both halves) and the emoji key placement in each field variant.

## Tests

- Frame: docked unchanged (window height and full width); one-handed width and side and the swap/expand buttons; floating layout message and rect, dragging and snapping and clamping after rotation; the height handle writes the scale on release; the tablet max width.
- Space drag: steps for slow and fast drags, deltas only, `moveCursor` calls (fake editor).
- Backspace swipe: words selected for given `dx`, delete on release, undo chip restores the text, zero-word release does nothing.
- Modes bar: each button writes the right setting.
- Use `test/keyboard/support/app_harness.dart` with `features: [createModesFeature()]` (see `test/keyboard/seams_test.dart`).

## Report extras

- What to check on the emulator: one-handed both sides, floating drag and touch pass-through to the app behind, resize, the cursor drag in the testbed, and backspace swipe plus undo.
- Anything the Kotlin side does differently from what you expected in floating mode. The orchestrator owns `MynaImeService.kt`, so report it rather than editing it.
