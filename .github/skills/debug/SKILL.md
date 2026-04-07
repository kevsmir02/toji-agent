---
name: debug
description: Evidence-first debugging with mandatory root-cause investigation before any fix, boundary logging in multi-component systems, and a three-attempt fix limit. Use when something is broken, a test fails, an error is thrown, or behavior diverges from the requirement. Do NOT use for refactoring or greenfield features.
globs: []
---

# Local Debugging Assistant — Iron Law of Debugging

Debug with evidence-first workflow. **No fix without proven root cause.**

## Hard rules (non-negotiable)

- **No speculative fixes** — You are forbidden from proposing or applying a code fix until Phase 1 (Root Cause Investigation) is complete and documented.
- **Three-attempt limit** — If **three** distinct fix attempts fail (same bug still reproduces or a new regression appears), you **must stop**. Acknowledge a possible **architectural or pattern failure**. Discuss fundamental design or approach changes with the user **before** any fourth attempt.
- **Approval after RCA** — After Phase 1, present findings and a fix hypothesis; do not modify production code until the user approves the plan (unless the user has already delegated full autonomy for this session — state that assumption explicitly if so).

---

## Phase 1: Root Cause Investigation (mandatory before any fix)

You are **forbidden** from proposing any code fix until you have completed all applicable items below.

### 1. Consistent reproduction

- Document **minimal, repeatable** reproduction steps (numbered, ordered).
- State **expected** vs **observed** behavior in one place.
- Confirm the failure is reproducible on demand (or document why it is intermittent and what triggers it).

### 2. Multi-component systems — boundary diagnostics

If the failure could involve more than one layer (e.g. API ↔ service ↔ DB ↔ queue ↔ frontend):

- You **must** add **diagnostic logging at component boundaries** (or use existing structured logs) to **prove where data or control flow breaks** — not guess.
- Log **entry/exit payloads or identifiers** (redact secrets) at each boundary until the first component that shows wrong or missing data is identified.
- Only after boundary evidence points to a single layer may you narrow the fix to that layer.

### 3. Trace data flow to the original trigger

- Trace the failing value or error **backward** from the symptom to the **original trigger** (user action, job, webhook, scheduled task, etc.).
- Document the chain: trigger → intermediate steps → failure point.

### 4. Phase 1 exit criteria

Phase 1 is complete only when you can answer:

- **Where** does correctness break (exact function, handler, or boundary)?
- **Why** does it break (root cause, not symptom)?
- **What** evidence proves it (repro steps + logs or traces)?

---

## Phase 2: Hypothesize and validate (after Phase 1)

- Each hypothesis must cite **Phase 1 evidence**.
- For each hypothesis: predicted evidence if true, disconfirming evidence if false, exact command or check.
- Prefer one-variable-at-a-time validation.

## Phase 3: Plan and fix (after user approval)

- Present fix options with risks and verification steps.
- Recommend one option; implement only after approval.
- After fix: confirm pre-fix signal is gone, post-fix behavior matches success criteria, run nearby regression checks.

---

## Session closure — Atomic Instinct (mandatory)

Use **`.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts** as the single source of truth for lesson capture and closure behavior.

- Do not duplicate or override lesson-capture criteria in this skill.
- On debug completion (fix landed or three-attempt stop), apply the global auto-capture rule in the same response as your final summary.

---

## Output template

Use this structure in order:

1. **Observed vs Expected**
2. **Reproduction steps** (minimal, numbered)
3. **Phase 1 — Root cause investigation**
   - Boundary diagnostic summary (or N/A for single-component)
   - Data-flow trace to original trigger
   - **Root cause statement** (one paragraph, evidence-backed)
4. **Hypotheses and tests** (if any remain after RCA)
5. **Fix proposal** (only after Phase 1 complete) — options, recommendation, risks
6. **Fix attempt count** — if this is attempt 4+, you must have explicit user sign-off on a new strategy
7. **Validation plan and results**
8. **Open questions**
