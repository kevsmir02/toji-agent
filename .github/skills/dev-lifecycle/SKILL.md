---
name: dev-lifecycle
description: Structured development workflow with sequential phases — requirements, design, planning, implementation, testing, and code review. Use when the user wants to build a feature end-to-end, or run any individual phase (new requirement, review requirements, review design, execute plan, check implementation, write tests, code review).
---

# Dev Lifecycle

Sequential phases producing docs in `docs/ai/`. Flow: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8.

## Phases

| # | Phase | Prompt | When |
|---|-------|--------|------|
| 1 | New Requirement | `/new-requirement` | User wants to add a feature |
| 2 | Review Requirements | `/review-requirements` | Requirements doc needs validation |
| 3 | Review Design | `/review-design` | Design doc needs validation |
| 4 | Execute Plan | `/execute-plan` | Ready to implement tasks |
| 5 | Check Implementation | `/check-implementation` | Verify code matches design |
| 6 | Write Tests | `/writing-test` | Add test coverage (100% target) |
| 7 | Code Review | `/code-review` | Final pre-push review |

## Starting a New Feature (Phase 1)

1. Ask for: feature name (kebab-case), problem description, target users, key user stories.
2. Create docs by copying the `README.md` template from each `docs/ai/` subdirectory:
   - `docs/ai/requirements/feature-{name}.md`
   - `docs/ai/design/feature-{name}.md`
   - `docs/ai/planning/feature-{name}.md`
   - `docs/ai/implementation/feature-{name}.md`
   - `docs/ai/testing/feature-{name}.md`
3. Fill the requirements doc: problem statement, goals/non-goals, user stories, success criteria, constraints, open questions.
4. Fill the design doc: architecture (mermaid diagram), data models, APIs, components, design decisions, security/performance.
5. Fill the planning doc: task breakdown, dependencies, effort estimates, implementation order, risks.
6. Proceed to Phase 2 (Review Requirements) → Phase 3 (Review Design).

## Resuming an Existing Feature

1. Check current branch: `git branch --show-current`
2. Locate the feature docs in `docs/ai/*/feature-{name}.md`
3. Check planning doc for task status to determine which phase to continue from
4. Run the appropriate phase prompt

## Backward Transitions

Not every phase moves forward. When a phase reveals problems, loop back:

- Phase 2 finds fundamental gaps → back to **Phase 1** to revise requirements
- Phase 3 finds requirements gaps → back to **Phase 2**
- Phase 5 finds major deviations → back to **Phase 3** (design wrong) or **Phase 4** (implementation wrong)
- Phase 6 tests reveal design flaws → back to **Phase 3**
- Phase 7 finds blocking issues → back to **Phase 4** (fix code) or **Phase 6** (add tests)

## Doc Convention

Feature docs: `docs/ai/{phase}/feature-{name}.md` (copy from `README.md` template in each directory).
Keep `{name}` aligned with the branch name `feature-{name}`.

## Rules

- Read existing `docs/ai/` before making changes. Keep diffs minimal.
- Use mermaid diagrams for architecture visuals.
- After each phase, summarize output and suggest the next phase.
