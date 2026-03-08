---
description: Pre-push code review against the feature brief and design intent.
---

Perform a local code review before pushing changes.

1. **Gather Context** — If not already provided, ask for: feature/branch description, list of modified files, relevant feature brief(s) (e.g. `docs/ai/features/{name}.md`), known constraints or risky areas, and which tests have been run. Also review `git status` and `git diff --stat`.
2. **Understand Design Alignment** — For each feature brief, summarize the architectural intent, success criteria, and critical constraints.
3. **File-by-File Review** — For every modified file:
   - Check alignment with the feature brief and flag deviations
   - Spot logic issues, edge cases, redundant code
   - Flag security concerns (input validation, secrets, auth, data handling)
   - Check error handling, performance, observability
   - Identify missing or outdated tests
4. **Cross-Cutting Concerns** — Verify naming consistency and project conventions. Confirm docs/comments updated where behavior changed. Check for needed configuration/migration updates.
5. **Summarize Findings** — Categorize each finding as **blocking**, **important**, or **nice-to-have** with: file, issue, impact, and recommendation.
6. **Next Steps** — If blocking issues remain, return to `/build` (code fixes) or `/write-tests` (test gaps); if clean, proceed with `/pr` or push.
