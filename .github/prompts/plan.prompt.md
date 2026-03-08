---
description: Plan any non-trivial work — capture requirements, design, and tasks before writing code.
---

Start a new feature from scratch with structured documentation.

1. **Gather** — Ask for: feature name (kebab-case, e.g. `user-authentication`), problem being solved, affected users, key user stories, constraints, and known risks.
2. **Create the primary feature brief** by copying `docs/ai/features/README.md` to `docs/ai/features/{name}.md`.
3. **Create companion docs only if needed**:
   - `docs/ai/implementation/{name}.md` for deeper implementation details
   - `docs/ai/testing/{name}.md` for a dedicated testing strategy
4. **Fill the feature brief** — capture the problem, goals/non-goals, user stories, critical flows, proposed solution, architecture, data/contracts, key decisions, delivery plan, success criteria, and open questions.
5. **Keep planning in the same file** — put milestones, task breakdown, dependencies, and risks in the `Delivery Plan` section so implementation work can be tracked without switching documents.
6. **Next Steps** — Run `/review-plan` to validate the brief, `/review-design` to validate the architecture sections, then `/build` to implement.
