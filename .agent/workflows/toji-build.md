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

## When to Dispatch a Subagent

Use a subagent when a task is self-contained and would benefit from a clean context (no accumulated state from the current session). Do not use subagents as a shortcut to avoid reading context — use them to isolate genuinely independent work.

### Dispatch criteria (all must apply)

1. The task has a single, clearly defined output (a file, a report, a set of test results)
2. The task does not require knowledge accumulated during the current session
3. The task scope is bounded enough that it can be described in a paragraph
4. You can define the exact acceptance criteria the subagent should meet

### Context to pass

When dispatching a subagent, provide:
- The exact task description (not a reference to "the plan")
- The specific file paths involved
- The verification command and expected output
- The acceptance criteria from `docs/ai/features/` or `.agent/implementation_plan.md`

Vague instructions produce vague output. Be precise.

### How to review subagent output

1. Read the subagent's completion report
2. **Run the verification command yourself** — do not accept the subagent's claim of passing tests
3. Review changed files against the task spec
4. If output is incomplete or incorrect: describe the specific delta in a follow-up dispatch, or fix manually

Subagent output is **unverified until you verify it**. The `verification-before-completion` skill applies to subagent delegation.

---

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
