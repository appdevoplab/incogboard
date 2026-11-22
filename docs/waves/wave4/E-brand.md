# Wave 4-E: the Kosha brand (treasure-chest key)

Read `docs/waves/wave4/COMMON.md` first. Plan section: "Brand" (it describes a myna bird; **the user replaced it**: read the decisions below).

## The user's decisions (2026-11-22)

- **Name: Kosha**, from Sanskrit/Hindi *kosha*, "a treasury, a store of gold". The idea: your words are your treasure, kept with you, never sent away.
- **Icon:** a small, rounded **treasure chest whose lock is a keyboard key**, in gold on Material You colours. Bold, simple shapes, in the style of 2026 Material 3 Expressive icons.
- **No character mascot.** The chest itself has poses in place of the old myna bird: **open** (welcome, onboarding), **locked** (privacy, app lock), **glowing** (voice typing, translation, "working"), **closed and quiet** (incognito, empty states).

## Ownership

**You own:**
- `android/app/src/main/res/mipmap-*/**`, `res/mipmap-anydpi-v26/**` (new), the launcher and splash drawables in `res/drawable*/` (`launch_background.xml` and new `ic_*`/`splash_*` files; never `inline_chip_background.xml`), and the splash items in `res/values*/styles.xml` and `colors.xml` (keep `LaunchTheme`/`NormalTheme` and every existing item working). Add `res/values-v31/` for the Android 12+ SplashScreen API.
- `lib/src/app/onboarding/kosha_mascot.dart`: keep `KoshaMascot({size, label})` working everywhere it is used today, and add `pose` (an enum with `open`, `locked`, `glowing`, `quiet`; default `open`). Draw with a `CustomPainter` from the theme's colour scheme, so it follows Material You and dark mode.
- The brand colour constants in `lib/src/theme/presets.dart` (`koshaBrown`, `koshaYellow`, the `kosha_gold` preset) and `koshaBrandScheme` in `lib/src/app/shell/kosha_theme.dart`: retune them to the gold chest. Rename the constants only if you update every use in those two files; keep `koshaBrandScheme` and the preset ids.
- `assets/brand/**` (SVG sources), `docs/brand/**` (store graphics), `tool/brand/**` (render scripts).
- Tests: `test/app/brand/**`, `test/android/brand_resources_test.dart`.

Agent C localises screens at the same time. Do not change screen code beyond passing a `pose:` to existing `KoshaMascot(...)` calls. List the call sites and the pose each should use in your report, and the orchestrator applies them after the merge.

## Deliverables

1. **Adaptive launcher icon:** `mipmap-anydpi-v26/ic_launcher.xml` and `ic_launcher_round.xml` (the manifest has no `android:roundIcon` yet: ask for it in your report) with a foreground (the chest on a 108 dp canvas, art inside the 66 dp safe zone), a background (a gold or warm-neutral fill), and a **monochrome** layer for Android 13+ themed icons, designed first: the chest silhouette with the key as negative space. Legacy PNGs for every `mipmap-*dpi`. Check that it reads at 48 px, on light and dark wallpapers, and with circle, squircle and the M3 "cookie" masks (export a preview sheet to `docs/brand/icon-masks.png`).
2. **Splash:** the SplashScreen API on Android 12+ (`windowSplashScreenAnimatedIcon` = the chest foreground, `windowSplashScreenBackground` light and dark). The older `launch_background.xml` shows the same chest centred.
3. **In-app chest** (`KoshaMascot`): the four poses as vector drawings, crisp from 24 to 160 dp, with a subtle spring animation between poses (`AnimatedSwitcher` or an implicit tween; respect `MediaQuery.disableAnimations`). `label` stays the TalkBack text.
4. **Store graphics** (in `docs/brand/`, not shipped in the APK): Play icon 512×512 PNG (32-bit, no transparency at the edges), feature graphic 1024×500, and a store-screenshot frame template (SVG) with space for a caption.
5. **Sources:** every asset as SVG in `assets/brand/` (or `docs/brand/` for store-only art), plus `tool/brand/render.*`, which exports all PNGs. You may use dev-machine tools (for example a Python venv under `tool/brand/.venv`, git-ignored, or Inkscape if installed); the app gains no dependency.

All artwork is original; no third-party icons, fonts or clip art. The existing bundled font (Google Sans Flex, OFL) may be used for a wordmark.

## Tests

- The four poses build at sizes 24, 48, 96 and 160 in light and dark, at font scale 1.3, with the semantics label, and nothing overflows.
- `brand_resources_test.dart`: every `mipmap-*dpi` has `ic_launcher.png` of the right pixel size; the adaptive XMLs reference existing drawables with a `<monochrome>` layer; `values-v31/styles.xml` sets the splash items; `AndroidManifest.xml`'s `android:icon` still resolves.

## Report extras

- The palette (hex values) and why; the files made; the `KoshaMascot` call sites with the pose for each.
- What to check on the emulator: the launcher icon with themed icons on and off, the splash in light and dark, onboarding and the privacy center with the new chest.
