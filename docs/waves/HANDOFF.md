# Handoff: continue from here after /clear

State as of 2026-11-20 evening:
- Wave 0 is done.
- Wave 1 agents are running in git worktrees.

## Wave 1 agent branches

| Agent | Area | Brief | Branch / worktree |
|---|---|---|---|
| A | Keyboard view and input controller | `docs/waves/wave1/A-keyboard.md` | `worktree-agent-ac8c015e786297f8c` |
| B | Text engine (dictionary, autocorrect, learning) | `docs/waves/wave1/B-text-engine.md` | `worktree-agent-ac029b572bc20073e` |
| C | Gesture (swipe) typing | `docs/waves/wave1/C-gesture.md` | `worktree-agent-ae8c6008f8608dbc9` |
| D | Themes and design (Sonnet) | `docs/waves/wave1/D-themes.md` | `worktree-agent-a2c0d90e867cfe9f5` |
| E | Android platform layer (Sonnet) | `docs/waves/wave1/E-android.md` | `worktree-agent-ad19bb1c74a0797b9` |

The worktrees live in `.claude/worktrees/agent-<id>`. Agents commit early and often on their branch.

## Next steps

1. **Check progress of each branch:**
   - `git worktree list`
   - `git log --oneline main..<branch>`
   - `git -C <worktree> status --short`
2. **If an agent is still running**, wait. If it stopped unfinished:
   - Commit its leftover files on its branch.
   - Launch a fresh agent with `isolation: worktree`. Tell it to first `git merge <old-branch>`, then finish its brief file.
3. **Merge in order E, D, B, C, A** using the checklist in `docs/waves/README.md`:
   - Analyze, test, build.
   - Smoke-test on emulator-5554.
   - Run the release permission gate.
4. **Remove merged worktrees and branches:** `git worktree remove --force <path>` and `git branch -d <branch>`. The worktrees are locked, so unlock them first.
5. **Continue with Waves 2–5** from `docs/waves/README.md`. Write each brief as a file, then launch agents with a short prompt that points at it.

## Cautions

- A personal TECNO phone is connected over USB. Always set `$env:ANDROID_SERIAL='emulator-5554'`, and never install on the phone without asking.
- The emulator AVD is `Medium_Phone_API_37.0`. It needs `adb shell settings put secure show_ime_with_hard_keyboard 1` once.
- The usage limit hit once with 5 parallel Opus agents. Use Sonnet for routine agents.

## Open questions for the user

1. GitHub username, for `io.github.<username>.myna`. The current applicationId is the placeholder `app.myna.keyboard`.
2. Which extra Indian languages "Something else" meant. The default is gu/kn/ml/pa/or as follow-up packs.
3. Voice model size: bundled base (~60 MB) plus an optional small model?
