---
description: Scan the project codebase, refresh the active stack profile, and produce a high-level map of its structure, entry points, architectural layers, patterns, and tech stack.
---

Scan this codebase and produce a structured map saved to `docs/ai/implementation/codebase-map.md`.

1. **Refresh Stack Profile First** — Re-run the `/detect-stack` logic: inspect stack markers, resolve the stack id, and update the Active Stack Profile in `.github/copilot-instructions.md` before writing the codebase map.
2. **Root Survey** — List the top-level directory. Identify the project type from config files (`composer.json`, `package.json`, `artisan`, `pyproject.toml`, `go.mod`, etc.).
3. **Structural Scan** — Walk key directories (max depth 4). Record each layer's path, role, and a few representative files. Skip `node_modules`, `vendor`, `.git`, build outputs, and caches.
4. **Entry Points** — Identify where the application starts: web routes, CLI commands, background jobs, API route groups.
5. **Architectural Layers** — Map each layer (HTTP, service, data, frontend, tests) and the patterns in use (MVC, action classes, form requests, DTOs, jobs, etc.).
6. **Key Conventions** — Capture consistent naming conventions, shared base classes/traits, testing setup, frontend tooling, and route generation approach.
7. **Dependencies Summary** — From `composer.json` / `package.json`, list runtime and dev dependencies grouped by purpose.
8. **Write Output** — Create `docs/ai/implementation/codebase-map.md` with sections: Project Overview, Active Stack Profile, Tech Stack, Directory Structure, Entry Points, Architectural Layers, Key Conventions, Dependencies Summary, Notes & Open Questions. Include the generation date.
9. **Report** — Confirm the file path, summarize key findings, report the refreshed Active Stack Profile values, and remind the user to re-run after major structural changes.
