# Wave 1-D: Material 3 Expressive design system and keyboard themes

Read `docs/waves/wave1/COMMON.md` first. Plan sections to read: Themes (Material You Expressive), Brand: Myna, Your choices.

- Never use the `google_fonts` package, because it downloads fonts at runtime.
- Check what `material_ui` exports, for example `ColorScheme.fromSeed` with `dynamicSchemeVariant` and `contrastLevel`.

## Ownership

**You own:**
- `lib/src/design/**`
- `lib/src/theme/**`, EXCEPT `keyboard_theme_data.dart`. That file is the contract the keyboard view paints with; read it carefully and do not edit it.
- `assets/themes/**`, already declared in pubspec
- `assets/fonts/**`
- `test/theme/**`
- `docs/notices/themes.md`
- ONLY the `fonts:` block under `flutter:` in `pubspec.yaml`

Keep the signature of `resolveKeyboardTheme(...)` in `theme_resolver.dart`. It must stay synchronous.

**Context:**
- Wave 1-A is building the keyboard view in parallel. It calls `resolveKeyboardTheme` and paints `KeyboardThemeData`.
- The theme editor UI comes in Wave 2.

## Build

### 1. Design tokens (`lib/src/design/`)

Material 3 Expressive tokens:
- Shape scale (corner radii).
- Spring motion tokens: fast, default and slow springs for both spatial and effects motion, each as stiffness plus damping ratio. For example, fast spatial is about stiffness 800 with damping 0.6.
- Tonal and elevation levels.
- A type scale for key labels.

Also add small helpers, such as a WCAG contrast-ratio function.

### 2. Theme spec (`lib/src/theme/theme_spec.dart`)

An editable, versioned JSON model for presets and future custom themes, with these fields:
- id and name
- colour source: dynamic, seed or custom roles
- seed colour
- scheme variant: tonalSpot, vibrant, expressive, fidelity, monochrome, and so on
- key shape: radius factor from 0 to 0.5
- borders and key gap
- font family, weight and roundness
- label scale and hints
- background: solid, gradient, or an image path with blur and dim
- popup and trail overrides
- motion intensity

Include migrations for future versions, and document the JSON in `assets/themes/README.txt`.

### 3. Presets

Define the presets in Dart so resolution stays synchronous, with a JSON round-trip:
- **myna_dynamic:** Material You colours from the wallpaper on Android 12+. Falls back to the brand seed.
- **myna_gold:** the brand look, taken from the Myna mascot icon. Warm yellow primary (about #F5B700) with dark-brown accents (about #3E2723).
- **lavender, ocean, mint, coral, rose.**
- **graphite:** monochrome.

Each preset must work in:
- light and dark
- pure black (`AppearanceSettings.pureBlack`): a true-black background with near-black keys
- standard, medium and high contrast (`ColorScheme.fromSeed` `contrastLevel` 0, 0.5 and 1.0)

### 4. Material You mapping

Build light and dark `ColorScheme`s from `SystemColorsMessage.palettes`.

**Input:** 5 palettes (accent1, accent2, accent3, neutral1, neutral2) × 13 Android tones (0, 10, 50, 100, 200, …, 1000). Android tone N ≈ M3 tone 100 − N/10.

**Use the M3 baseline role mapping:**
- primary = accent1 600 (light) / 200 (dark); onPrimary = 0 / 800; primaryContainer = 100 / 700
- secondary from accent2
- tertiary from accent3
- surfaces and `surfaceContainer*` from neutral1
- outline and `outlineVariant` from neutral2

If the palettes are missing or invalid, fall back to the seed colour.

### 5. `resolveKeyboardTheme`

**Inputs:** `appearance`, `systemColors`, `systemDark` and `disableAnimations`.

**Selection:**
- Pick the preset by `AppearanceSettings.themeId`. An unknown id falls back to myna_dynamic.
- Apply the dark-mode preference, pure black and contrast.

**Map the result to `KeyboardThemeData`:**

| Element | Value |
|---|---|
| Background | surfaceContainer |
| Letter keys | surfaceContainerHighest |
| Function keys | secondaryContainer |
| Action key | primary |
| Space key | its own fill |
| Popups | primaryContainer |
| Suggestion colours | set to match the scheme |
| Trail | primary → tertiary |
| `keyCornerRadius` | 0.5 (pill) by default |
| `keyGap` | about 6 |
| `fontFamily` | `'GoogleSansFlex'` |
| `labelFontVariations` | `wght` from `labelWeight`; `ROND` roundness tied to the key shape |
| Motion | from your tokens, with `enabled = !disableAnimations` |

**Contrast:** every label/fill pair must meet WCAG 4.5:1, or 7:1 at high contrast. Enforce this in tests and adjust tones where needed.

**Performance:** keep resolution cheap by caching on the inputs.

### 6. Font

1. Download Google Sans Flex (SIL OFL 1.1; Google open-sourced it in November 2025) from an official source: `github.com/googlefonts/googlesans-flex`, or `github.com/google/fonts` under `ofl/`.
2. Verify the OFL licence file.
3. Add the variable TTF to `assets/fonts/` along with `OFL.txt`.
4. Declare the family `'GoogleSansFlex'` in the pubspec `fonts:` block.
5. Record it in `docs/notices/themes.md`.

If you can't get the official file, use Roboto Flex (also OFL) the same way and say so.

## Tests (`test/theme/`)

- Every preset × light/dark/pure-black × contrast level resolves and passes the contrast checks.
- Material You mapping from a synthetic palette gives the expected roles.
- JSON round-trip and migration work.
- `disableAnimations` turns motion off.
- An unknown `themeId` falls back.
