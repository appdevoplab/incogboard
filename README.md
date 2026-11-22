# Kosha

A private, offline, multilingual keyboard for Android, built with Flutter.

- **Offline by design.** Release builds have no internet permission at all. CI fails the build if one appears.
- **Private.** Learned words, phrases and clipboard history are encrypted with a key held in the Android Keystore. Nothing is learned in password or incognito fields, and nothing is ever backed up to the cloud.
- **Swipe typing**, autocorrect and next-word prediction, all on the device.
- **Material You Expressive** themes with a theme editor.
- **Languages (planned):** English, Spanish, French, German, Portuguese, Indonesian, Hindi (Devanagari and typing in English letters), Marathi, Bengali, Tamil, Telugu, Arabic, Urdu, Russian, Ukrainian, Chinese (pinyin) and Japanese.

> Status: early development (Wave 0 foundation). See `docs/PARALLEL_WORK.md` for how the build is organised.

## Architecture in one picture

```
KoshaImeService (Kotlin, thin)  ──Pigeon──►  keyboardMain()  (Dart: keyboard UI + language engines)
SettingsActivity (Kotlin)      ──Pigeon──►  main()          (Dart: settings app)
```

The whole keyboard UI and every language engine are Dart. Kotlin only hosts the Flutter engine, talks to Android's InputConnection and Keystore, and keeps a native fallback so you can always switch keyboards.

## Build and run

```powershell
flutter pub get
flutter test
flutter build apk --debug
. .\tool\adb_ime.ps1; Install-Kosha; Enable-Kosha; Open-Testbed -Field text
```

Regenerate the platform contract after editing `pigeons/messages.dart`:

```powershell
dart run pigeon --input pigeons/messages.dart
```

On emulators with a hardware keyboard, allow the on-screen keyboard:
`adb shell settings put secure show_ime_with_hard_keyboard 1`.

## Privacy checks

- `tool/check_release_permissions.sh build/app/outputs/flutter-apk/*-release.apk` must pass (no network permissions).
- Never log typed text. Use `KoshaLog` with events, sizes and timings only.
- No dependency may contain network, analytics or Google Play Services code.

## License

GPL-3.0-or-later. See `LICENSE` and `THIRD_PARTY_NOTICES.md`.
