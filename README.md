<p align="center">
  <img src="docs/showcase/hero.png" alt="IncogBoard: the keyboard that cannot phone home" width="100%">
</p>

<p align="center">
  <a href="https://github.com/appdevoplab/incogboard/releases/latest/download/app-arm64-v8a-foss-release.apk"><img alt="Download APK" src="https://img.shields.io/badge/Download-APK-6E8BFF?style=for-the-badge&logo=android&logoColor=white&labelColor=17141F"></a>
  <a href="https://apps.obtainium.imranr.dev/redirect?r=obtainium://add/https://github.com/appdevoplab/incogboard"><img alt="Get it on Obtainium" src="https://img.shields.io/badge/Obtainium-auto%20updates-17141F?style=for-the-badge&labelColor=2A2438"></a>
  <a href="https://github.com/appdevoplab/incogboard/releases"><img alt="All releases" src="https://img.shields.io/github/v/release/appdevoplab/incogboard?style=for-the-badge&label=release&color=2A2438"></a>
  <a href="LICENSE"><img alt="GPL-3.0" src="https://img.shields.io/badge/license-GPL--3.0-2A2438?style=for-the-badge"></a>
</p>

<h3 align="center">Your keyboard sees everything you type.<br>This one has no way to tell anyone.</h3>

Every keyboard on Android sees your passwords, your messages and your searches. Android even warns you about it
when you turn a new keyboard on. **IncogBoard asks for no internet permission at all**, so there is no code path that
could send what you type anywhere. Predictions, swipe typing, voice typing and translation all run on your phone.

It is free, open source (GPL-3.0) and built so you can check that claim yourself.

## Install

1. Tap **Download APK** above on your phone (most phones need `arm64-v8a`; older ones `armeabi-v7a`; all files are on the
   [releases page](https://github.com/appdevoplab/incogboard/releases)).
2. Open the file and allow the install.
3. Open IncogBoard: a six-step setup turns it on, picks your languages and lets you try it.

Want updates without an app store? Add the repository to [Obtainium](https://github.com/ImranR98/Obtainium) with the
badge above. Google Play and F-Droid listings are being prepared.

Optional **packs** (voice, translation, Chinese and Japanese dictionaries) are separate signed files on the
releases page. Get them without IncogBoard ever going online: in *Settings → Voice → Model packs* (or the **Get**
button in the keyboard), **Download** opens the pack in your browser, and **Import** installs the file. Packs hold
data only, never code, and are checked against the release key on your phone before they are installed.

## Why IncogBoard

| | A typical cloud keyboard | IncogBoard |
|---|---|---|
| Internet permission | Yes | **No** (CI fails the build if one appears) |
| Where predictions run | Often on a server | On your phone |
| Voice typing | Usually sent to a server | Whisper, on your phone |
| Translation | Online | Offline packs |
| What it learns | Stored and often synced | Encrypted with a key in Android Keystore, never synced, never in password or incognito fields |
| Source code | Closed | GPL-3.0, here |

## See it in action

<table>
  <tr>
    <td align="center" width="25%"><img src="docs/showcase/gif/swipe-typing.gif" alt="Swipe typing" width="100%"><br><b>Swipe typing</b></td>
    <td align="center" width="25%"><img src="docs/showcase/gif/hindi-transliteration.gif" alt="Hindi in English letters" width="100%"><br><b>Hindi in English letters</b></td>
    <td align="center" width="25%"><img src="docs/showcase/gif/japanese-flick.gif" alt="Japanese flick input" width="100%"><br><b>Japanese flick input</b></td>
    <td align="center" width="25%"><img src="docs/showcase/gif/translate.gif" alt="Offline translation" width="100%"><br><b>Offline translation</b></td>
  </tr>
</table>

## Every feature

### Privacy you can check

<table>
  <tr>
    <td width="33%"><img src="docs/showcase/01-no-internet.png" alt="No internet permission"></td>
    <td width="33%"><img src="docs/showcase/17-privacy.png" alt="See what is stored"></td>
    <td width="33%"><img src="docs/showcase/18-incognito.png" alt="Incognito and hide from screenshots"></td>
  </tr>
  <tr>
    <td width="33%"><img src="docs/showcase/20-app-lock.png" alt="App lock and shortcuts"></td>
    <td width="33%"><img src="docs/showcase/19-packs.png" alt="Signed data packs"></td>
    <td width="33%"><img src="docs/showcase/16-languages.png" alt="Pick your languages"></td>
  </tr>
</table>

- **No internet permission.** Release builds are checked by `tool/check_release_permissions.sh` in CI.
- **Encrypted on the phone.** Learned words, phrases and clipboard history are encrypted with a key held in Android
  Keystore. Nothing is backed up to the cloud; you can make an encrypted backup file yourself.
- **Incognito.** Nothing is learned in password fields, in browser incognito tabs, or in apps you choose.
- **Hide from screenshots**, **app lock** with fingerprint or PIN, and a privacy screen that shows the size of
  everything stored, never its contents.

### Typing

<table>
  <tr>
    <td width="33%"><img src="docs/showcase/02-swipe.png" alt="Type, swipe, predict"></td>
    <td width="33%"><img src="docs/showcase/03-toolbar.png" alt="Toolbar"></td>
    <td width="33%"><img src="docs/showcase/11-emoji.png" alt="Emoji search"></td>
  </tr>
  <tr>
    <td width="33%"><img src="docs/showcase/12-clipboard.png" alt="Clipboard history"></td>
    <td width="33%"><img src="docs/showcase/13-editing.png" alt="Text editing pad"></td>
    <td width="33%"><img src="docs/showcase/14-one-handed.png" alt="One-handed mode"></td>
  </tr>
</table>

Autocorrect, next-word prediction, swipe typing, emoji search in every language, clipboard history with pins,
a text-editing pad, personal shortcuts ("omw"), one-handed and floating modes, adjustable height, haptics and sounds.

### 18 languages

<table>
  <tr>
    <td width="33%"><img src="docs/showcase/04-hindi.png" alt="Hindi"></td>
    <td width="33%"><img src="docs/showcase/05-chinese.png" alt="Chinese pinyin"></td>
    <td width="33%"><img src="docs/showcase/06-japanese.png" alt="Japanese flick"></td>
  </tr>
  <tr>
    <td width="33%"><img src="docs/showcase/07-arabic.png" alt="Arabic"></td>
    <td width="33%"><img src="docs/showcase/08-russian.png" alt="Russian"></td>
    <td width="33%"><img src="docs/showcase/15-themes.png" alt="Themes"></td>
  </tr>
</table>

English, Spanish, French, German, Portuguese (Brazil and Portugal), Indonesian, Filipino (with Ñ, Taglish words
included), Hindi (Devanagari, InScript or
English letters, plus Hinglish), Marathi, Bengali, Tamil, Telugu, Arabic, Urdu, Russian, Ukrainian, Chinese
(Simplified, pinyin) and Japanese (12-key flick or romaji). Several can be on at once.

### Voice and translation, offline

<table>
  <tr>
    <td width="50%"><img src="docs/showcase/09-voice.png" alt="Voice typing"></td>
    <td width="50%"><img src="docs/showcase/10-translate.png" alt="Translate as you type"></td>
  </tr>
</table>

Voice typing uses Whisper through sherpa-onnx and recognises 17 languages, Filipino included. Audio stays in memory and is never saved.
Translation uses Opus-MT models in signed packs. English → Spanish is available now; more directions (French,
German, Portuguese, Hindi, Russian) are planned.

### Make it yours

Material You colours that follow your wallpaper, a gold preset, light, dark and pure black, three contrast levels,
and a theme editor with a live preview.

## Build it yourself

```powershell
flutter pub get
flutter test
flutter build apk --release --flavor foss --split-per-abi
```

Builds need a flavour: `foss` (GitHub and F-Droid) or `play` (Google Play, packs through Play asset delivery).
Without the release keys, release builds are signed with the debug key and are for testing only. The release steps
are in [docs/release/RELEASING.md](docs/release/RELEASING.md).

For development on an emulator:

```powershell
flutter build apk --debug --flavor foss
. .\tool\adb_ime.ps1; Install-IncogBoard; Enable-IncogBoard; Open-Testbed -Field text
```

Regenerate the platform contract after editing `pigeons/messages.dart`:

```powershell
dart run pigeon --input pigeons/messages.dart
```

On emulators with a hardware keyboard, allow the on-screen keyboard:
`adb shell settings put secure show_ime_with_hard_keyboard 1`.

### How it is built

```
IncogBoardImeService (Kotlin, thin)  --Pigeon-->  keyboardMain()  (Dart: keyboard UI + language engines)
SettingsActivity (Kotlin)            --Pigeon-->  main()          (Dart: settings app)
```

The whole keyboard UI and every language engine are Dart. Kotlin only hosts the Flutter engine, talks to Android's
InputConnection and Keystore, and keeps a native fallback so you can always switch keyboards.

### Privacy rules for contributors

- `tool/check_release_permissions.sh build/app/outputs/flutter-apk/*-release.apk` must pass (no network permissions).
- Never log typed text. Use `IncogBoardLog` with events, sizes and timings only.
- No dependency may contain network, analytics or Google Play Services code.

The README images are real emulator screenshots, framed by `python tool/brand/showcase.py`.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
