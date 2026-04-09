---
name: finishing-work
description: "Structured post-implementation workflow — verify, decide integration method, and clean up Physical Memory. Triggers after all tasks are marked [x] and before session ends. Enforces test verification before any merge/push decision."
globs: []
---

# Finishing Work

This skill governs what happens after all implementation tasks are complete. The work is not finished when the last task is checked. It is finished when this workflow completes.

## When to trigger

Trigger this skill when:
- All tasks in `.agent/task.md` are marked `[x]`
- The user says "we're done", "wrap it up", "finish this off", or similar
- You are about to claim a mission is complete

---

## Step 1: Test Suite Verification (mandatory, non-optional)

Before any integration decision, run the full test suite.

```
<test runner command for this project>
```

**Rules:**
- You may not proceed to Step 2 with any failing test.
- If tests fail: return to implementation. This skill pauses until all tests pass.
- If no tests exist: state this explicitly and ask the user whether to write them before integration.

Show the test output. Do not summarize it.

---

## Step 2: Present Integration Options (mandatory)

After tests pass, present exactly these four options. Do not pre-select one.

```
## Work is complete. How do you want to integrate?

**Option 1 — Merge to main locally**
Merge the current branch into main in the local repository.
No push. Local only.

**Option 2 — Push branch + open PR**
Push the current branch to origin and open a pull request.
Requires a PR title and description.

**Option 3 — Keep branch as-is**
Leave the branch exactly as it is. No merge, no push.
Return here when ready to integrate.

**Option 4 — Discard**
Delete the branch and all work on it.
To confirm, type the word: discard
```

Wait for the user's response before proceeding. Do not guess or default.

---

## Step 3: Execute Integration Choice

**Option 1 — Merge locally**
1. Confirm the target branch (default: `main`)
2. Run `git merge <branch> --no-ff` on the target branch
3. Confirm merge completed successfully (show git log --oneline -3)

**Option 2 — Push + PR**
1. Run `git push origin <branch>`
2. Show the PR creation command or URL
3. Draft a PR description using the feature brief from `docs/ai/features/`
4. If no feature brief exists, use the mission header from `.agent/implementation_plan.md`

**Option 3 — Keep as-is**
1. State the branch name for reference
2. Note any follow-up actions the user mentioned
3. Proceed to Step 4 (Physical Memory cleanup still applies)

**Option 4 — Discard**
1. You must receive the literal word "discard" in the user response before proceeding.
2. If confirmed: `git branch -D <branch>` (or stash deletion equivalent)
3. Warn that this is irreversible before executing.

---

## Step 4: Physical Memory Cleanup (mandatory)

After integration is resolved (any option), delete Physical Memory files:

1. Delete `.agent/task.md`
2. Delete `.agent/implementation_plan.md`

These files should not persist after a mission is complete. They represent in-progress state, not historical record.

If a feature brief exists in `docs/ai/features/`, it stays — that is Canonical, not Physical Memory.

---

## Step 5: Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
