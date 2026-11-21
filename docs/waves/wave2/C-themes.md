# Wave 2-C: theme gallery, theme editor, custom themes, keyboard preview

Read `docs/waves/wave2/COMMON.md` first. Plan sections to read: "Themes (Material You Expressive)", "Settings app, onboarding and privacy center".

## Ownership

**You own:**
- `lib/src/app/themes/**`. Replace the stub and keep `const ThemeGalleryScreen()`, which Wave 2-A links to.
- `lib/src/theme/**`, EXCEPT `keyboard_theme_data.dart` (contract). You take over Wave 1-D's area, so read its report gaps below.
  - The `resolveKeyboardTheme` signature is fixed, including the new optional `customThemesDirectory`. You implement what that parameter does.
- `lib/src/keyboard/preview/**` (new): a static keyboard preview for the settings app.
- `lib/src/settings/sections/appearance_settings.dart`: you may add optional fields.
- `assets/themes/**`.
- Tests: `test/theme/**`, `test/app/themes/**`, `test/keyboard/preview/**`.

**Read-only for you:**
- the keyboard's view code in `lib/src/keyboard/view/**` and `layout/**`, which you reuse for the preview
- `AppServices`, the shared settings widgets, and the keyboard's `KeyboardApp`

## Wave 1-D carry-over

- Custom themes could only be resolved through `resolveKeyboardThemeFromSpec`. Make them resolve by id; see section 3.
- Trail width and fade are not in `ThemeSpec`. They are `SwipeSettings.trailWidth` and `trailFadeMs`, and your editor writes those values. The trail colours (`trailStart`, `trailEnd`) are already theme data.
- Image backgrounds: the keyboard paints the image, then a black overlay at `backgroundImageDim` (see `_Background` in `keyboard_app.dart`). Label contrast must be computed against the image dimmed toward black; Wave 1-D already assumed that.

## Build

### 1. Theme gallery (`ThemeGalleryScreen`)

- **Layout:**
  - A large header.
  - An **M3 carousel** (`CarouselView` from `material_ui`, if present; check the package source) of the 8 presets, then "My themes", then a "Create theme" card.
  - Each card is a real rendered mini keyboard (section 4), not a picture.
- **Selecting a card:** write `appearance.themeId` through `settings.update(..., sections: ['appearance'])`. The keyboard engine updates live.
- **Controls on the screen:**
  - dark mode (system / light / dark)
  - pure black (for dark)
  - contrast (standard / medium / high)
  - "Myna Dynamic follows your wallpaper": shown only when `getSystemColors()` is non-null
- **My themes:** long-press or a menu to edit, duplicate, rename or delete. Deleting asks first, and falls back to the default if the theme is in use.
- **Try typing:** a field at the bottom. The real Myna keyboard appears there if it is the selected keyboard.

### 2. Theme editor

**Live preview:** the static keyboard preview at the top, sticky while scrolling, updating as values change (a debounced resolve is fine).

Controls, grouped:
- **Colours:**
  - Source: Material You dynamic, a seed colour (picker with presets plus HSV/hex), or custom per role. The roles are `themeRoleNames` in `theme_spec.dart`.
  - Scheme variant (tonal spot, vibrant, expressive, fidelity, …).
  - Contrast.
- **Keys:**
  - shape, a slider from pill to rounded to square, which drives `keyCornerRadius` and the font's ROND axis
  - borders on/off and width
  - key gap
  - font weight and size
  - hint labels: `TypingSettings.hintLabels`, A's section, values only
  - keyboard height: `appearance.heightScale`
- **Background:**
  - Solid, gradient (two or three stops and an angle), or photo.
  - **Photo:**
    1. Pick with `image_picker` (`ImageSource.gallery`). On Android it uses the system Photo Picker and needs no permission. Never request storage permission.
    2. Crop screen: pan and zoom inside a frame with the keyboard's aspect ratio (screen width × keyboard height).
    3. Blur slider: render the crop once with `dart:ui` (`PictureRecorder`, an `ImageFilter.blur` layer, `toImage`), and save a PNG at screen width ≤ 1440 px to `<dataDirectory>/themes/images/<themeId>.png`.
    4. Dim slider (0–0.8): stored in the spec and painted live by the keyboard, not baked into the image.
    5. Check the decoded size and reject anything that would produce more than 20 MP.
- **Popups and trail:** popup style, trail colours (theme), trail width and fade (`SwipeSettings` values), trail on/off.
- **Motion:** press-animation intensity (off / subtle / standard / bouncy), mapped to the motion tokens. "Remove animations" always wins.

Saving creates or updates a custom theme (section 3). Back without saving asks to discard. The name is required, up to 30 characters.

### 3. Custom themes storage and resolution (`lib/src/theme/custom/`)

- **Files:**
  - Spec: `<dataDirectory>/themes/<uuid>.json`, the versioned `ThemeSpec` JSON with migrations.
  - Images: `<dataDirectory>/themes/images/<uuid>.png`.
  - Theme id: `custom:<uuid>`.
  - Write atomically (temp file, then rename) and cap each spec at 64 KB.
  - The settings app gets `dataDirectory` from `platform.getDataDirectory()`; the keyboard has it as `KeyboardServices.dataDirectory`.
- **`resolveKeyboardTheme(..., customThemesDirectory:)`:** when `appearance.themeId` starts with `custom:`, read and parse `<dir>/<uuid>.json` synchronously.
  - This happens only when the appearance changes; the keyboard caches the result.
  - Keep a small parsed-spec cache keyed on the id plus the file's modified time.
  - A missing or broken file falls back to the default preset and logs (without the path).
  - The image path in `KeyboardThemeData.backgroundImagePath` must be absolute.
- **Live updates in the keyboard:** `KeyboardApp` re-resolves only when the `AppearanceSettings` object changes. So when you save a theme that is in use, also bump a new `appearance.customThemeRevision` int, which you add to `appearance_settings.dart`. Include the revision in your cache keys.
- **Tests:** round trip, migration, broken file fallback, revision bump, image path.

### 4. Keyboard preview (`lib/src/keyboard/preview/keyboard_preview.dart`)

- `KeyboardPreview({required KeyboardThemeData theme, required MynaSettings settings, String layoutId = 'qwerty', double? height, bool showStrip = true})`. It is static and non-interactive.
- Reuse the real painting:
  - `LayoutRepository` with `BundledPackRepository` to load the layout asset
  - `KeyboardLayoutEngine.layout`
  - `KeysPainter`, with a `KeyPressAnimator` and `KeyTextCache` from the view package
  - a strip mock showing three suggestion chips
  - the background, including gradient, image and dim
- Do not import `KeyboardSession` or anything that needs `ImeHostApi`. The settings engine has no IME host.
- Optionally animate a "press" on one key in the gallery hero card, respecting "Remove animations".
- Performance: a gallery card builds in under 4 ms. Cache layouts and themes.

## Tests

- Widget tests for the gallery: selecting a preset writes the theme id, and the dark/contrast controls work.
- Editor tests: change the seed, see the preview update; save a custom theme, see it in My themes and resolve it by id.
- Preview golden-free checks: it renders 26 letter keys and has no exceptions in light, dark and pure black.
- `resolveKeyboardTheme` with custom ids: valid, missing, broken, revision bump.
- The crop and blur pipeline on a small synthetic image (render to bytes, check the size).

## Report extras

- The custom theme JSON format and file layout, for the backup agent's follow-up.
- Performance: preview build time and custom theme resolve time.
- What to check on the emulator: the photo picker flow, a custom theme applied in the keyboard, and dim and contrast on a busy photo.
