---
description: Write tests for a feature or change.
---

Review `docs/ai/features/{name}.md` and `docs/ai/testing/{name}.md` when present, then write tests that match the defined strategy.

1. **Gather Context** — If not already provided, ask for: feature name/branch, summary of changes, existing test suites, and any flaky/slow tests to avoid.
2. **Detect the Test Runner** — Inspect project markers such as `tests/Pest.php`, `composer.json`, `phpunit.xml*`, `vitest.config.*`, `vite.config.*`, `package.json`, and the Active Stack Profile in `.github/copilot-instructions.md`.
	- If Pest is present, generate Laravel tests using Pest syntax (`it()`, `test()`, datasets, Laravel test helpers, `assertInertia` when relevant).
	- If Vitest is present, generate frontend tests using Vitest syntax (`describe`, `it`, `expect`, `vi`) and project file conventions like `*.test.ts(x)`.
	- If the Active Stack Profile or project markers indicate a MERN/React environment and Vitest is present, default to Vitest + React Testing Library style for components and hooks, use `vi.mock` for client dependencies, and keep file naming aligned with the repo convention such as `*.test.ts` or `*.test.tsx`.
	- In MERN environments, prefer Vitest for shared contract helpers, typed client adapters, and React-side integration seams when `tRPC`, `ts-rest`, or shared API types are involved.
	- If both are present, split backend and frontend coverage across the appropriate runners.
3. **Analyze the Feature Brief and Test Plan** — Use `docs/ai/features/{name}.md` as the default source of acceptance criteria, critical flows, and edge cases. If `docs/ai/testing/{name}.md` exists, treat it as the detailed strategy and fixture/mocking source.
4. **Write Tests (aim for 100% coverage of new/changed logic)** — For each changed module or flow: cover happy path, edge cases, validation, authorization, and failure handling. Highlight missing branches that still prevent full coverage.
5. **Integration Coverage** — Identify critical cross-component flows. Define setup/teardown and test cases for contracts, database boundaries, typed API clients, Inertia payloads when relevant, and failure modes.
6. **Coverage Strategy** — Recommend runner-specific commands and thresholds. Call out files/functions still needing coverage and suggest additional tests if below target.
7. **Update Documentation** — Summarize tests added or still missing. Update `docs/ai/testing/{name}.md` when it exists, or add a concise validation note back to `docs/ai/features/{name}.md`. Flag deferred tests as follow-up tasks.
8. **Next Steps** — If tests expose design issues, return to `/review-design`; otherwise continue to `/review`.
