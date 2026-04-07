---
name: toji-onboard
description: "Antigravity workflow for /onboard — initializes Toji governance on a project. Handles Fresh Start (new project) and Legacy Integration (existing codebase) modes. Run once per repository before starting feature work."
---

# Workflow: Toji Onboard

Purpose: initialize Toji governance on a project. Delegates to the `onboarding` skill.

## Inputs

- Repository root (all files accessible via tools)
- Available MCP tools (DB schema, routes, logs)

## Outputs

- `docs/ai/README.md` — governance block with Line in the Sand
- `docs/ai/onboarding/onboarding-log.md`
- **Legacy Integration only:**
  - `docs/ai/onboarding/legacy-token-extract.md`
  - `docs/ai/onboarding/legacy-baseline.md`

## Steps

1. Load `.github/skills/onboarding/SKILL.md` before starting.
2. **Detect mode** — examine the repository:
   - If routes, UI components, and substantial source code already exist → **Mode B (Legacy Integration)**
   - If the repository is new or mostly scaffolding → **Mode A (Fresh Start)**
3. **Run the IDE "List Tools" command** to discover available MCP servers (DB schema, logs, REPL).
4. **Mandatory current-state verification**: use MCP tools to confirm:
   - Database schema (if applicable)
   - Existing routes or API endpoints
   - Frontend framework and UI component structure
5. Execute the corresponding mode from `.github/skills/onboarding/SKILL.md`:
   - **Mode A:** scaffold `docs/ai/` layout, set Line in the Sand, create onboarding log
   - **Mode B:** Legalization Scan, baseline inventory, Line in the Sand, onboarding log
6. Write governance block to `docs/ai/README.md` — do not overwrite existing project content.
7. Produce an **Integrity Roadmap** summarizing:
   - Current State of the Union (what exists)
   - Technical debt discovered (if Legacy mode)
   - Recommended next steps (e.g. `/detect-stack`, first feature)

## Turbo Blocks

// turbo:start onboard-docs-scaffold
- create docs/ai/ structure if missing
- write onboarding-log.md
- update docs/ai/README.md governance block
// turbo:end

## Guardrails

- Never overwrite existing `docs/ai/` content — append and create only
- Never skip the Line in the Sand date
- If database schema is available via MCP, use it — do not guess table names
- Prohibit Guessing: runtime facts come from MCP tools, not file inference
- After onboarding: recommend `/detect-stack` as the next step
