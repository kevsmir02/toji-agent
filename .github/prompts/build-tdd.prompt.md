---
description: Iron Law TDD — delegates to the test-driven-development skill. Explicit shorthand for triggering the strict Red-Green-Refactor cycle. Use this or /build — both now enforce TDD identically.
---

This prompt delegates entirely to the **`test-driven-development` core skill**. It is now an explicit shorthand — standard `/build` enforces TDD identically.

## What happens when you run /build-tdd

1. **Silently read** `.github/skills/test-driven-development/SKILL.md` — internalize the Iron Law, the Delete Rule, the runner detection logic, and the enforcement table.
2. **Load context** — Read `docs/ai/features/{name}.md` and any testing companions in `docs/ai/testing/`. Parse acceptance criteria into behavior slices.
3. **Execute per slice** — Red (failing test + observed failure output) → Green (minimum implementation to pass) → Refactor (clean up with all tests green).
4. **Delete Rule checkpoint** — If any production code for a slice was written before its failing test existed, delete that code and restart from Red.
5. **Regression gate** — Full suite green. Flag any test edited to match implementation (spec drift — escalate to user).
6. **What changed** — ≥3 bullets: tests added and what they encode, production code added, any refactor tradeoffs.
7. **Handoff** — `/verify` (two-stage), then `/review`.
