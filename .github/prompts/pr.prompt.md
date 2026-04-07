---
description: Draft a comprehensive pull request description from the feature brief, plan, and actual changes. Single-shot.
---

Draft a complete pull request description in markdown.

**Single-shot:** Infer feature name, branch, and brief path from git + `docs/ai/` + message. Omit issue/ticket lines if unknown. **At most one** question only if neither branch nor changed files imply a feature.

1. **Gather Context** — Fill metadata from `git branch --show-current`, `git diff --stat`, and the closest `docs/ai/features/*.md`; mark **Assumed:** for guesses.
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