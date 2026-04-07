---
name: dev-lifecycle
description: Scope classification and workflow routing — determines whether work is Trivial, Small, Medium, or Large, then maps it to the correct sequence of prompts and gates. Use when starting any new feature or task to decide how much process to apply. Do NOT apply this skill's full gate sequence to Trivial or Small work.
globs: ["**"]
---

# Dev Lifecycle

Scope-tiered workflow. Classify the work first, then apply the appropriate process level.

## Step 0: Classify Scope (Always Do This First)

Before starting any work, determine scope. **Infer** from the user message, `docs/ai/`, and git context; **at most one** blocking question if scope is genuinely ambiguous.

| Scope | Signals | Examples |
|---|---|---|
| **Trivial** | Single-file edit, no new entities, no schema changes, no new patterns | Bug fix, config tweak, copy change, CSS adjustment, dependency bump |
| **Small** | 1–3 files, no new domain entities, no schema changes | Add a helper function, new UI component, endpoint tweak, small refactor |
| **Medium** | New domain entity, new API endpoints, new UI flows, schema changes | New CRUD feature, user authentication, payment integration |
| **Large** | New subsystem, multi-entity schema, cross-cutting architecture, breaking changes | New module/service, database redesign, major migration, platform feature |

## Scope-Tiered Workflows

### Trivial (Fast Lane)
```
/build → done
```
*Operating Profile: Fast (Trivial scope)*
No planning docs. No gates. Skip clarification. Just implement directly and explain what changed. TDD Iron Law still applies.

### Small
```
/plan (lightweight) → /build → /verify
```
- `/plan` produces a short task list in the chat or a minimal feature brief — not a full doc unless the user asks for one.
- Skip `/requirements`, `/design-db`, and `/review-plan`.
- `/verify` is a quick sanity check, not a formal review.

### Medium
```
/plan → /requirements → /build → /verify → /write-tests → /review
```
- `/plan` produces `docs/ai/features/{name}.md`.
- `/requirements` runs a **one-response** coverage checklist on the new entities and contracts (see `requirements.prompt.md`).
- `/design-db` is **recommended** when schema changes are involved, but not a hard gate.
- `/review-plan` and `/review-design` are optional — use when the plan or design feels uncertain.

### Large
```
/plan → /requirements → /review-plan → /design-db → /review-design → /build → /verify → /write-tests → /review → /pr
```
- Full gate sequence. All steps are recommended.
- `/requirements` runs the full **one-response** coverage checklist (all topics answered in a single turn).
- `/design-db` is a hard gate — do not start `/build` until schema design passes.
- `/review-design` validates architecture readiness before coding.
- Companion docs (`docs/ai/implementation/{name}.md`, `docs/ai/testing/{name}.md`) are appropriate at this scope.

## Phase Reference

| Phase | Prompt | Required at scope |
|---|---|---|
| Plan | `/plan` | Small, Medium, Large |
| Requirements Discovery | `/requirements` | Medium, Large |
| Review Plan | `/review-plan` | Large |
| Database Design | `/design-db` | Large (recommended at Medium with schema changes) |
| Review Design | `/review-design` | Large |
| Build | `/build` or `/build-tdd` | All |
| Update Plan | `/update-plan` | Medium, Large (when work spans multiple sessions) |
| Verify | `/verify` (3 stages: spec → quality → **cleanup audit** with lint/AST evidence for any deletion/replacement) | Small, Medium, Large |
| Write Tests | `/write-tests` | Medium, Large |
| Code Review | `/review` | Medium, Large |
| Draft PR | `/pr` | Large (optional at Medium) |

## Starting a New Feature

1. **Classify scope** using the table above.
2. **Infer** feature name (kebab-case), problem, and users from the message and `docs/ai/features/`; **at most one** question only if none can be named.
3. At **Small** scope: capture a lightweight task list in chat.
4. At **Medium+** scope: create `docs/ai/features/{name}.md` from `docs/ai/features/README.md`.
5. At **Large** scope: also create companion docs when depth is needed.
6. Follow the workflow for the classified scope.

## Resuming an Existing Feature

1. Check current branch: `git branch --show-current`
2. Locate the feature brief at `docs/ai/features/{name}.md` (if one exists)
3. Check the `Delivery Plan` section for task status
4. Continue from the appropriate phase

## Build vs Build-TDD

Use `/build` for standard implementation.

Use `/build-tdd` when:
- You want tests to define the requirement rather than validate the implementation
- The feature has clear acceptance criteria in the feature brief that map cleanly to test cases
- You want to prevent the AI from writing tests that rubber-stamp its own logic

Both follow the same scope tier. `/build-tdd` simply reverses the order: failing tests first, then implementation to pass them.

## UI/UX Redesign

Use `/redesign` for aesthetic and interaction overhauls.

- Must include a visual audit and data-contract check before code changes.
- If the redesign requires new backend fields, run `/refactor` first.
- Invalid if the result is mostly refactoring or minor style tweaks.

## Backward Transitions

When a phase reveals problems, loop back:

- Requirements check finds major gaps → back to `/plan`
- Design review finds schema issues → back to `/requirements` or `/design-db`
- Verification finds deviations → back to `/build` (implementation wrong) or `/review-design` (design wrong)
- Tests reveal design flaws → back to `/design-db`
- Code review finds blocking issues → back to `/build` or `/write-tests`

## Doc Convention

- Primary feature doc: `docs/ai/features/{name}.md`
- Optional companions: `docs/ai/implementation/{name}.md` and `docs/ai/testing/{name}.md`
- Only create docs when the scope warrants them (Medium+)
- Keep `{name}` aligned with the feature or branch name

## Rules

- Read existing `docs/ai/` before making changes
- Use mermaid diagrams for architecture visuals at Medium+ scope
- After each phase, summarize output and suggest the next phase
- Always classify scope before choosing a workflow — do not apply Large-scope ceremony to Trivial work
- During `/verify`, do not approve Delete Rule cleanup without explicit diagnostics (lint/AST/type evidence with file + line context)
- If tooling evidence is unavailable, mark cleanup decisions as blocked and avoid destructive removals
