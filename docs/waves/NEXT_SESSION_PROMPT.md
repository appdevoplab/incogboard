# Prompt for the next session

Paste this as the first message after `/clear`:

---

Continue the IncogBoard keyboard (C:\Users\kgnan\keyboard, branch main, nothing pushed). Read docs/waves/HANDOFF.md ("Do next", "Before the first store release", "Open work") and docs/waves/README.md first, then the memory file incogboard-project. Waves 0-5 are merged; there are no agent worktrees. Do the "Do next" steps in order: Pigeon wiring for pack Verify, an emulator retest of the foss release APK (emulator-5554 only; a personal phone may be attached, never install on it), the Play bundle wiring and local-testing run, then the audit patches that need no user decision. Run the quality gate (format, analyze, flutter test, JVM tests for `testFossDebugUnitTest`, `flutter build apk --release --flavor foss|play --split-per-abi`, then the permission gate in Git Bash) before each commit and fix what fails. Builds need `--flavor`. Release builds trust only the release pack key; never print, copy or commit anything from %USERPROFILE%\.kosha\release. Do not publish, push or create accounts. Use parallel agents only if I ask. Then update HANDOFF, README and memory, and ask me the open user decisions from HANDOFF (sensitive-field rule, restore confirmation, secure-store AAD, Play asset library, GitHub username) before changing behaviour that depends on them.
