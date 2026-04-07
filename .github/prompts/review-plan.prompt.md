---
description: Review a feature brief for completeness before starting work. Single-shot.
---

**Single-shot:** Infer `{name}` from the message, branch, or `docs/ai/features/`; **at most one** question only if no brief can be chosen.

Review `docs/ai/features/{name}.md` and the base template `docs/ai/features/README.md` to ensure structure and content alignment.

1. Summarize:
   - Core problem statement and affected users
   - Goals, non-goals, and success criteria
   - Primary user stories and critical flows
   - Proposed solution, delivery plan, constraints, assumptions, and open questions
   - Any missing sections or deviations from the template
2. Identify gaps or contradictions — list as **Assumed:** fixes or **BLOCKED:** items in **this** response; **do not** open a separate Q&A round before delivering the review.
3. **Next Steps** — If fundamentals are missing, fill them in; otherwise continue to `/review-design`.
