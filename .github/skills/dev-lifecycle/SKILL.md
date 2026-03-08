---
name: dev-lifecycle
description: Structured development workflow with sequential phases — feature brief, design review, implementation, testing, code review, and PR prep. Use when the user wants to build a feature end-to-end, or run any individual phase (`/plan`, `/review-plan`, `/review-design`, `/build`, `/verify`, `/write-tests`, `/review`, `/pr`).
---

# Dev Lifecycle

Sequential phases producing docs in `docs/ai/`. The primary source of truth is `docs/ai/features/{name}.md`, with optional companion docs in `implementation/` and `testing/`.

## Phases

| # | Phase | Prompt | When |
|---|-------|--------|------|
| 1 | Create Feature Brief | `/plan` | User wants to add a feature |
| 2 | Review Problem & Plan | `/review-plan` | Feature brief needs validation |
| 3 | Review Design | `/review-design` | Design doc needs validation |
| 4 | Execute Plan | `/build` | Ready to implement tasks |
| 5 | Check Implementation | `/verify` | Verify code matches design |
| 6 | Write Tests | `/write-tests` | Add test coverage (100% target) |
| 7 | Code Review | `/review` | Final pre-push review |
| 8 | Draft PR | `/pr` | Summarize scope, risks, and testing for reviewers |

## Starting a New Feature (Phase 1)

1. Ask for: feature name (kebab-case), problem description, target users, key user stories.
2. Create `docs/ai/features/{name}.md` from `docs/ai/features/README.md`.
3. Add `docs/ai/implementation/{name}.md` and `docs/ai/testing/{name}.md` only when the feature needs extra depth.
4. Fill the feature brief: problem statement, goals/non-goals, user stories, architecture, data/contracts, design decisions, task breakdown, dependencies, risks, and success criteria.
5. Proceed to Phase 2 (`/review-plan`) → Phase 3 (`/review-design`).

## Resuming an Existing Feature

1. Check current branch: `git branch --show-current`
2. Locate the feature brief at `docs/ai/features/{name}.md`
3. Check the `Delivery Plan` section for task status to determine which phase to continue from
4. Run the appropriate phase prompt

## Backward Transitions

Not every phase moves forward. When a phase reveals problems, loop back:

- Phase 2 finds fundamental gaps → back to **Phase 1** to revise the feature brief
- Phase 3 finds requirements gaps → back to **Phase 2**
- Phase 5 finds major deviations → back to **Phase 3** (design wrong) or **Phase 4** (implementation wrong)
- Phase 6 tests reveal design flaws → back to **Phase 3**
- Phase 7 finds blocking issues → back to **Phase 4** (fix code) or **Phase 6** (add tests)

## Doc Convention

Primary feature doc: `docs/ai/features/{name}.md`.
Optional companion docs: `docs/ai/implementation/{name}.md` and `docs/ai/testing/{name}.md`.
Keep `{name}` aligned with the feature or branch name.

## Rules

- Read existing `docs/ai/` before making changes. Keep diffs minimal.
- Use mermaid diagrams for architecture visuals.
- After each phase, summarize output and suggest the next phase.
