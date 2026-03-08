---
description: Detect project stack and update active stack profile for stack-specific mode.
---

Detect the current project stack and update `.github/copilot-instructions.md` so stack mode is explicitly activated.

1. **Scan Stack Markers** — Identify runtime, framework, testing, contract, and frontend markers from files such as `composer.json`, `package.json`, `pyproject.toml`, `go.mod`, `tailwind.config.*`, `vite.config.*`, `vitest.config.*`, `tests/Pest.php`, framework configs, and lockfiles.
   - Record notable evidence like Laravel, Inertia, React, Tailwind, Pest, Vitest, Ziggy, Vite, Express, MongoDB, TypeScript, Zod, `tRPC`, and `ts-rest` when present.
2. **Build Stack ID** — Normalize to a kebab-case id (e.g. `laravel-inertia-react`, `mern`, `nextjs-typescript`).
   - If Laravel + Inertia + React markers exist, use `laravel-inertia-react`.
   - Treat Ziggy, Tailwind, Pest, and Vitest as corroborating evidence when they appear alongside the core Laravel/Inertia/React markers.
   - If MongoDB/Mongoose + Express + React markers exist, use `mern`.
   - Treat Zod, Vitest, `tRPC`, and `ts-rest` as strong MERN ecosystem evidence.
   - If both a Laravel web stack and a MERN stack are present, prioritize `mern` when the MERN markers include core backend/frontend evidence plus Zod, Vitest, `tRPC`, or `ts-rest`.
3. **Resolve Skill** — Check for these files in order:
   - `.github/skills/stack-{stack-id}/SKILL.md`
   - `.github/skills/{stack-id}/SKILL.md`
4. **Update Active Stack Profile** in `.github/copilot-instructions.md`:
   - If a skill is found, set:
     - `Mode: stack-specific`
     - `Stack ID: <detected-stack-id>`
     - `Active Skill: <resolved-skill-path>`
     - `Last Detected: <YYYY-MM-DD>`
   - If no skill is found, set:
     - `Mode: generic`
     - `Stack ID: <detected-stack-id>`
     - `Active Skill: none`
     - `Last Detected: <YYYY-MM-DD>`
5. **Activation Rule**
   - Do not apply stack-specific conventions unless `Mode` is `stack-specific` in `.github/copilot-instructions.md`.
6. **Report** — Return:
   - Detected stack id
   - Evidence files and markers used
   - Updated profile values written to `.github/copilot-instructions.md`
   - Suggested skill name/path to create if missing
