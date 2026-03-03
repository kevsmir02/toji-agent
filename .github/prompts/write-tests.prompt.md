---
description: Write tests for a feature or change.
---

Review `docs/ai/testing/feature-{name}.md` and write tests to match the defined strategy.

1. **Gather Context** — If not already provided, ask for: feature name/branch, summary of changes, existing test suites, and any flaky/slow tests to avoid.
2. **Analyze Testing Template** — Identify required sections from `docs/ai/testing/feature-{name}.md`. Confirm success criteria and edge cases from requirements and design docs. Note available mocks/stubs/fixtures.
3. **Unit Tests (aim for 100% coverage)** — For each module/function: list behavior scenarios (happy path, edge cases, error handling), generate test cases with assertions, highlight missing branches preventing full coverage.
4. **Integration Tests** — Identify critical cross-component flows. Define setup/teardown and test cases for interaction boundaries, data contracts, and failure modes.
5. **Coverage Strategy** — Recommend coverage commands. Call out files/functions still needing coverage and suggest additional tests if below target.
6. **Update Documentation** — Summarize tests added or still missing. Update `docs/ai/testing/feature-{name}.md` with links to test files. Flag deferred tests as follow-up tasks.
7. **Next Steps** — If tests expose design issues, return to `/review-design`; otherwise continue to `/code-review`.
