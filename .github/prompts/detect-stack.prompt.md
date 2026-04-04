---
description: Detect project stack and update active stack profile for stack-specific mode. Single-shot.
---

Detect this project's stack using the protocol in **`.github/skills/stack-router/SKILL.md`**.

**Single-shot:** No clarifying questions unless the repo has **no** recognizable markers at all.

Read the skill first, then:

1. Scan stack markers (config files, dependencies, framework indicators).
2. Skim **`.github/lessons-learned.md`** `## Instincts` for stack/tooling mentions that should match the chosen profile.
3. Build a normalized stack ID.
4. Resolve the matching skill path.
5. Update the Active Stack Profile in **`.github/copilot-instructions.md`** (set **Last Detected** to today’s date).
6. **Regenerate Tier 2** (same response, **stack-router** “Tier 2 path instructions + Antigravity rules”): ensure **`.github/instructions/`** and **`.agent/rules/`** exist; delete all **`.github/instructions/toji-stack-*.instructions.md`** and **`.agent/rules/toji-stack-*.md`**; if **stack-specific** with a real **`.github/skills/.../SKILL.md`**, write thin doublets per the matrix — Copilot **`applyTo`** + Antigravity **`globs`** (same pattern string) + one skill line — **never** delete Tier 1 `testing` / `frontend-tokens` / `documentation` **`.instructions.md`** or **`.agent/rules/toji-*.md`** without **`toji-stack-`**.
7. **MCP recommendations (mandatory):** determine Beneficial MCP Servers for the detected stack (Laravel: `laravel-boost`; MERN/Node: `mongodb-mcp` or `node-logs-mcp`; general: `github-mcp` or `fetch-mcp`). If Antigravity is active, generate or update **`.agent/mcp_config.json`** with these recommendations (non-destructive merge, preserve existing keys).
8. **Exclude hygiene:** if **`.git/info/exclude`** lacks **`.github/instructions/toji-stack-*.instructions.md`**, append it once; if it lacks **`.agent/rules/toji-stack-*.md`**, append it once; if it lacks **`.agent/*.json`**, append it once.
9. Report: detected stack ID, evidence used, updated profile values, suggested skill to create if missing, MCP recommendations, **Re-run hint**, and **Path instructions** summary (Copilot + Antigravity Tier 2 files removed/written plus `.agent/mcp_config.json` status).
