---
description: Plan any non-trivial work — capture requirements, design, and tasks before writing code.
---

Start a new feature from scratch with structured documentation.

1. **Gather** — Ask for: feature name (kebab-case, e.g. `user-authentication`), problem being solved, who is affected, and key user stories.
2. **Create feature docs** by copying the `README.md` template from each `docs/ai/` subdirectory:
   - `docs/ai/requirements/feature-{name}.md`
   - `docs/ai/design/feature-{name}.md`
   - `docs/ai/planning/feature-{name}.md`
   - `docs/ai/implementation/feature-{name}.md`
   - `docs/ai/testing/feature-{name}.md`
3. **Fill requirements doc** — problem statement, goals/non-goals, user stories, success criteria, constraints, open questions.
4. **Fill design doc** — architecture overview with mermaid diagram, data models, API design, component breakdown, design decisions.
5. **Fill planning doc** — task breakdown by phase, dependencies, effort estimates, risks.
6. **Next Steps** — Run `/review-requirements` to validate, then `/review-design`, then `/execute-plan` to implement.
