---
name: test-driven-development
description: Iron Law TDD — mandatory Red-Green-Refactor for all code changes regardless of scope. Enforces failing test first, Delete Rule for premature implementation, and regression-green gate before handoff. Activate for ANY task that produces or modifies production code.
globs: ["**/*.ts","**/*.tsx","**/*.js","**/*.jsx","**/*.php","**/*.py","**/*.go","**/*.rb","**/*.java","**/*.cs","**/*.swift","**/*.kt","**/*.vue","**/*.blade.php"]
---

This skill governs all production code changes in this repository. There are no scope exceptions — Trivial, Small, Medium, and Large tasks all follow the Iron Law.

## Iron Law of TDD (Non-Optional)

### Red — Green — Refactor (strict order, always)

1. **Red:** Write **one** failing test that encodes a single requirement derived strictly from the spec or feature brief. Run the test suite and confirm it **fails for the expected reason** — the right assertion message, missing symbol, or expected behavior absence. A compile error caused by a missing *implementation* symbol is acceptable as the first Red; a typo in the test file is not.
2. **Green:** Write the **minimum** production code necessary to pass that one test — nothing more. Do not pre-implement adjacent behavior.
3. **Refactor:** With all tests green, clean up structure, names, and duplication. Do not add behavior in this phase — any new behavior requires a new Red.

You **must** complete the full Red phase (failing test + observed failure output) before **any** production code for that behavior exists in the working tree.

---

## The Delete Rule (mandatory, no exceptions)

If production code for a given behavior was written **before** a failing test exists for that behavior:

1. **Delete** those implementation lines entirely — revert exactly the premature code, not the whole file.
2. **Start the slice again from Red** — write the failing test, observe its failure, then implement.

> There is no "write tests retroactively to cover already-written code." The Delete Rule is the enforcement mechanism. Apply it every time.

---

## Anti-Rationalization

If you are thinking any of the following, stop and re-read the Iron Law above.

| Thought | What it actually means |
| :--- | :--- |
| "I'll write the tests after the implementation" | You are about to violate the Delete Rule. Delete the code and start from Red. |
| "This is too simple to need a test" | There is no simplicity exemption. All production code requires a failing test first. |
| "Deleting my implementation wastes hours of work" | Keeping untested code wastes more. Apply the Delete Rule. |
| "TDD is dogmatic — being pragmatic means adapting it" | Violating the letter of the rules is violating the spirit. There is no pragmatic variant. |
| "Tests already exist for this area — it's basically covered" | "Basically covered" is not a failing test for this specific behavior. Write the test. |
| "I'll verify it works first, then formalize the test" | There is no formalize-after variant. Tests come first. Start from Red. |
| "I'll write the test next (after this commit)" | It will not happen. Apply the Delete Rule now and start from Red. |
| "The test would just be testing the framework" | Write the test. If it fails, the framework is fine. If it passes trivially, move on. |

---

## Workflow

### 1. Identify behavior slices
Before writing anything, decompose the task into the smallest independently-testable behavior slices. Each slice gets its own Red-Green-Refactor cycle.

### 2. Detect the test runner
Inspect: `tests/Pest.php`, `composer.json`, `phpunit.xml*`, `vitest.config.*`, `jest.config.*`, `package.json`, `pyproject.toml`, `go.mod`. Follow this priority:
- **Pest** → use Pest syntax (`it()`, `test()`, datasets)
- **Vitest / Jest** → use Vitest/Jest + React Testing Library as appropriate
- **PHPUnit** → use PHPUnit
- **pytest / Go test / RSpec** → use the native runner for the detected stack
- Split backend/frontend slices across their respective runners when both exist

### 3. Red phase (per slice)
- Write the failing test derived **only** from the spec/brief — not from guessing the implementation.
- Run the test. Capture the **failure output** (assertion error, missing symbol, exit code).
- **Checkpoint:** No production code for this slice may exist before this checkpoint is confirmed.

### 4. Green phase
- Write the minimum implementation to make the failing test pass.
- Re-run the test; confirm it is now green.

### 5. Refactor phase
- Improve code structure with all tests green.
- Re-run full suite to confirm no regressions.
- Do not introduce new behavior here.

### 6. Repeat for every slice
Continue until every acceptance criterion in the feature brief has a passing test.

### 7. Regression gate
Run the **full test suite**. All tests must be green before handoff. Flag any test edited to match the implementation (signals spec drift — escalate to the user).

---

## Enforcement

| Violation | Required action |
| :--- | :--- |
| Claiming "tests written" without showing failing output before implementation | Redo from Red |
| Keeping premature implementation code | Apply Delete Rule: delete and restart the slice |
| Writing production code to make tests "less broken" without a clean Red | Delete and restart |
| Editing a test to match the implementation | Flag spec drift; escalate to user |

---

## Legacy Grace Period

When `/onboard` has established a **Line in the Sand**, this skill does **not** retroactively impose TDD on pre-baseline legacy code. Legacy files listed in `docs/ai/onboarding/legacy-baseline.md` may be read, documented, or lightly patched without a full TDD retrofit — **until** the user requests a significant modification to that file or feature area. At that point the changed lines enter normal Iron Law TDD.
