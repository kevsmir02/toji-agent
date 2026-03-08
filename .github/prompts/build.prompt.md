---
description: Build — execute a plan task by task.
---

Help me work through a feature plan one task at a time.

1. **Gather Context** — If not already provided, ask for: feature name (kebab-case), feature brief path (default `docs/ai/features/{name}.md`), and any supporting docs (`docs/ai/implementation/{name}.md`, `docs/ai/testing/{name}.md`).
2. **Load & Present Plan** — Read the `Delivery Plan` section from the feature brief and parse task lists. Present an ordered task queue grouped by section with status: `todo`, `in-progress`, `done`, `blocked`.
3. **Interactive Task Execution** — For each task in order:
   - Display context and full task description
   - Reference relevant problem, design, and success-criteria sections in the feature brief
   - Offer to outline sub-steps before starting
   - Prompt for status update after work (`done`, `in-progress`, `blocked`, `skipped`)
   - If blocked, record the blocker and move to a "Blocked" list
4. **Update Feature Brief** — After each completed task, update the checkbox in `docs/ai/features/{name}.md`.
5. **Session Summary** — Produce a summary: Completed, In Progress (with next steps), Blocked (with blockers), Skipped/Deferred.
6. **Next Steps** — Continue `/build` until the plan is complete; then run `/verify`.
