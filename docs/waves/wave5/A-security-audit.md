# Wave 5-A: security audit, licence audit, CI hardening, name check

Read `docs/waves/wave5/COMMON.md` first. Plan section: "Privacy and security".

## Ownership

**You own:**
- `docs/security/**` (new): `threat-model.md`, `audit.md`, `SECURITY.md` content, `licences.md`.
- `SECURITY.md` at the repo root (vulnerability reporting policy; use "open a private security advisory on the project's GitHub repository" because the repository URL is not known yet).
- `.github/workflows/**` (pin every action to a full commit SHA with a version comment, least-privilege `permissions`, `persist-credentials: false`, concurrency, timeouts). Add `.github/dependabot.yml` for GitHub Actions, Gradle and pub updates (grouped, weekly).
- `tool/audit/**` (new): scripts for the licence and dependency audit (they read lockfiles and the Gradle cache; no network except to fetch licence texts or advisories on this dev machine).
- `docs/brand/trademark-check.md` (new; Part 3).
- Tests that pin the findings you fix inside files you own, under `test/security/**` (new names only).

**Findings in files you do not own** (Dart, Kotlin, manifests): do not edit them. List each with file, line, severity, why, and an exact patch in `docs/security/audit.md` and the report. The orchestrator applies them. Exception: you may fix a test you own.

## Part 1: threat model and security review

1. Write `docs/security/threat-model.md`. Assets: typed text, learned words and phrases, clipboard history, backups, voice audio, app list, themes and photos. Actors: other apps, a person holding an unlocked phone, a person with a stolen locked phone, a malicious `.koshapack` or `.koshabackup`, a malicious dictionary or model file, a malicious IME client (a text field that tries to read the keyboard's state), supply-chain compromise (a dependency, a pack, a CI action), and ourselves (an accidental log, an accidental permission). For each: what the defence is (with file references: `SecureBlobStore`, the Keystore alias `kosha.secure_store.v1`, `FLAG_SECURE`, app lock, pack signature check, backup crypto, `InputFieldInfo.isSensitive`, incognito, the release permission gate), what remains, and the residual risk.
2. Review the code. Run the `security-review` skill on the whole tree (not only a diff), then read the high-risk files yourself:
   - `android/app/src/main/kotlin/app/kosha/keyboard/**`: `packs/PackStore.kt` (signature verification, path traversal in the archive, size limits, the 64-file limit, zip-slip-style names, trailing data, symlinks), `security/backup/**` (PBKDF2 600k, AES-256-GCM, nonce reuse, header authentication, downgrade and magic handling, restore preview), the SAF import and export, the permission activity, the receivers and exported components, `FLAG_SECURE`, clipboard access, voice (microphone lifetime, buffers kept in memory only), the Keystore use (key invalidation, `setUserAuthenticationRequired`, what happens on a locked device).
   - `lib/src/security/**` and `lib/src/core/secure_blob_store*`: AAD binding of blob names, atomic writes, backup restore merge rules, shortcuts, the learned-data codecs (fuzz the decoders with truncated and corrupt input).
   - Parsers fed by files the user can import: `.koshapack` manifest JSON, dictionary files (`zh.kdict`, `japanese.lex.gz`, `japanese.conn.gz`, `.dat` emoji, translit tables): bounds checks, huge counts in headers (allocation bombs), gzip bombs, integer overflow in offsets. These are Dart, so memory-safe, but a crafted header can still hang or exhaust memory in the keyboard process. Write corrupt-file tests under `test/security/**` for each parser; report the ones that fail rather than patching code you do not own.
   - Logging: grep every `KoshaLog`, `Log.`, `debugPrint`, `print`, `Log.d/i/w/e` for typed text, words, candidates, app names, paths or URIs.
   - The manifest: exported components, `allowBackup`/`dataExtractionRules` (the app data must not go to Android cloud backup or device transfer: check `android:allowBackup`, `fullBackupContent`, `dataExtractionRules`), `usesCleartextTraffic`, `debuggable`, `networkSecurityConfig`, taskAffinity, intent filters.
   - Build: R8 and ProGuard keep rules, debug-only code in release (the testbed activity must not ship in release), `testOnly`, any `BuildConfig` secrets.
3. Fixes you may make yourself: only inside files you own. Everything else becomes a patch in the audit.

## Part 2: dependency, licence and CI audit

- **Licence audit.** Kosha is GPL-3.0-or-later. Build `docs/security/licences.md`: every Dart package (`pubspec.lock`), every Gradle dependency (resolve the release runtime classpath), every bundled native library (sherpa-onnx, onnxruntime, Flutter engine), every bundled data file (dictionaries, emoji, translit, fonts, layouts) with its licence, whether it is GPL-3.0-compatible, where the notice lives, and whether `THIRD_PARTY_NOTICES.md` and `assets/notices/third-party-data.txt` cover it. Flag: GPLv2-only, NC/ND, unclear, missing attribution, a licence text that is not shipped. Known open items to resolve or restate precisely: the IPAdic terms inside the Mozc dictionary (custom permissive licence with an ICOT clause, in the signed Japanese pack), the pt-BR word list (AOSP-derived), the Arabic list (CC BY 4.0 per HeliBoard, not checked at the source), Tatoeba CC BY 2.0 FR (test data only: confirm it is not shipped), the Google Sans Flex font (OFL), Whisper models (MIT), Opus-MT (CC-BY-4.0 / Apache). Say plainly which ones need the user's decision; do not give legal advice.
- **Dependency audit.** `tool/audit/` script that lists direct and transitive dependencies and checks them against OSV (https://osv.dev, query API, on the dev machine only) for known advisories. Report the result. No new runtime dependency.
- **Network audit.** Prove the no-network claim: a script that inspects the merged release manifest, every dependency AAR manifest and class list for `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `HttpURLConnection`, `okhttp`, `java.net.Socket`, telemetry and analytics packages, and prints what it finds. Extend `tool/check_release_permissions.sh` only if you also keep its current behaviour and exit codes (you may edit that file).
- **CI.** Rewrite `.github/workflows/ci.yml`: pin every action to a SHA, pin Flutter by version and the action by SHA, `permissions: contents: read`, no secrets, no `pull_request_target`, a job that runs the audit scripts and the permission gate, a job that fails if a `.jks`/`.keystore`/`.pem`/`.p12` or a file over 5 MB is added. Add a separate `codeql`-free supply-chain job only if it needs no new account. Do not add a release workflow (Agent B owns `.github/workflows/release.yml`; do not create that file).

## Part 3: trademark check of the name "Kosha"

Not legal advice; a first screen so the user can decide. Search on the public web and write `docs/brand/trademark-check.md` with, for each source, the query, the date, the result and a link:
- USPTO TESS/Trademark Search, EUIPO eSearch plus, WIPO Global Brand Database, India's IPIndia, UKIPO: live or pending marks for "Kosha" or close variants (Kosa, Cosha, Kosh, Koshi) in classes 9 (software), 42 (SaaS), 38 and 45; list the owner, status and goods.
- App stores and registries: Google Play, F-Droid, the Apple App Store, GitHub, pub.dev, npm, PyPI: apps or projects named Kosha, especially keyboards, input methods, privacy or finance/"treasury" apps.
- Domains and handles: kosha.app, kosha.dev, kosha.io, kosha.org, kosha.com status (registered or not), a GitHub organisation, a Mastodon handle. Do not register anything.
- Common-word risk: "kosha" is a real Sanskrit/Hindi/Bengali word and a Jewish dietary term variant ("kosher" is different), and "kosha" is a Hindu philosophy term (the five sheaths); note that descriptive or cultural meanings reduce but do not remove conflict risk.
End with a table (conflict, how close, risk low/medium/high) and a recommendation (keep the name, keep with a disambiguating tagline such as "Kosha Keyboard", or consider alternatives). Include the exact steps the user would take to file or to run a professional search. Do not file anything.

## Deliverables and done

- The four documents in `docs/security/`, `SECURITY.md`, the trademark note, the audit scripts, the hardened workflows, `dependabot.yml`, the corrupt-input tests.
- `docs/security/audit.md`: a table of findings (id, severity, file:line, description, patch or "fixed in <file>"), highest first, plus "no finding" for each area you reviewed so the user can see the coverage.
- Gate: format, analyze, test (your new tests included), and if a script needs a build, the release build and permission gate.
- Report: the top findings in order, which need the user's decision, and the patches for the orchestrator.
