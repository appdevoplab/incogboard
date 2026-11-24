# IncogBoard privacy policy

Last updated: <date of publication>. Applies to IncogBoard for Android, the keyboard and its settings app.

IncogBoard is a keyboard. A keyboard sees what you type, so this policy says plainly what happens to that. In short:
**IncogBoard does not send anything you type, say or copy off your phone, because it cannot connect to the internet.**

## 1. Who we are

IncogBoard is free software, licensed under the GNU General Public License v3.0 or later. It is developed by
the IncogBoard contributors. Contact: open an issue at https://github.com/appdevoplab/incogboard/issues (public; do not post
anything private there).

## 2. No network access

- IncogBoard does not request the internet permission, and the app contains no network code. The release
  builds are checked for this before every release.
- IncogBoard does not use analytics, advertising, crash reporting, or any service that collects data.
- IncogBoard has no accounts. There is nothing to sign up for or log in to.
- Because the app cannot connect to the internet, nothing you type, say, copy or store in IncogBoard is sent
  anywhere.

## 3. Permissions

| Permission | Why | When |
|---|---|---|
| Vibrate | Key feedback | Always, if you turn on haptics |
| Microphone (`RECORD_AUDIO`) | Offline voice typing | Asked the first time you tap the microphone key. Used only during a voice session you start |
| Biometrics (`USE_BIOMETRIC`, `USE_FINGERPRINT`) | Optional app lock | Only when you turn on app lock |

IncogBoard does not ask for contacts, location, photos or files as permissions. Photos you choose for a theme
background come through Android's photo picker, which hands IncogBoard only the picked image.

## 4. What is stored on your phone

All of it stays on the device, in the app's private storage that other apps cannot read.

- **Learned words, word combinations, personal shortcuts and the clipboard history** are encrypted with
  AES-256-GCM. The key lives in the Android Keystore, in secure hardware when the phone has it. The key can
  only be used while the device is unlocked, so these can be read only then. Writes are atomic.
- **The list of apps IncogBoard was used in** (package names and app names, never text) is encrypted in the same way.
  It is used to offer apps for the "always incognito" list.
- **Settings** (layout, themes, toggles, the incognito app list) are stored in a plain file in the app's private
  storage. They contain no typed text.
- **Themes and background photos** you create are stored in the app's private storage.
- **Model packs** you import (dictionaries, voice and translation models) are stored in the app's private
  storage. Each pack is checked against its signature before it is used.

IncogBoard keeps only what the features need. The clipboard history keeps text only, at most 30 items, and removes
items after an hour by default (you can change the time). Pinned items stay until you remove them. Copies that
Android marks as sensitive, such as passwords from password managers, are never stored.

## 5. Voice typing

When you start a voice session, IncogBoard records audio from the microphone and processes it on the phone with a
model you installed. The audio is held in memory during the session and is discarded afterwards. It is never
saved to a file, never uploaded, and never shared. A session ends when you stop it, cancel it, or after a
period of silence.

## 6. Sensitive fields

In password fields and in fields where the app asks for no personalised learning, IncogBoard does not show
suggestions, does not learn from what you type, does not show key pop-ups, and does not offer voice input.
Screenshots of the keyboard in those fields are blocked by the system.

## 7. Incognito

You can turn on incognito with a switch, and you can keep it on for chosen apps (for example banking apps).
While incognito is on, IncogBoard does not learn new words and does not record the app in its list. IncogBoard does not
detect private browser tabs by itself; use the switch or the app list for those.

## 8. Backups

IncogBoard does not back up to the cloud or to another device. The system's cloud backup and device transfer are
turned off for IncogBoard's data.

You can make a backup yourself, from the privacy centre. The backup is saved to a place you choose with
Android's file picker. It is encrypted with AES-256-GCM. The key is derived from a passphrase you choose
with PBKDF2-HMAC-SHA256 (600,000 iterations and a random salt). If you lose the passphrase, the backup cannot
be opened by anyone, including us.

## 9. Logs

Release builds do not write debug or information logs. IncogBoard logs events, sizes and timings, never what you
type, the words it knows, the names of the apps you use, or file paths. Logs stay on the phone and are never
sent anywhere.

## 10. Deleting your data

- In the privacy centre you can wipe everything, or one category at a time (learned words, clipboard history,
  recent emoji, shortcuts, the app list and imported packs). Wiping everything also destroys the encryption
  key, so no encrypted leftovers can be read afterwards.
- Uninstalling IncogBoard removes all of its data from the phone.
- IncogBoard holds no copy of your data anywhere else, so there is nothing for us to delete on request.

## 11. Children

IncogBoard is not directed at children and does not knowingly collect any information from anyone, children included.

## 12. Changes

If this policy changes, the new version is published with the release notes, and the date above changes.
Because IncogBoard does not connect to the internet, we cannot notify you on the phone; the release notes are the
notice.

## 13. Your choices

You can use IncogBoard without learning, without the clipboard history, without voice, without the app lock and
without backups. Each of these is a switch in the settings app.
