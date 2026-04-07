---
name: toji-clarify
description: "Antigravity workflow for /clarify — triggers the ambiguity-resolver skill to intercept vague feature requests and ask 2-3 precise clarifying questions before planning begins. Run this before /plan on any Medium or Large scope request."
---

# Workflow: Toji Clarify

Purpose: resolve ambiguities in a feature request before planning begins. Delegates to the `ambiguity-resolver` skill.

## Inputs

- User's feature request or task description
- `docs/ai/README.md` (current project state)
- `docs/ai/features/*.md` (existing feature briefs)
- Relevant source files inferred from the request

## Outputs

- 2–3 precise clarifying questions (or "no clarification needed" if request is unambiguous)
- A short summary of what is already known (inferred from codebase) vs what is ambiguous

## Steps

1. Load `.github/skills/ambiguity-resolver/SKILL.md` before starting.
2. **Silent Context Scan** — use available tools to read:
   - `docs/ai/README.md` for project state
   - Any `docs/ai/features/` brief related to this request
   - Relevant model, schema, or route files related to the request domain
3. **Classify request scope** using `.github/skills/dev-lifecycle/SKILL.md`.
   - If scope is **Trivial**: skip this workflow entirely. Proceed directly to `/build`.
   - If a feature brief already exists in `docs/ai/features/` for this exact request: skip to `/plan`.
4. **Identify ambiguities**: scan the context for missing decisions in:
   - Error handling strategy
   - Auth/authorization requirements
   - Data storage approach
   - Edge cases specific to the domain
5. **Formulate 2–3 questions** — each must be:
   - Concrete and specific (reference actual file names, field names, or flows)
   - Non-obvious (cannot be inferred from codebase or docs)
   - Architecture-blocking (the answer changes how the plan is written)
6. Present questions to the user. **Stop and wait for answers.**
7. Once answered, signal readiness for `/plan` — do not ask further questions.
8. While clarification is active, defer autonomous profile selection.

## Guardrails

- Never ask about the tech stack (inferable via `/detect-stack`)
- Never ask "should I add tests?" (Iron Law — always yes)
- Never ask about pagination on list endpoints (Iron Law — always yes)
- At most one follow-up if an answer introduces a new critical ambiguity
- All context reads are local files + MCP tools only — no external API calls
