# Wave 2-A: settings app, onboarding and settings screens

Read `docs/waves/wave2/COMMON.md` first. Plan sections to read: "Settings app, onboarding and privacy center", "Typing feel", "Suggestions, autocorrect and learning", "Swipe", "Panels and modes", "Brand: Myna".

## Ownership

**You own:**
- `lib/src/app/**`, EXCEPT:
  - `app_services.dart` and `routes.dart`, which are contracts (read-only)
  - `privacy/**`, which belongs to Wave 2-B
  - `themes/**`, which belongs to Wave 2-C
- That means you own:
  - `app.dart`, which is yours to replace. Keep `const MynaSettingsApp()`; `main()` wraps it in `AppScope`.
  - `common/settings_widgets.dart`: restyle it freely, but keep every constructor and parameter, because B and C use them in parallel. You may ADD widgets there.
  - New folders: `shell/`, `onboarding/`, `screens/`, `about/`.
- Settings section files: you may add optional fields with defaults to `typing_settings.dart`, `feedback_settings.dart`, `swipe_settings.dart`, `language_settings.dart` and `voice_settings.dart`.
- `assets/notices/**` (licence texts for the About screen).
- `test/app/**`, EXCEPT `test/app/privacy/**` and `test/app/themes/**`.

**Others build in parallel:**
- B: privacy center, app lock, backup.
- C: theme gallery and editor.
- D: emoji, clipboard and editing panels.
- E: keyboard modes.

Link to B's and C's screens through the stubs that exist today: `PrivacyCenterScreen`, `AppLockGate({required child})` and `ThemeGalleryScreen`. Their real versions replace the stubs at merge, with the same names.

## Build

### 1. App shell

- **`MaterialApp`:**
  - Myna's brand theme: seed `mynaYellow` 0xFFF5B700, with the brown 0xFF3E2723 for emphasis.
  - Material You dynamic colour when available. `PlatformHostApi.getSystemColors()` gives the palettes; you may use `lib/src/theme/material_you.dart` read-only.
  - Light and dark, following the system.
- **Lock:** wrap the home in `AppLockGate`.
- **Routes:** map every `MynaRoutes` id to a screen.
  - Open the launch route from `services.app.takeLaunchRoute()` on start.
  - Listen to `services.routeRequests` while running; the keyboard's Themes button sends `themes`.
  - Unknown routes go home.
- **Settings reload:** `AppScope.of(context).settings` is a `ChangeNotifier`. Rebuild from it, so changes from the keyboard engine (its height handle, for example) show live.
- **Home:**
  - A large expressive header with the Myna mascot.
  - Setup status: a card while Myna isn't enabled or selected.
  - Section tiles: Languages, Typing, Feel, Themes, Panels, Voice, Privacy, About.
- **Mascot:** Wave 3-E draws the real artwork. For now build a `MynaMascot` widget in `onboarding/` (vector, `CustomPainter`): a geometric dark-brown myna with a yellow beak and eye patch, and a wing shaped like a keycap. Make it easy to swap later.

### 2. Onboarding (first run, and again from Home if setup is incomplete)

1. **Enable Myna.**
   - Explain the step, then deep-link with `openInputMethodSettings()`.
   - On resume, detect it with `isMynaEnabled()` (`AppLifecycleListener`).
2. **Switch to Myna.** Use `showInputMethodPicker()`, then detect it with `isMynaSelected()`. The picker returns focus without a resume event, so poll every 500 ms while this step is showing.
3. **"May collect your text" explainer.** Android warns that every keyboard may collect what you type. Explain why that doesn't apply to Myna:
   - It has no internet permission. Show `hasInternetPermission()` live, and say that debug builds have it for development only.
   - Everything stays on the phone, encrypted.
4. **Pick languages and a theme.**
   - Languages: today only English has a dictionary. List the planned ones as "coming soon" chips; they are wired in Wave 3.
   - Theme: show a compact preset picker, and link to `ThemeGalleryScreen` for more.
5. **Try it:** a test field and a short checklist (type, swipe, long-press for accents).
6. **Finish:** store `onboardingDone` in a settings section you own, for example `language_settings`.

- Use a progress indicator (wavy if `material_ui` has one) and back/next.
- Every step can be skipped once it is done.

### 3. Settings screens

Edit the existing `MynaSettings` fields; add new ones only to your own sections.

- **Languages & layouts:** enabled languages and the active one. Layout per language (qwerty only today). Multilingual typing switch.
- **Typing:**
  - autocorrect, auto-capitalise, double-space period, smart punctuation
  - suggestions, next-word prediction, emoji suggestions, block offensive words
  - key popups, long-press delay slider (150–1000 ms), number row, hint labels, lowercase labels
  - swipe: on/off, trail, trail width, fade, live preview, space-bar cursor control, backspace swipe-delete
- **Feel:**
  - haptics and strength (slider; the keyboard maps it)
  - sounds and volume
  - keyboard height for portrait and landscape: `appearance.heightScale` and `landscapeHeightScale`. These live in C's section file, but writing the values is fine.
  - one-handed default side and floating, from `ModeSettings` (E's section; values only)
- **Panels:** clipboard history on/off, expiry (15 min / 1 h / 1 day / 1 week), max items (`ClipboardSettings`, D's section; values only), recent-copy chip, emoji suggestions.
- **Voice:** a placeholder screen showing the `VoiceSettings` values, with "Offline voice arrives in a later update".
- **About:**
  - version (`getAppInfo()`) and the GPL-3.0 licence
  - a link to the source code. Show the URL as selectable text; there is no browser intent and no network.
  - licences: Flutter's `LicenseRegistry`, plus Myna's data licences. Copy the texts from `THIRD_PARTY_NOTICES.md` into `assets/notices/*.txt` and register them.

Every switch writes through `services.settings.update(...)` with the right section name, so the keyboard updates live. Debounce sliders: write on `onChangeEnd`. `SettingsSliderTile` already does this.

### 4. Look and feel

- **M3 Expressive:**
  - grouped containers: `SettingsGroup` with 24 dp outer corners and 6 dp inner corners
  - `SliverAppBar.large` headers
  - shape-morphing buttons where `material_ui` supports them
  - spring transitions between screens
- Respect "Remove animations" (`MediaQuery.disableAnimationsOf`).
- Make sure every screen works with TalkBack labels, in dark mode and at font scale 1.3.
- Optional: the `material_3_expressive` package only after a licence and code audit, and only as a report request, not a dependency.

## Tests

- Widget tests:
  - Navigation for every route, including a launch route and a route request.
  - Onboarding steps react to enabled/selected changes. Fake `AppHostApi` with mocktail.
  - Toggling a typing setting calls `settings.update` with the `typing` section.
  - Light and dark smoke builds.
- Build `AppServices` with `SettingsStore.memory()`, `InMemorySecureBlobStore()` and mocked host APIs.

## Report extras

Tell the orchestrator:
- which settings each screen writes
- anything you could not reach through the existing APIs
- screenshots the orchestrator should check on the emulator
