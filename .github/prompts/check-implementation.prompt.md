---
description: Compare implementation with design and requirements docs to ensure alignment.
---

Compare the current implementation with the design in `docs/ai/design/` and requirements in `docs/ai/requirements/`.

1. If not already provided, ask for: feature/branch description, list of modified files, and relevant design doc(s).
2. For each design doc: summarize key architectural decisions and constraints, highlight components, interfaces, and data flows that must be respected.
3. File-by-file comparison:
   - Confirm implementation matches design intent
   - Note deviations or missing pieces
   - Flag logic gaps, edge cases, or security issues
   - Suggest simplifications or refactors
   - Identify missing tests or documentation updates
4. Summarize findings with recommended next steps.
5. **Next Steps** — If major design issues found, go back to `/review-design` or `/execute-plan`; if aligned, continue to `/writing-test`.
