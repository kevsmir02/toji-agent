---
description: Update the plan to reflect current implementation progress.
---

Help me reconcile current implementation progress with the planning documentation.

1. **Gather Context** — If not already provided, ask for: feature/branch name and brief status, tasks completed since last update, new tasks discovered, current blockers or risks, and feature brief path (default `docs/ai/features/{name}.md`).
2. **Review & Reconcile** — Summarize existing milestones, task breakdowns, dependencies, and risks from the `Delivery Plan` section. For each planned task: mark status (done / in progress / blocked / not started), note scope changes, record blockers, identify skipped or added tasks.
3. **Produce Updated Task List** — Generate an updated checklist grouped by: Done, In Progress, Blocked, Newly Discovered Work — with short notes per task.
4. **Update the Feature Brief** — Fold the updated checklist, blockers, and scope changes back into `docs/ai/features/{name}.md`.
5. **Next Steps** — Suggest the next 2-3 actionable tasks and prepare a short status summary for the feature brief.
6. **Next Command Guidance** — Return to `/build` for remaining work. When implementation tasks are complete, run `/verify`.
