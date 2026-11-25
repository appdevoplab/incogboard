# Prompt for the next session

Paste this as the first message after `/clear`:

---

Continue the IncogBoard keyboard (C:\Users\kgnan\keyboard, branch main, public repo github.com/appdevoplab/incogboard). Read docs/waves/HANDOFF.md first ("Current state (2026-11-25)", then "Open" in that section), then the memory files incogboard-project and commit-attribution.

State: `origin/main` is at 7dc6ffb (release 1.2.0, build 3). GitHub releases v1.0.0, v1.1.0 and v1.2.0 (Latest, beta). v1.2.0 has the foss APKs, five packs (including the English-only Parakeet pack) and SHA256SUMS; the Download APK and Parakeet links were checked. Oceanblue is the only built-in theme and the default for new installs; existing users keep their saved theme.

Open items, ask me before anything that pushes, publishes, downloads or is public:
1. Ask me to try voice typing on my own phone (never install on it yourself): Whisper base with the pause fix, then Parakeet English. Ask how it feels and whether Auto-detect picks the wrong language.
2. The GitHub Contributors box still shows Claude. The cause is two closed Dependabot PR refs (pull/1 and pull/2) that git cannot delete; GitHub Support must remove them. Ask me whether the Support request has been sent.
3. Two "Oceanblue" entries on the phone and emulator (built-in and custom). Ask whether to delete the custom copy.
4. The gallery's wallpaper note still says "IncogBoard Dynamic". Ask whether to remove it.
5. Onboarding warning text in all ARBs: show me the proposed text first (see HANDOFF "Open work").
6. Wider sensitive-field retest on the emulator. No-suggestion fields keep swipe and emoji; passwords keep everything off.
7. Official trademark register searches: tell me what to search, I do them.
8. Whether HANDOFF, this prompt and README stay on GitHub. They are public from the pushes; ask me.
9. Play steps in docs/release/checklist.md.

Rules: commit as appdevoplab (noreply address) and never add Co-Authored-By or any Claude attribution lines. Builds need `--flavor foss|play`. Run the quality gate before each commit and fix what fails: `dart format --line-length 120` on lib test pigeons tool/audit (never plain `dart format .`; regenerate lib/l10n with `flutter gen-l10n`), `flutter analyze`, `flutter test`, `testFossDebugUnitTest`, `flutter build apk --release --flavor foss|play --split-per-abi`, then `bash tool/check_release_permissions.sh` on the `app-*-foss-release.apk` and `app-*-play-release.apk` files only. Launch a play release build on the emulator once after any dependency or proguard change. Emulator-5554 only (start it with `emulator -avd Medium_Phone_API_37.0 -port 5554` if needed); never install on a personal phone. Release builds trust only the release pack key; never print, copy or commit anything from %USERPROFILE%\.kosha\release. IncogBoard must never get the internet permission, and onnxruntime stays pinned at 1.28.0. Ask me before every push, release, download or anything public. Use parallel agents only if I ask. When something is a real decision, ask me with options and plain-language explanations first, and explain privacy clearly at every user-facing step. At the end update HANDOFF, this prompt, README and memory.
