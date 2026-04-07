# Artifact Hierarchy

Toji uses a **two-tier artifact model**. Understanding which tier owns what prevents context drift, conflicting sources of truth, and stale plans.

## Two-Tier Model

| Tier | Location | Purpose | Lifespan |
|---|---|---|---|
| **Canonical** | `docs/ai/features/*.md` | Requirements, acceptance criteria, architecture decisions, and delivery plan. **Policy artifacts.** | Permanent — project lifetime |
| **Physical Memory** | `.agent/implementation_plan.md`, `.agent/task.md` | Execution state, progress tracking, session resumption. **Not policy, but durable mid-mission.** | Mission-scoped — deleted on completion |

## Canonical Tier

`docs/ai/features/{name}.md` is the **single source of truth** for:

- Problem definition and goals
- User stories and acceptance criteria
- Architecture and key decisions
- Risk Surface
- Delivery Plan checkboxes (authoritative for what to build)

Rules:
- Never derive requirements from Physical Memory files. Always read `docs/ai/features/` first.
- Do not overwrite or skip the feature brief to save time.
- At Medium+ scope, create the feature brief before producing Physical Memory files.
- At Small scope, a lightweight feature brief is optional — but Physical Memory is still mandatory.

## Physical Memory Tier

`.agent/implementation_plan.md` and `.agent/task.md` are the **source of truth for progress**:

- Which tasks are done (`[x]`), in progress (`[/]`), or pending (`[ ]`)
- Architectural grounding for the active session (implementation_plan.md)
- Session recovery position (task.md)

Rules:
- Physical Memory must exist on disk before implementation begins (Small+ scope).
- Trivial scope is **exempt** from Physical Memory.
- Only one active mission at a time. One `task.md` per project.
- If `task.md` exists when `/plan` runs for a new mission, the agent must warn the user and ask whether to delete-and-replace or continue the existing mission.
- When Canonical specs change mid-mission, re-derive Physical Memory from the updated feature brief.
- Physical Memory files persist across sessions until all tasks are `[x]`.

## Mission Cleanup (Mandatory)

When all checkboxes in `.agent/task.md` are `[x]`:

1. Delete `.agent/task.md`.
2. Delete `.agent/implementation_plan.md`.
3. State: `[Mission complete — Physical Memory cleared]`.

This ensures the next mission starts from a clean slate with no stale context.

## Session Resumption

When a session starts (or context is lost/evicted):

1. Check if `.agent/task.md` exists.
2. If yes — read it and `.agent/implementation_plan.md` silently.
3. Resume from the first `[ ]` or `[/]` task.
4. State: `[Resuming: <task description>]`.
5. If neither file exists — proceed with the user's request normally.

## Checkpoint Discipline

During `/build` execution:

- Mark the active task `[/]` in `task.md` **before** starting work. Write to disk immediately.
- Mark `[x]` **after** completion. Write to disk immediately.
- Do not batch checkpoint writes across multiple tasks.
- After every tool call that modifies source code, re-read `task.md` to confirm position.
- If context feels uncertain, re-read `implementation_plan.md` for architectural grounding.

## Pivot Behavior

If a mid-build pivot is needed (scope creep, blocker, design flaw discovered):

1. Halt code changes immediately.
2. Update `docs/ai/features/{name}.md` (Canonical) first.
3. Re-derive `.agent/implementation_plan.md` and `.agent/task.md` from the updated brief.
4. Continue from the new task list.

Never update Physical Memory to justify code that contradicts the Canonical brief.
