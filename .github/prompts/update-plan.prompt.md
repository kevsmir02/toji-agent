---
description: Update the plan to reflect current implementation progress. Single-shot.
---

Help me reconcile current implementation progress with the planning documentation.

**Single-shot:** Infer feature brief and progress from `docs/ai/features/`, `git diff` / status, and the message. **At most one** question only if no brief matches and no feature name is inferable.

1. **Gather Context** — Pick `docs/ai/features/{name}.md` from context; infer completed work and blockers from diff + Delivery Plan checkboxes; use **Assumed:** for gaps.
2. **Review & Reconcile** — Summarize existing milestones, task breakdowns, dependencies, and risks from the `Delivery Plan` section. For each planned task: mark status (done / in progress / blocked / not started), note scope changes, record blockers, identify skipped or added tasks.
3. **Produce Updated Task List** — Generate an updated checklist grouped by: Done, In Progress, Blocked, Newly Discovered Work — with short notes per task.
4. **Update the Feature Brief** — Fold the updated checklist, blockers, and scope changes back into `docs/ai/features/{name}.md`.
5. **Next Steps** — Suggest the next 2-3 actionable tasks and prepare a short status summary for the feature brief.
6. **Next Command Guidance** — Return to `/build` for remaining work. When implementation tasks are complete, run `/verify`.
