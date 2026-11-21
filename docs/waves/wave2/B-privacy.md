# Wave 2-B: privacy center, app lock, encrypted backup, personal shortcuts

Read `docs/waves/wave2/COMMON.md` first. Plan sections to read: "Privacy and security" (all of it), "Settings app, onboarding and privacy center".

## Ownership

**You own:**
- `lib/src/app/privacy/**`. Replace the stubs and keep `const PrivacyCenterScreen()` and `AppLockGate({required Widget child})`.
- `lib/src/security/**` (new): backup format, shortcuts store, wipe helpers.
- `lib/src/features/shortcuts/**`. Keep `createShortcutsFeature()`, which `keyboard_main.dart` calls.
- **Kotlin:**
  - `android/app/src/main/kotlin/app/myna/keyboard/security/backup/**` (new).
  - In `android/.../bridge/AppHostApiImpl.kt`, ONLY the "Backup files and crypto: Wave 2-B" section, meaning the six methods there.
  - JVM tests under `android/app/src/test/kotlin/app/myna/keyboard/security/backup/**`.
- `lib/src/settings/sections/privacy_settings.dart`: you may add optional fields.
- Tests: `test/app/privacy/**`, `test/security/**`, `test/features/shortcuts/**`.

**Read-only for you:**
- `lib/src/engine/learn/learned_data.dart` (the `LearnedData` codec; use `decode`, `encode`, `removeWord` and `blocked`).
- `SecureBlobStore`, `DataBlobs`, `DataSections`, `SeenAppsStore`, `AppServices`.
- The shared widgets in `lib/src/app/common/`.

## Build

### 1. Privacy center (`PrivacyCenterScreen`)

Use the shared `SettingsPage`/`SettingsGroup` widgets. Put a mascot slot at the top (Wave 2-A's `MynaMascot` is not available on your branch, so leave an `Icon` placeholder and note it in your report).

1. **Proof of no internet:**
   - Call `platform.hasInternetPermission()` live.
   - Release build: a green "Myna has no internet permission. It cannot send anything." card.
   - Debug build (`getAppInfo().isDebugBuild`): explain that it is for development tools only.
2. **What is stored:**
   - `platform.secureList()` shows each blob with a friendly name: learned words per language, clipboard, emoji recents, shortcuts, apps list.
   - Show each blob's size and last change, plus the custom theme files' size under `<dataDirectory>/themes`.
   - Never show contents here.
3. **Typing privacy:**
   - learning on/off (`privacy.learning`)
   - incognito toggle
   - hide-from-screenshots toggle, noting that password fields are always hidden
4. **Always-incognito apps:**
   - List `services.seenApps.list()` with each app's label, or its package name when there is no label. A switch per app writes `privacy.incognitoApps`.
   - Explain that the keyboard remembers app names only to fill this list, encrypted, never in incognito, and that the list can be wiped below.
   - Remove an entry with `seenApps.remove`.
   - Note: browser incognito tabs already turn learning off by themselves (`IME_FLAG_NO_PERSONALIZED_LEARNING`).
5. **Learned words** (app lock applies; use `setSecureScreen(true)` while shown):
   - Per language: read `DataBlobs.learned(lang)` with `LearnedData.decode`.
   - List the words (search, sort by score or A–Z). Remove a word, block a word ("never suggest"), or clear the language.
   - Write the blob back, then `notifyDataChanged([DataSections.learned])` so the keyboard reloads (`TextPredictor.reloadLearnedData`).
   - If the read returns null because the phone is locked or the key changed, show a clear message instead of an empty list.
6. **Personal shortcuts:** see section 4 below.
7. **Clipboard:** a link row to the Panels settings (Wave 2-A's route `MynaRoutes.panels`). Show the history size here too.
8. **App lock:** on/off and a timeout (immediately, 30 s, 1 min, 5 min). See section 2.
9. **Backup and restore:** see section 3.
10. **Wipe:**
    - Per category: learned words (all `learned_*` blobs), clipboard, emoji recents, shortcuts, apps list, custom themes (files).
    - Everything: `secureWipeAll()` also destroys the Keystore key, so the next write creates a new one, which rotates the key. It also deletes custom themes and resets settings to defaults if the user ticks that box.
    - Every wipe asks for confirmation with the exact list of what goes, and says it cannot be undone. After wiping, notify the right `DataSections` (`all` for everything).

### 2. App lock (`AppLockGate`)

- **When on** (`privacy.appLock`): ask on app start, and after the app was in the background longer than `appLockTimeoutSeconds`. Use `AppLifecycleListener`.
- **local_auth:**
  - Strong biometric or device credential (PIN/pattern/password): `biometricOnly: false`, with sticky auth.
  - Read the local_auth 3.x API in the pub cache before you use it; it changed from 2.x.
  - `SettingsActivity` is already a `FlutterFragmentActivity`.
- **Locked screen:** the mascot slot, "Myna is locked", and an Unlock button. No content behind it, and `setSecureScreen(true)` while locked.
- **Turning it on:** require one successful authentication first. If the device has no lock screen, explain that and leave it off.
- **Sensitive screens** (learned words, backup): `setSecureScreen(true)` on enter and `false` on leave, so there is no screenshot and no recents thumbnail.

### 3. Encrypted backup (`.mynabackup`)

**Kotlin** (`security/backup/`, called from the six `AppHostApiImpl` methods):
- **`sealBackup` / `openBackup`:**
  - Key derivation: PBKDF2-HMAC-SHA256 with 600,000 iterations and a 16-byte random salt, giving a 256-bit key.
  - Encryption: AES-256-GCM with a 12-byte random IV, and the header as AAD.
  - File layout: magic `MYNABK`, format version 1, KDF id, iterations, salt, IV, then ciphertext plus tag.
  - Wrong passphrase or tampering: return null. Newer version: throw code `unsupported_version`.
  - Zero the key and passphrase bytes after use.
  - Runs on Pigeon's background task queue.
- **`createDocument` / `openDocument`** (ACTION_CREATE_DOCUMENT / ACTION_OPEN_DOCUMENT):
  - Pigeon generates them as `suspend` functions on the main thread.
  - Register with `registerForActivityResult` in `AppHostApiImpl`'s `init`. It is constructed in `configureFlutterEngine`, which runs during `onCreate`, before the activity starts, so registering there is allowed.
  - You may change the constructor's `activity` parameter type to `androidx.activity.ComponentActivity`. `SettingsActivity` passes a `FlutterFragmentActivity`, so it needs no change.
  - Bridge the callback to the suspend function with `suspendCancellableCoroutine`. Allow only one picker at a time; a second call fails with code `busy`.
  - If you need anything else in `SettingsActivity`, describe it in your report. The orchestrator owns `SettingsActivity.kt`.
- **`writeDocument` / `readDocument`:** use the ContentResolver; enforce `maxBytes` (throw `too_large`).
- **JVM tests:**
  - round trip
  - wrong passphrase
  - tampered byte
  - header change
  - a fixed test vector
  - iteration count read from the header (tests may use a lower count through an internal parameter; production is always 600k)

**Dart** (`lib/src/security/backup/`):
- **Plain payload:** JSON with `format: 1`, `createdAt`, `appVersion` and `sections`.
- **Sections the user ticks:**
  - settings (all `MynaSettings` JSON)
  - learned words (every `learned_*` blob, base64)
  - shortcuts
  - clipboard: pinned items only, off by default
  - emoji recents
  - custom themes: files from `<dataDirectory>/themes`, images optional because they are large
- **Export flow:**
  1. Pick sections and see sizes.
  2. Enter the passphrase twice, with a strength meter and the warning that a lost passphrase cannot be recovered.
  3. `sealBackup`, then `createDocument("myna-YYYYMMDD.mynabackup")`, then `writeDocument`.
- **Import flow:**
  1. `openDocument`, then `readDocument` with a 64 MB cap.
  2. Ask for the passphrase, then `openBackup`.
  3. Validate the schema strictly: size caps per item, blob names must match the store's name rule, and theme file names cannot contain `..` or `/`.
  4. Preview counts ("1,240 learned words, 12 shortcuts, 2 themes").
  5. Choose Merge (learned: add counts, keeping the max of decayed scores; shortcuts: union; themes: add) or Replace.
  6. Write, then `notifyDataChanged([DataSections.all])`, and `settings.update` for the settings section.
- **Never log** passphrases, contents or file names.

### 4. Personal shortcuts

- **Store:** `DataBlobs.shortcuts`, JSON `[{trigger, expansion}]`.
  - Trigger: 1–32 characters, letters/digits/apostrophes, unique case-insensitively.
  - Expansion: up to 500 characters.
  - At most 500 shortcuts.
- **Editor** in the privacy center: add, edit, delete, search. Examples in the empty state: "omw → on my way", "addr → your address".
- **Keyboard feature** (`createShortcutsFeature()`):
  - In `attach`, load the shortcuts and add a `SuggestionDecorator` to `session.input.decorators`.
  - When `query.composing` equals a trigger (case-insensitive), put `Suggestion(expansion, kind: SuggestionKind.completion, display: expansion)` first. Keep the predictor's best word as the second item.
  - Multi-word expansions are never learned; the controller already handles that.
  - Reload on `DataSections.shortcuts` or `DataSections.all` (`session.services.events.settingsChanged`).
  - Off when your new `privacy.personalShortcuts` setting is false.
  - Decorators never run in password or no-suggestion fields.
  - Budget: under 0.2 ms per call. Use a map keyed by the lowercased trigger.

## Tests

- **Dart:**
  - backup payload round trip and strict validation (bad names, oversize, wrong format)
  - merge and replace logic
  - shortcuts store and the decorator (exact match, case, disabled setting)
  - the incognito apps screen with a fake `SeenAppsStore`
  - wipe calls the right deletes and notifications
  - `AppLockGate` with a fake authenticator: put a small interface around local_auth so tests can fake it
- **Kotlin:** the JVM tests listed above.

## Report extras

- The exact `.mynabackup` header layout.
- What the orchestrator must wire in `SettingsActivity` for the document pickers, if anything.
- Which flows need an emulator check: biometric prompt, SAF picker, FLAG_SECURE on the learned-words screen.
