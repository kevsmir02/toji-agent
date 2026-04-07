---
name: scan-codebase
description: Full-project structural scan — refresh Active Stack Profile, map directories, identify entry points, architectural layers, and key conventions, then write docs/ai/implementation/codebase-map.md. Use when the user explicitly asks to scan or map the codebase, or when starting a Large-scope feature that needs a fresh structural baseline. Do NOT use for understanding a single file or module (use capture-knowledge for that).
globs: ["**"]
---

# Codebase Scanner

Produce a structured, high-level map of the entire project so Toji has persistent context about what it's working in.

## `#codebase` vs this skill

- **`#codebase` / `@workspace`:** answers *“how does X work in this repo?”* using the **shared semantic index** (default branch) at **no extra request cost** — use for ad-hoc navigation and explanations.
- **`scan-codebase` (this skill):** produces a **written artifact** **`docs/ai/implementation/codebase-map.md`** for **living memory** and governance handoff — use when the user asks for a **map**, a **Large-scope baseline**, or a **durable** structural record.

Do **not** invoke this skill when **`#codebase`** alone is enough for a one-off question.

## Hard Rules
- Do not modify any source files.
- Updating `.github/copilot-instructions.md` to refresh the Active Stack Profile is allowed as part of the scan.
- Do not create the output doc until the full scan is complete.
- Focus on structure and patterns — avoid deep line-by-line analysis (that's `capture-knowledge`'s job).

## Workflow

0. **Onboarding / governance check (mandatory before recommending feature work)** — Before treating the repo as fully Toji-governed:

   - Read **`docs/ai/onboarding/onboarding-log.md`** if it exists.
   - Otherwise read **`docs/ai/README.md`** and locate **Toji Governance** → **Line in the Sand (Toji governance start)**.
   - **If** there is **no** onboarding log **and** the Line in the Sand is missing, `not set`, or clearly never filled (e.g. placeholder “run `/onboard`”), you **must** state in the scan output: **“Onboarding not completed — suggest running `/onboard` before significant feature development.”** Still complete the structural scan if the user asked for a map.
   - **If** governance is set, note the Line in the Sand date and onboarding mode in the **Project Overview** or **Notes** section of the codebase map.

1. **Refresh Stack Profile** — Run the same detection protocol as `/detect-stack` before producing the map. Update the Active Stack Profile in `.github/copilot-instructions.md` with the detected stack id, skill path, and date.

2. **Root Survey** — List the top-level directory. Identify the project type from config files:
   - `composer.json`, `artisan` → Laravel
   - `package.json`, `vite.config.*`, `next.config.*` → Node / frontend
   - `pyproject.toml`, `requirements.txt` → Python
   - `go.mod` → Go
   - Combination files → note the full stack

3. **Structural Scan** — Walk key directories (max depth 4). For each relevant layer, record:
   - Directory path and its role (e.g. `app/Http/Controllers` → HTTP layer)
   - Representative files — list a few, not all
   - Skip: `node_modules`, `vendor`, `.git`, build outputs, caches

4. **Entry Points** — Identify where the application starts:
   - Web: routes files, controllers, page components
   - CLI: console commands, scripts
   - Background: jobs, queues, event listeners
   - API: resource controllers, route groups

5. **Architectural Layers** — Map the layers present and their responsibilities:
   - Examples: HTTP, Domain/Action, Data (Models/Repos/DTOs), Background Jobs, Frontend Pages, Tests
   - Note patterns in use: MVC, action classes, form requests, DTOs, service objects, route helpers, etc.

6. **Key Conventions** — Capture what's consistent across the codebase:
   - Naming conventions (file names, class names, route naming)
   - Notable shared utilities, base classes, traits
   - Testing setup (feature vs unit, test runner)
   - Frontend tooling (bundler, component patterns, styling approach)

7. **Dependencies Summary** — Read `composer.json` and/or `package.json`. List:
   - Runtime dependencies grouped by purpose (framework, auth, queue, UI, etc.)
   - Dev dependencies (testing, linting, build tools)

8. **Create Codebase Map** — Write `docs/ai/implementation/codebase-map.md` using the Output Template below.

## Validation
- All Output Template sections are populated
- **Onboarding / governance** — Step 0 satisfied: either README + log show a Line in the Sand, or the map explicitly recommends `/onboard`
- Active Stack Profile was refreshed before the map was written
- Entry points are clearly identified
- No source files were modified beyond `.github/copilot-instructions.md` for stack profile refresh
- Remind the user to commit the doc and re-run after major structural changes

## Output Template

```md
# Codebase Map

> Generated: {YYYY-MM-DD}

## Project Overview
Brief description of what this application is and does (1–3 sentences).

## Toji Governance (onboarding)
- **Line in the Sand:** {YYYY-MM-DD or not set}
- **Onboarding log:** {path or missing}
- **Recommendation:** {OK for governed feature work | run `/onboard` first}

## Active Stack Profile
Summarize the detected stack id, resolved skill path, and detection date.

## Tech Stack
| Layer | Technology | Version |
|---|---|---|

## Directory Structure
Key directories and their roles (skip noise).

## Entry Points
- Web:
- CLI:
- Background:
- API:

## Architectural Layers
Describe each layer, its location, and its responsibility.

## Key Conventions
Naming, patterns, shared utilities, base classes.

## Dependencies Summary
Grouped by purpose.

## Notes & Open Questions
Anything unclear or worth investigating further.
```
