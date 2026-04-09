---
description: "/review — Adversarial quality gate. Dispatches the code-reviewer agent. Single-shot pass/fail grading with zero tolerance. Explicit command only."
---

**Dispatch the code-reviewer agent from `.github/agents/code-reviewer.agent.md` to conduct this review.**

The code-reviewer agent persona applies: Senior Staff Engineer, adversarial, terse, no rubber-stamping.

**Single-shot:** Derive scope from `git status`, `git diff`, `docs/ai/features/`, and the user message. **No follow-up questions** — if context is ambiguous, state your assumptions and proceed.

## Review Protocol

1. **Gather Context (silent)** — Read the diff, identify the feature brief from `docs/ai/features/`, and note the scope tier.

2. **Grade on 5 Categories** — Evaluate every modified file against these categories. Assign each a score from 0-10:

### Category 1: Correctness (0-10)
- Does the code actually produce the correct result for all inputs?
- Are edge cases handled (null, empty, boundary values, concurrent access)?
- Are error paths tested and meaningful?
- Does it match the acceptance criteria in the feature brief?

### Category 2: Complexity (0-10)
- **Big-O analysis** of any loops, queries, or data transformations in hot paths.
- Flag anything O(n²) or worse that processes user-controlled input sizes.
- Flag N+1 query patterns.
- Is the code the simplest possible solution, or is it over-engineered?

### Category 3: Security (0-10)
- Cross-reference against `.github/skills/security/SKILL.md` OWASP Threat Matrix.
- Flag: unvalidated input, missing auth, raw SQL, hardcoded secrets, XSS vectors, mass assignment.
- Any finding here is automatically **blocking**.

### Category 4: Architecture (0-10)
- Does it follow existing project conventions and patterns?
- Proper separation of concerns (controllers don't contain business logic, etc.)?
- Are dependencies injected, not hardcoded?
- Is the code in the right file/layer?

### Category 5: Test Coverage (0-10)
- Were tests written before implementation (TDD compliance)?
- Do tests encode **behavior**, not implementation details?
- Are tests meaningful, or just line-count padding?
- Is the test-to-production code ratio reasonable?

3. **Calculate Verdict** — Average the 5 category scores:

| Average | Verdict | Meaning |
| :--- | :--- | :--- |
| 8.0-10.0 | **PASS** ✅ | Ship it. Proceed to `/pr`. |
| 6.0-7.9 | **CONDITIONAL PASS** ⚠️ | Fixable issues. List required changes, then re-run `/review`. |
| 0.0-5.9 | **FAIL** ❌ | Blocking issues. Return to `/build` and fix before re-review. |

## Output Format (mandatory)

```
## /review — Quality Gate

**Verdict: [PASS ✅ | CONDITIONAL PASS ⚠️ | FAIL ❌]**
**Score: [X.X / 10.0]**

| Category | Score | Notes |
|---|---|---|
| Correctness | X/10 | ... |
| Complexity | X/10 | ... |
| Security | X/10 | ... |
| Architecture | X/10 | ... |
| Test Coverage | X/10 | ... |

### Blocking Issues
- (file, line, issue, fix)

### Important Issues
- (file, line, issue, fix)

### Minor Issues
- (file, line, issue, recommendation)

### Next Step
→ [/build | /pr | specific action]
```

**Stop** after this block. Do not offer to fix things — the user will invoke `/build` themselves.
