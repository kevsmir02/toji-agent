```prompt
---
description: Scan the project codebase and produce a high-level map of its structure, entry points, architectural layers, patterns, and tech stack.
---

Scan this codebase and produce a structured map saved to `docs/ai/implementation/codebase-map.md`.

1. **Root Survey** — List the top-level directory. Identify the project type from config files (`composer.json`, `package.json`, `artisan`, `pyproject.toml`, `go.mod`, etc.).
2. **Structural Scan** — Walk key directories (max depth 4). Record each layer's path, role, and a few representative files. Skip `node_modules`, `vendor`, `.git`, build outputs, and caches.
3. **Entry Points** — Identify where the application starts: web routes, CLI commands, background jobs, API route groups.
4. **Architectural Layers** — Map each layer (HTTP, service, data, frontend, tests) and the patterns in use (MVC, service objects, action classes, form requests, etc.).
5. **Key Conventions** — Capture consistent naming conventions, shared base classes/traits, testing setup, and frontend tooling.
6. **Dependencies Summary** — From `composer.json` / `package.json`, list runtime and dev dependencies grouped by purpose.
7. **Write Output** — Create `docs/ai/implementation/codebase-map.md` with sections: Project Overview, Tech Stack, Directory Structure, Entry Points, Architectural Layers, Key Conventions, Dependencies Summary, Notes & Open Questions. Include the generation date.
8. **Report** — Confirm the file path, summarize key findings, and remind the user to re-run after major structural changes.
```
