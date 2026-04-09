---
name: verification-before-completion
description: "Passive core skill — blocks completion claims without fresh command output evidence. Fires before any 'Done', 'Working', or 'Should be fixed' claim. Applies to tests, builds, requirements, and agent-delegated tasks. No exceptions."
globs: []
---

# Verification Before Completion

This is a passive skill. It fires automatically before any claim that work is done, passing, or working.

## The Rule

You are **forbidden** from claiming a task is complete, a test is passing, or a bug is fixed without showing **fresh terminal output** captured in the current session as evidence.

"Should work", "probably passes", and "I'm confident" are not evidence. They are guesses.

---

## Anti-Rationalization

If you are thinking any of the following, stop and run the 5-step gate below.

| Thought | What it actually means |
| :--- | :--- |
| "It should work now" | You have not verified it. Run the command. |
| "I'm confident this is correct" | Confidence is not evidence. Run the command. |
| "The logic looks right" | Looking right and being right are different. Run the command. |
| "The linter passed, so it's fine" | Linting checks style, not behavior. Run the test. |
| "I tested it mentally" | Mental simulation is not a passing test suite. Run the command. |
| "The last run passed, and I only changed X" | Changes break things. Run the command again. |
| "The subagent confirmed it's done" | Subagent claims are also unverified until you run the command. |

---

## 5-Step Verification Gate

Before any completion claim, complete all five steps in order:

1. **Identify the verification command** — exact command, no paraphrasing (`npm test`, `composer test`, `go test ./...`, etc.)
2. **Run it** — execute the command in the terminal, in the current session
3. **Read the full output** — do not skim; look for failures, warnings, and exit codes
4. **Confirm success criteria** — all tests pass, build succeeds, no unexpected warnings
5. **Then** claim the task is complete — include the command and its output in your response

If any step fails, return to implementation. Do not claim partial completion.

---

## Scope

This gate applies to:

- **Test runs** — "tests pass" claims require fresh `npm test` / `pest` / `pytest` / `go test` output
- **Build verification** — "it builds" requires fresh `npm run build` / `tsc` / `cargo build` output
- **Requirement verification** — acceptance criteria are verified against running behavior, not code reading
- **Subagent delegation** — when a subagent returns DONE, run the verification command yourself before accepting
- **Bug fixes** — "bug is fixed" requires the bug-reproducing case to now pass

---

## Output Requirement

When completing a task, always include in your response:

```
### Verification Evidence
Command: <exact command run>
Output:
<actual terminal output, truncated to relevant lines>
Result: PASS / FAIL
```

If you cannot run the command (e.g. no terminal access, user-blocked), state this explicitly and mark the task as **Unverified** — do not mark it Done.

---

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
