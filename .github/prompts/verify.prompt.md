---
description: Verify the implementation matches the design and requirements — identify gaps.
---

Compare the current implementation with the feature brief in `docs/ai/features/` and any supporting implementation/testing docs.

1. If not already provided, ask for: feature/branch description, list of modified files, relevant feature brief(s), and any supporting implementation doc.
2. For each feature brief: summarize key architectural decisions, delivery constraints, acceptance criteria, and data flows that must be respected.
3. File-by-file comparison:
   - Confirm implementation matches feature intent and design decisions
   - Note deviations or missing pieces
   - Flag logic gaps, edge cases, or security issues
   - Suggest simplifications or refactors
   - Identify missing tests or documentation updates
4. Summarize findings with recommended next steps.
5. **Next Steps** — If major design issues are found, go back to `/review-design` or `/build`; if aligned, continue to `/write-tests`.
