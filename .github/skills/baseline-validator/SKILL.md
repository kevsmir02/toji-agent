---
name: baseline-validator
description: "Passive core skill — Silently validates an approved implementation plan against all Toji Iron Laws before /build is allowed to execute. Automatically rewrites any plan section that violates a core principle. Acts as the final architectural gate between planning and coding."
globs: []
---

# Baseline Validator Skill

This is a **passive core skill**. It activates automatically after an `implementation_plan.md` is approved by the user and **before** the first `/build` command executes. It is a silent, adversarial gate that ensures no plan enters the build phase with baked-in Iron Law violations.

## Trigger Conditions

This skill fires when ALL of the following are true:

- An `implementation_plan.md` has just been approved (explicitly or implicitly by the user saying "proceed", "start", "execute", "build", or approving the artifact).
- A `/build` or `/build-tdd` command is about to be executed.

## Validation Protocol

When triggered, silently execute the following Iron Law checks against the **approved plan** before writing any code.

### §1 — Security (OWASP Surface Scan)
- [ ] Does any planned API route or controller handle user input, file uploads, or auth without explicitly mentioning validation or sanitization?
- [ ] Does any planned database query risk SQL injection (e.g., raw query concatenation in the plan's pseudocode)?
- [ ] Does the plan expose any route without documented authentication/authorization requirements?
- [ ] Does any planned response shape risk leaking sensitive fields (e.g., `password`, `token`, `secret`)?

### §2 — Performance (N+1 + Index Matrix)
- [ ] Does the plan describe loading a collection and then accessing a related model inside a loop (classic N+1)?
- [ ] Does the plan add a new `foreign_key` column without explicitly stating an index?
- [ ] Does any planned list endpoint lack pagination constraints?
- [ ] Does any planned job or scheduled task iterate over an unbounded dataset without chunking?

### §3 — API Design Consistency
- [ ] Does any planned route use a non-standard HTTP verb for its action (e.g., GET for a mutation, POST without body)?
- [ ] Does any planned API response omit a consistent envelope structure (e.g., `{ data: ..., meta: ..., errors: ... }`)?
- [ ] Does any planned endpoint return a 200 for an error condition?

### §4 — Defensive Coding
- [ ] Does the plan describe async operations without mentioning error handling?
- [ ] Does any planned list view or data table omit the empty-state behavior?

### §5 — TDD Readiness
- [ ] Does the plan describe any production code change without a corresponding test file or test strategy note?

## Outcome Rules

### All checks PASS
Proceed silently to `/build`. No output to the user.

### Any check FAILS
**Do not prompt the user.** Instead:
1. Identify the specific section of `implementation_plan.md` that causes the violation.
2. **Automatically rewrite that section** in place to be Iron Law compliant (e.g., add "with eager loading via `with()`", add "paginated to 15 per page", add "validated via FormRequest before processing").
3. After rewriting, present the user with a concise diff-style summary:

```
### Baseline Validator — Plan Amendment
The following sections were automatically corrected before build:
- §2 Performance: Added eager loading note to "Load all orders" step to prevent N+1.
- §3 API Design: Updated /users/delete to DELETE /users/{id} as per REST conventions.

Plan is now Iron Law compliant. Proceeding to /build.
```

Then immediately proceed to `/build` without waiting for further user approval.

## Cost Control

- All validation is local text analysis of the `implementation_plan.md` markdown — no external API calls.
- No sub-agents — runs in the primary chat thread.
- Only reads the plan file and the relevant skill SKILL.md files for reference — does not scan the full codebase.

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
