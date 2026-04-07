# Workflow: Toji Build

Purpose: translate Toji /build behavior into Antigravity workflow execution.

## Inputs

- .agent/implementation_plan.md
- .agent/task.md
- docs/ai/features/{name}.md (if present)

## Outputs

- Code changes for one logical plan task
- Updated checkboxes in .agent/task.md and feature brief

## Steps

0. **Load TDD Skill (mandatory)** — Before touching production code, silently read `.github/skills/test-driven-development/SKILL.md`. Iron Law TDD and the Delete Rule apply to every behavior slice in every task.
1. Read implementation_plan.md and task.md.
2. Pick the next unchecked task (or user-named task).
3. Implement exactly one logical task end-to-end using Red-Green-Refactor cycles (one per behavior slice).
4. Run verification commands listed in the plan.
5. Mark task status and capture brief outcome notes.
6. Enforce routing lock semantics for active task lifecycle:
	- Respect explicit user profile overrides immediately.
	- Maintain `Audit` lock when active.
	- Allow one-way escalation to `Audit` if qualifying new high-risk evidence appears.
	- Forbid automatic deescalation.

## Turbo Blocks

Use // turbo blocks for deterministic execution chunks that Antigravity can automate.

Example pattern:

// turbo:start build-task
- apply planned edit(s)
- run tests/lint for touched scope
- report failures with file path + command output summary
// turbo:end

## Guardrails

- Respect Risk Surface requirements from planning.
- **TDD Iron Law:** Red (failing test + observed failure) before Green (implementation). Apply the Delete Rule to any production code that appeared before a failing test.
- Apply Delete Rule for any UI compliance violations introduced on new/changed lines.
- End with a concise What changed summary.
