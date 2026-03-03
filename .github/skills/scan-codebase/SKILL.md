```skill
---
name: scan-codebase
description: Scan the entire project to produce a high-level codebase map — structure, entry points, architectural layers, key patterns, and tech stack. Use when users ask to scan, map, or understand the codebase, or before starting a large feature to build shared context.
---

# Codebase Scanner

Produce a structured, high-level map of the entire project so Toji has persistent context about what it's working in.

## Hard Rules
- Do not modify any source files.
- Do not create the output doc until the full scan is complete.
- Focus on structure and patterns — avoid deep line-by-line analysis (that's `capture-knowledge`'s job).

## Workflow

1. **Root Survey** — List the top-level directory. Identify the project type from config files:
   - `composer.json`, `artisan` → Laravel
   - `package.json`, `vite.config.*`, `next.config.*` → Node / frontend
   - `pyproject.toml`, `requirements.txt` → Python
   - `go.mod` → Go
   - Combination files → note the full stack

2. **Structural Scan** — Walk key directories (max depth 4). For each relevant layer, record:
   - Directory path and its role (e.g. `app/Http/Controllers` → HTTP layer)
   - Representative files — list a few, not all
   - Skip: `node_modules`, `vendor`, `.git`, build outputs, caches

3. **Entry Points** — Identify where the application starts:
   - Web: routes files, controllers, page components
   - CLI: console commands, scripts
   - Background: jobs, queues, event listeners
   - API: resource controllers, route groups

4. **Architectural Layers** — Map the layers present and their responsibilities:
   - Examples: HTTP, Domain/Service, Data (Models/Repos), Background Jobs, Frontend Pages, Tests
   - Note patterns in use: MVC, service objects, action classes, form requests, etc.

5. **Key Conventions** — Capture what's consistent across the codebase:
   - Naming conventions (file names, class names, route naming)
   - Notable shared utilities, base classes, traits
   - Testing setup (feature vs unit, test runner)
   - Frontend tooling (bundler, component patterns, styling approach)

6. **Dependencies Summary** — Read `composer.json` and/or `package.json`. List:
   - Runtime dependencies grouped by purpose (framework, auth, queue, UI, etc.)
   - Dev dependencies (testing, linting, build tools)

7. **Create Codebase Map** — Write `docs/ai/implementation/codebase-map.md` using the Output Template below.

## Validation
- All Output Template sections are populated
- Entry points are clearly identified
- No source files were modified
- Remind the user to commit the doc and re-run after major structural changes

## Output Template

```md
# Codebase Map

> Generated: {YYYY-MM-DD}

## Project Overview
Brief description of what this application is and does (1–3 sentences).

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
```
