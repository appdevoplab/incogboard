# Wave 1-E: Android/Kotlin platform layer

Read `docs/waves/wave1/COMMON.md` first. Then read these plan sections:
- Architecture
- Privacy and security
- Panels and modes
- the special cases under Typing feel

Then read these files:
- all Kotlin under `android/app/src/main/kotlin/app/myna/keyboard/`
- `pigeons/messages.dart`, the contract (don't change it; request changes in your report)
- the manifests
- `android/app/build.gradle.kts`

The Android SDK is at `%ANDROID_HOME%`; `build-tools 36.0.0` includes aapt2.

## Ownership

You own `android/**`, with two exceptions:
- **Manifests:** you may only add attributes inside the existing `<service>` block of the main `AndroidManifest.xml`, and only if truly needed.
- **Generated code:** don't edit `Messages.g.kt`.

You may edit:
- `android/app/build.gradle.kts`
- `android/app/proguard-rules.pro` (create it)
- `res/xml/method.xml`
- `docs/notices/android.md`

## Build

### 1. Clipboard watcher

- Register `ClipboardManager.OnPrimaryClipChangedListener` for the service's lifetime, and unregister it in `onDestroy`.
- Forward text clips to `flutterApi.onClipboardChanged`, including `ClipDescription.timestamp` and `EXTRA_IS_SENSITIVE` (API 33+).
- Cap clips at 20k characters, and skip non-text or empty clips.

### 2. Feedback

**Haptics:**
- If `hapticStrength` ≈ 0.5 (the default), use `view.performHapticFeedback(KEYBOARD_TAP)`, which respects the system setting.
- Otherwise use `Vibrator`/`VibratorManager` with `VibrationEffect` predefined effects (TICK, CLICK, HEAVY_CLICK), or amplitude one-shots when `hasAmplitudeControl()`.
- Map `HapticKind` sensibly: `repeatTick` lighter, `keyLongPress` stronger, `error` as a double pulse.

**Sounds:** play key sounds only when the ringer mode is NORMAL, matching AOSP LatinIME.

### 3. Window modes (`onComputeInsets`)

**Docked:** content and visible insets sit at the keyboard top.

**Floating** (`WindowLayoutMessage` mode `FLOATING`, with `floatingRect` in dp):
- Set `contentTopInsets` = `visibleTopInsets` = view height, so the app does not resize.
- Set `touchableInsets` = `TOUCHABLE_INSETS_REGION`, with the floating rect in px.
- Make the window background transparent and give Flutter a transparent surface: recreate the FlutterView with `FlutterSurfaceView(context, true)` or a `FlutterTextureView` when switching to floating.
- Switch back to opaque when docked: detach/attach the engine, and avoid flicker.

### 4. IME navigation-bar contrast

On API 30+, set light or dark navigation-bar icons on the IME window based on night mode. A contract call for exact colours can come later; request it in your report.

### 5. Inline autofill (API 30+)

- Set `android:supportsInlineSuggestions="true"` in `res/xml/method.xml`.
- Implement `onCreateInlineSuggestionsRequest` with presentation specs for ~40 dp chips and M3-like `UiVersions` styles.
- In `onInlineSuggestionsResponse`, inflate the `InlineContentView`s into a native `HorizontalScrollView` overlay:
  - Position it at the rect from `setInlineSuggestionsArea`, converting dp to px.
  - Hide it when the area is null.
- Report counts via `flutterApi.onInlineSuggestionsChanged`, and clear the overlay when input finishes.

### 6. SecureStore hardening

- **Locked device or invalidated key:**
  - `read` returns null.
  - `write` throws a clear exception that Dart can catch.
- **Permanently invalidated key:** recreate it. The old data becomes unreadable by design.
- Keep the `.bak` fallback.
- Cap blob size at 16 MB.
- Make it testable by injecting the cipher/key provider.
- Add JVM unit tests under `android/app/src/test` (add `testImplementation junit`) for the file format, atomic replace, `.bak` recovery, name validation and wipe.

### 7. Robustness

- Guard every InputConnection call against null and exceptions, returning false or null.
- In `onTrimMemory`, at `TRIM_MEMORY_RUNNING_LOW` or above, also call `engine.systemChannel.sendMemoryPressureWarning()`.
- `onConfigurationChanged` re-applies the height.
- `onCreateInputView` can be called repeatedly without leaking views or listeners.
- The fallback overlay is readable in dark mode.
- Consider engine death and restart.

### 8. Release config

- R8/proguard rules strip `android.util.Log.d/v/i` in release (`-assumenosideeffects`), while keeping what Flutter and Pigeon need.
- Confirm the release build works and its APKs still request no `INTERNET` or `ACCESS_NETWORK_STATE`.

## Verify

Run all of these:
- `flutter build apk --debug`
- `flutter build apk --release --split-per-abi`, then run `bash tool/check_release_permissions.sh build/app/outputs/flutter-apk/*-release.apk` (or the aapt2 equivalent)
- `cd android; .\gradlew.bat :app:testDebugUnitTest`

Do not install anything on any device.
