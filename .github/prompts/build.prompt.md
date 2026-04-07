---
description: Build — execute the next (or named) Delivery Plan task in one shot; infer brief from docs/message. No pre-task questionnaires.
---

**Single-shot:** Follow **Single-shot efficiency** in `.github/copilot-instructions.md`. Infer **feature name** and brief path from the user message, **`docs/ai/features/`**, or the plan the message references—**do not** ask for them unless **blocking**.

0. **Core Skills (mandatory, always first)** — Before any code is written, silently read and internalize these core skills:
   - `.github/skills/test-driven-development/SKILL.md` — Iron Law TDD (Red-Green-Refactor + Delete Rule). No scope exceptions.
   - `.github/skills/research-first/SKILL.md` — If the task involves any framework, API, or external service, perform a documentation lookup before writing integration code.
   - `.github/skills/security/SKILL.md` — If the task touches auth, input handling, routes, uploads, or queries, silently evaluate the OWASP Threat Matrix and block any FAIL results.

0.5. **Session Recovery (Physical Memory)** — Before any other work, check if `.agent/task.md` exists. If it does, read it and `.agent/implementation_plan.md` silently. Resume from the first unchecked (`[ ]`) or in-progress (`[/]`) task. State: `[Resuming: <task>]`.

1. **Load context** — Read `docs/ai/features/{name}.md` (and implementation/testing companions if present), `.agent/implementation_plan.md`, and `.agent/task.md`. Parse `Delivery Plan` checkboxes.

2. **Risk Surface read (silent, mandatory when present)** — At build start, silently read the `## Risk Surface` section of the feature brief if it exists.
	- If the section identifies an **input surface**, validate inputs at the relevant boundaries.
	- If the section identifies an **auth boundary**, confirm guards/authorization checks are in place.
	- If the section identifies **performance pressure**, avoid N+1 queries and add appropriate indexing and/or pagination where applicable.
	- These are build requirements derived from planning, not optional suggestions.
3. **Execute (TDD mode)** — Complete **one** logical Delivery Plan item per invocation (or the **single** item the user named).
	- **Checkpoint Start**: Mark the task as in-progress (`[/]`) in `.agent/task.md` and write to disk immediately.
	- **Behavior Slices**: For each slice: Red (failing test + observed failure) → Green (minimum implementation) → Refactor.
	- **Checkpoint Discipline**: After every tool call that modifies source code, re-read `.agent/task.md` to confirm position.
	- **Checkpoint Complete**: Mark task as `[x]` in `.agent/task.md` and the feature brief. Write to disk immediately. Apply the Delete Rule if any production code preceded a failing test.

4. **What changed** — Mandatory **What changed** (≥3 bullets) for any code edits.
5. **Handoff** — One line: next unchecked task title, or “Plan complete — run `/verify`.”
	- **Mission Cleanup**: If all tasks in `.agent/task.md` are marked `[x]`, delete `.agent/task.md` and `.agent/implementation_plan.md`. State: `[Mission complete — Physical Memory cleared]`.
	- **Handoff**: The user invokes `/build` again for the next task.

