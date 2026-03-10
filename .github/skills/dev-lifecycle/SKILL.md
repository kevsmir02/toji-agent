---
name: dev-lifecycle
description: Structured development workflow with sequential phases and mandatory design gates before implementation. Use when the user wants to build a feature end-to-end, or run any individual phase (`/plan`, `/requirements`, `/review-plan`, `/design-db`, `/review-design`, `/build`, `/verify`, `/write-tests`, `/review`, `/pr`).
---

# Dev Lifecycle

Sequential phases producing docs in `docs/ai/`. The primary source of truth is `docs/ai/features/{name}.md`, with optional companion docs in `implementation/` and `testing/`.

## Phases

| # | Phase | Prompt | When |
|---|-------|--------|------|
| 1 | Create Feature Brief | `/plan` | User wants to add a feature |
| 1.5 | Requirements Discovery (Mandatory Design Gate) | `/requirements` | Immediately after `/plan` to uncover missing fields and hidden requirements |
| 2 | Review Problem & Plan | `/review-plan` | Feature brief and requirements discovery output need validation |
| 3 | Technical Design (Mandatory Design Gate) | `/design-db` + `/review-design` | Database architecture and technical design must be approved before coding |
| 4 | Execute Plan | `/build` | Only after Phase 3 gate is complete |
| 5 | Check Implementation | `/verify` | Verify code matches design |
| 6 | Write Tests | `/write-tests` | Add test coverage (100% target) |
| 7 | Code Review | `/review` | Final pre-push review |
| 8 | Draft PR | `/pr` | Summarize scope, risks, and testing for reviewers |

## Starting a New Feature (Phase 1)

1. Ask for: feature name (kebab-case), problem description, target users, key user stories.
2. Create `docs/ai/features/{name}.md` from `docs/ai/features/README.md`.
3. Add `docs/ai/implementation/{name}.md` and `docs/ai/testing/{name}.md` only when the feature needs extra depth.
4. Fill the feature brief: problem statement, goals/non-goals, user stories, architecture, data/contracts, design decisions, task breakdown, dependencies, risks, and success criteria.
5. Run Phase 1.5 (`/requirements`) as a mandatory gate before plan review.
6. Proceed to Phase 2 (`/review-plan`) and resolve all open requirements gaps.
7. Run Phase 3 (`/design-db` then `/review-design`) as a mandatory gate before implementation.

## Phase 1.5: Requirements Discovery (Mandatory)

Purpose: prevent missing requirements and messy data models before design or implementation.

1. Run an Interrogator-style interview focused on domain entities, lifecycle states, business rules, and edge cases.
2. Identify hidden or ambiguous data fields (required, optional, derived, sensitive, tenant-scoped, audit-related).
3. Record each missing field with: name, type, constraints, default behavior, source of truth, and validation rules.
4. Capture unresolved questions and explicitly block `/build` until answered or documented as assumptions.
5. Write updates back into `docs/ai/features/{name}.md` (and `docs/ai/implementation/{name}.md` if deeper data notes are needed).

Exit criteria:
- No unresolved high-impact data field gaps.
- Field-level assumptions are explicit and reviewable.

## Phase 3: Technical Design (Mandatory)

Purpose: enforce database architecture quality and a reviewed technical blueprint before coding.

Required steps:
1. Run `/design-db` to produce a database architecture review.
2. Ensure the review covers normalization strategy, entity boundaries, key constraints, indexing approach, and migration implications.
3. Produce a Mermaid.js ERD that reflects the proposed schema and relationships.
4. Run `/review-design` to validate architecture and implementation readiness.
5. Block `/build` until both database design and technical design review pass.

Exit criteria:
- Database architecture review is complete and accepted.
- Mermaid ERD is present and consistent with the data model.
- Open design risks are either resolved or explicitly accepted.

## Resuming an Existing Feature

1. Check current branch: `git branch --show-current`
2. Locate the feature brief at `docs/ai/features/{name}.md`
3. Check the `Delivery Plan` section for task status to determine which phase to continue from
4. Run the appropriate phase prompt

## Backward Transitions

Not every phase moves forward. When a phase reveals problems, loop back:

- Phase 1.5 finds major scope ambiguity → back to **Phase 1** to revise the feature brief
- Phase 2 finds unresolved field gaps → back to **Phase 1.5**
- Phase 3 finds requirements or data model gaps → back to **Phase 1.5** or **Phase 2**
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
- Treat Phase 1.5 and Phase 3 as hard gates; do not start `/build` before both pass.
- After each phase, summarize output and suggest the next phase.
