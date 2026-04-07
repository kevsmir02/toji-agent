# Workflow: Toji Build

Purpose: translate Toji /build behavior into Antigravity workflow execution. Enforce durable state tracking and session recovery.

## Inputs

- docs/ai/features/{name}.md (canonical source, if present)
- .agent/implementation_plan.md
- .agent/task.md

## Outputs

- Code changes for one logical plan task
- Updated checkboxes in .agent/task.md and feature brief
- Immediate disk write of task.md state

## Steps

0. **Session Recovery**: Before any work, check if `.agent/task.md` exists. If it does, read it and resume from the first unchecked (`[ ]`) or in-progress (`[/]`) task. State: `[Resuming: <task>]`.
1. **Load TDD Skill (mandatory)** — Before touching production code, silently read `.github/skills/test-driven-development/SKILL.md`. Iron Law TDD and the Delete Rule apply to every behavior slice in every task.
2. Read docs/ai/features/{name}.md first, then read implementation_plan.md and task.md.
3. Mandatory: read acceptance criteria from docs/ai/features/{name}.md before executing any task.
4. **Checkpoint Start**: Mark the next unchecked task as in-progress (`[/]`) in `.agent/task.md` and write to disk immediately.
5. Implement exactly one logical task end-to-end using Red-Green-Refactor cycles (one per behavior slice).
6. **Checkpoint Discipline**: After every tool call that modifies source code, re-read `.agent/task.md` to confirm your position. If context feels uncertain, re-read `.agent/implementation_plan.md`.
7. Run verification commands listed in the plan.
8. **Checkpoint Complete**: Mark the task as `[x]` in `.agent/task.md` and write to disk immediately. Capture brief outcome notes.
9. **Mission Cleanup**: If all tasks in `.agent/task.md` are marked `[x]`, delete `.agent/task.md` and `.agent/implementation_plan.md`. State: `[Mission complete — Physical Memory cleared]`.
10. Enforce routing lock semantics for active task lifecycle:
	- Respect explicit user profile overrides immediately.
	- Maintain `Audit` lock when active.
	- Allow one-way escalation to `Audit` if qualifying new high-risk evidence appears.
	- Forbid automatic deescalation.

## Turbo Blocks

Use // turbo blocks for deterministic execution chunks that Antigravity can automate.

// turbo:start build-task
- apply planned edit(s)
- run tests/lint for touched scope
- report failures with file path + command output summary
// turbo:end

## Guardrails

- Respect Risk Surface requirements from planning.
- Follow docs/ai/implementation/artifact-hierarchy.md when deciding canonical vs mirror edits.
- **TDD Iron Law:** Red (failing test + observed failure) before Green (implementation). Apply the Delete Rule to any production code that appeared before a failing test.
- Apply Delete Rule for any UI compliance violations introduced on new/changed lines.
- End with a concise What changed summary.
- **Durable State**: task.md must reflect current progress at all times. Stale checkboxes are a governance violation.
- **Mission Slate**: Always delete physical memory on mission completion.
