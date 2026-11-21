# Third-party notices: Android platform layer (Wave 1-E)

## androidx.autofill:autofill 1.3.0

- Source: https://maven.google.com (group `androidx.autofill`, artifact `autofill`), code at https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/autofill/
- License: Apache License 2.0
- Used for: `UiVersions` / `InlineSuggestionUi` style builders, so password-manager inline autofill chips match Myna's strip (Android 11+).
- Contains pure UI helper classes and `Bundle` encoding only. No network code, no permissions, no native code.

## junit:junit 4.13.2 (unit tests only, never packaged in the APK)

- Source: https://github.com/junit-team/junit4
- License: Eclipse Public License 1.0
- Used for: JVM unit tests under `android/app/src/test`.
