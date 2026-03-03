---
description: Build — execute a plan task by task.
---

Help me work through a feature plan one task at a time.

1. **Gather Context** — If not already provided, ask for: feature name (kebab-case), planning doc path (default `docs/ai/planning/feature-{name}.md`), and any supporting docs (design, requirements, implementation).
2. **Load & Present Plan** — Read the planning doc and parse task lists. Present an ordered task queue grouped by section with status: `todo`, `in-progress`, `done`, `blocked`.
3. **Interactive Task Execution** — For each task in order:
   - Display context and full task description
   - Reference relevant design/requirements docs
   - Offer to outline sub-steps before starting
   - Prompt for status update after work (`done`, `in-progress`, `blocked`, `skipped`)
   - If blocked, record the blocker and move to a "Blocked" list
4. **Update Planning Doc** — After each completed task, update the checkbox in `docs/ai/planning/feature-{name}.md`.
5. **Session Summary** — Produce a summary: Completed, In Progress (with next steps), Blocked (with blockers), Skipped/Deferred.
6. **Next Steps** — Continue `/execute-plan` until plan complete; then run `/check-implementation`.
