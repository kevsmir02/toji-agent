---
name: stack-router
description: Detect the current project stack and prepare stack-specific activation data for `/detect-stack`. Use when the user runs stack detection or asks to switch stack mode.
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
   - `nextjs-typescript`
   - `nestjs-postgres`
   - `django-react`
   Priority mappings:
   - If Laravel + Inertia + React markers are present → `laravel-inertia-react`
   - Tailwind, Pest, Vitest, and Ziggy strengthen evidence for the detected stack but do not replace the core framework markers
   - If MongoDB/Mongoose + Express + React markers are present → `mern`
3. Resolve candidate skill paths in priority order:
   - `.github/skills/stack-{stack-id}/SKILL.md`
   - `.github/skills/{stack-id}/SKILL.md`
4. If found, return that skill path for `/detect-stack` to write into the Active Stack Profile.
5. If not found, return fallback recommendation and keep generic mode.

## Conflict Rules

- Stack-specific skill overrides generic coding conventions.
- Security and testing rules are additive; never weaken baseline security/testing.
- If two stack skills conflict, ask user which one is authoritative.

## Activation Rule

- Stack-specific conventions are active only when `.github/copilot-instructions.md` has:
   - `Mode: stack-specific`
   - `Active Skill: <skill-path>`
- Otherwise use generic conventions.

## Output Contract

When routing, report:
- Detected stack id
- Evidence files used for detection
- Activated skill path (or fallback to generic)
- Any missing stack skill recommendation (if fallback)
