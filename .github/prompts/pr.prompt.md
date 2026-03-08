---
description: Draft a comprehensive pull request description from the feature brief, plan, and actual changes.
---

Draft a complete pull request description in markdown.

1. **Gather Context** — If not already provided, ask for: feature name, branch name, linked issue/ticket, feature brief path (default `docs/ai/features/{name}.md`), and any supporting implementation/testing docs.
2. **Load the Planning Context** — Read the feature brief and extract the problem, goals, scope, major design decisions, delivery-plan items completed in this PR, risks, and follow-up work.
3. **Cross-check the Actual Change Set** — Review `git status`, `git diff --stat`, and key changed files so the description matches reality rather than only the plan.
4. **Write the PR Description** — Produce copy-ready markdown with these sections:
   - `## Summary`
   - `## Problem / Context`
   - `## What Changed`
   - `## Implementation Notes`
   - `## Testing`
   - `## Risks and Rollout`
   - `## Follow-ups`
5. **Call Out Gaps Explicitly** — Note any planned work that remains out of scope for this PR, and mention any risks or assumptions reviewers should pay attention to.
6. **Reviewer Guide** — End with a short reviewer checklist or focus areas list when the change is complex.