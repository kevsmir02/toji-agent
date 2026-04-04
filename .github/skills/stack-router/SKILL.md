---
name: stack-router
description: Stack detection protocol — scan config files and dependencies, build a normalized stack ID, resolve the matching skill path, return activation data for the Active Stack Profile, and (for /detect-stack) regenerate Tier 2 path-specific .github/instructions/toji-stack-*.instructions.md plus .agent/rules/toji-stack-*.md. Also perform MCP-aware recommendations and Antigravity mcp_config update when applicable. Use exclusively when running /detect-stack or when the user explicitly asks to identify or switch the project stack. Do NOT use during normal coding — stack conventions come from the already-activated stack skill.
globs: ["package.json","composer.json","pyproject.toml","go.mod","*.config.*","*.lock"]
---

# Stack Router

Resolve stack-specific standards when explicitly triggered.

## Goal

Keep this template generic by default while enabling strict stack conventions on demand.

## Detection Protocol

1. Scan repository markers in this order:
   - **Backend/runtime**: `composer.json`, `package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`, `pom.xml`, `build.gradle`
   - **Framework markers**: `artisan`/`laravel` deps, Inertia packages, `next.config.*`, `nuxt.config.*`, `svelte.config.*`, `vite.config.*`, `rails` files
   - **Frontend markers**: React/Vue/Svelte/Angular dependencies, `tailwind.config.*`, `postcss.config.*`
   - **Testing markers**: `tests/Pest.php`, Pest packages, `vitest.config.*`, Vitest dependencies
   - **Routing markers**: Ziggy packages or generated route helpers
   - **Infra markers**: `docker-compose.yml`, `terraform`, `k8s` manifests
2. Build a normalized stack id, examples:
   - `laravel-inertia-react`
   - `mern`
   - `react-native-bare`
   - `nextjs-typescript`
   - `nestjs-postgres`
   - `django-react`
   Priority mappings:
   - If Laravel + Inertia + React markers are present → `laravel-inertia-react`
   - Tailwind, Pest, Vitest, and Ziggy strengthen evidence for the detected stack but do not replace the core framework markers
   - If MongoDB/Mongoose + Express + React markers are present → `mern`
   - If `package.json` contains `react-native` and does not include `expo` as a direct dependency, and `android/` or `ios/` exists at repo root, and `metro.config.js` or `react-native.config.js` is present → `react-native-bare`
3. Resolve candidate skill paths in priority order:
   - `.github/skills/stack-{stack-id}/SKILL.md`
   - `.github/skills/{stack-id}/SKILL.md`
4. If found, return that skill path for `/detect-stack` to write into the Active Stack Profile.
5. If not found, return fallback recommendation and keep generic mode.

## Conflict Rules

- Stack-specific skill overrides generic coding conventions.
- Security and testing rules are additive; never weaken baseline security/testing.
- If two stack skills conflict, **prefer the path with stronger file evidence** from the Detection Protocol; **ask the user only if** evidence is genuinely tied.

## Activation Rule

- Stack-specific conventions are active only when `.github/copilot-instructions.md` has:
   - `Mode: stack-specific`
   - `Active Skill: <skill-path>`
- Otherwise use generic conventions.

## MCP Awareness (mandatory in `/detect-stack`)

After stack id is resolved, assess **Beneficial MCP Servers** for the detected ecosystem and report recommendations:

- `laravel-inertia-react` (or Laravel markers): include `laravel-boost` (`php artisan boost:mcp`).
- `mern` (or Node/Mongo markers): suggest `mongodb-mcp` and/or `node-logs-mcp`.
- Any stack: suggest `github-mcp` and/or `fetch-mcp` for external documentation.

If Antigravity is active (project has `.agent/` governance and stack detection is executed for Antigravity workflows), `/detect-stack` must **generate or update** `.agent/mcp_config.json`:

1. Start from existing `.agent/mcp_config.json` if present; else seed from `.agent/mcp_config.template.json` when available.
2. Merge recommended servers into `mcpServers` without deleting user-defined servers.
3. Default newly added recommended servers to `enabled: false` unless user requested auto-enable.
4. Keep existing server values when keys already exist (non-destructive update).

## Tier 2 path instructions + Antigravity rules (`/detect-stack`)

After the Active Stack Profile is updated in **the same response**, **`/detect-stack`** must update Tier 2 artifacts using **diff-and-patch** (not blind delete/rewrite).

1. Build a **desired manifest** of Tier 2 files for the detected stack across:
   - `.github/instructions/toji-stack-*.instructions.md`
   - `.agent/rules/toji-stack-*.md`
2. Enumerate the **existing manifest** from disk for the same Tier 2 patterns.
3. For each desired file:
   - Generate proposed content.
   - Compare against current file using content hash (preferred) or mtime+size heuristic.
   - If content matches, **skip write**.
   - If content differs or file is missing, write/update that file only.
4. For existing Tier 2 files absent from desired manifest, delete only those stale files.
5. If **Mode** is **`generic`** or no stack **`SKILL.md`** exists, desired manifest is empty; only stale Tier 2 files are removed.

### Strict wrapper contract (no logic creep)

- Tier 2 files are wrappers only and must point back to `.github/skills/*/SKILL.md`.
- `.agent/rules/toji-stack-*.md` must contain only minimal metadata plus a 1-line skill pointer body.
- Do not duplicate stack logic, rules, or workflows inside IDE-specific wrappers.

6. If **`.git/info/exclude`** does **not** already contain **`.github/instructions/toji-stack-*.instructions.md`**, append that line **once**.
7. If **`.git/info/exclude`** does **not** already contain **`.agent/rules/toji-stack-*.md`**, append that line **once**.
8. If **`.git/info/exclude`** does **not** already contain **`.agent/*.json`**, append that line **once**.

**Generation matrix (examples — infer from evidence; extend analogously for new stack skills):**

Detection matrix addition:

react-native-bare:
- Detection signals: `package.json` contains `react-native` without `expo` as a direct dependency; `android/` or `ios/` folder exists at project root; `metro.config.js` or `react-native.config.js` present
- Stack ID: `react-native-bare`
- Active Skill: `.github/skills/stack-react-native-bare/SKILL.md`
- Tier 2 globs: `**/*.tsx,**/*.ts` (excluding `node_modules/`, `android/`, `ios/`)

| Stack ID (example) | Copilot file | Antigravity file | Globs / `applyTo` (example) | Skill path (example) |
|--------------------|-------------|-------------------|-----------------------------|------------------------|
| `laravel-inertia-react` | `toji-stack-php.instructions.md` | `toji-stack-php.md` | `**/*.php` | `.github/skills/stack-laravel-inertia-react/SKILL.md` |
| `laravel-inertia-react` | `toji-stack-tsx.instructions.md` | `toji-stack-tsx.md` | `**/*.tsx,**/*.jsx` | `.github/skills/ui-reasoning-engine/SKILL.md` |
| `mern` | `toji-stack-js-ts.instructions.md` | `toji-stack-js-ts.md` | `**/*.js,**/*.jsx,**/*.ts,**/*.tsx` | `.github/skills/stack-mern/SKILL.md` |
| `react-native-bare` | `toji-stack-rn-ts.instructions.md` | `toji-stack-rn-ts.md` | `**/*.tsx,**/*.ts` (excluding `node_modules/`, `android/`, `ios/`) | `.github/skills/stack-react-native-bare/SKILL.md` |

For other stack ids with a matching **`stack-*/SKILL.md`**, emit doublet wrappers per **primary source extensions** and apply diff-and-patch semantics.

**Invisible Governance:** **`toji-stack-*.instructions.md`** and **`toji-stack-*.md`** are excluded locally via **`install.sh` / `update.sh`**. Tier 1 shippables (no `toji-stack-` prefix) stay committable in the framework repo.

## Output Contract

When routing, report:
- Detected stack id
- Evidence files used for detection
- Activated skill path (or fallback to generic)
- Any missing stack skill recommendation (if fallback)
- **Re-run hint:** Recommend **`/detect-stack`** again when **either** (a) **`.github/lessons-learned.md`** `## Instincts` mentions frameworks, databases, or runtimes **not** reflected in the current **Active Skill** / **Stack ID**, **or** (b) **new** primary framework/runtime dependencies appear in `package.json`, `composer.json`, or the repo’s main lockfile **since** **Last Detected** in the profile (use file mtimes or version bumps as signal—lightweight, not a full audit).
- **Path instructions:** Confirm Tier 2 regeneration: which **`toji-stack-*.instructions.md`** and **`toji-stack-*.md`** files were removed and which were written (or “none — generic mode”), matching this section’s rules.
- **MCP recommendations:** List beneficial MCP servers for the detected stack and state whether `.agent/mcp_config.json` was generated/updated (or skipped with reason).
