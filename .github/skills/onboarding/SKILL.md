---
name: onboarding
description: Repository onboarding — Fresh Start vs Legacy Integration; Legalization Scan; legacy baseline for routes/components; Line in the Sand in docs/ai. Use when the user runs /onboard, adopts Toji mid-project, or must baseline existing UI before governance. Do NOT use for routine feature work (use dev-lifecycle + plan).
globs: ["**"]
---

# Onboarding

Manage **Onboarding State** so Toji applies the right rigor: greenfield scaffolding versus **legacy grace** with a clear **Line in the Sand**.

## Modes (pick exactly one per run)

### Mode A — Fresh Start

**When:** New or greenfield project; no substantial production UI/routes yet.

**Goals:**

- Scaffold **AI doc layout** under `docs/ai/` (ensure `README.md`, `features/README.md`, `implementation/`, `testing/` exist per `docs/ai/README.md` structure).
- Record **stack intent**: recommend `/detect-stack` after first meaningful code exists.
- Set **Line in the Sand** (today’s date, ISO `YYYY-MM-DD`) in `docs/ai/README.md` under **Toji Governance** — governance applies from this date forward for *new* work.
- Update **`docs/ai/README.md` → Governance History** with **Toji installed** / **Onboarding** dates and mode (Fresh Start).
- Create `docs/ai/onboarding/onboarding-log.md` (see template below) with `mode: fresh-start`.
- Optionally seed `.github/lessons-learned.md` if missing (only when user wants project memory; do not block).

**Do not** run Legalization Scan or legacy baselines unless the user later switches to integration.

---

### Mode B — Legacy Integration

**When:** Existing app with routes, components, and styling already in flight.

**Goals:**

1. **Legalization Scan** (mandatory for this mode)
2. **Baseline the codebase** (Legacy/Accepted inventory)
3. **Line in the Sand** + onboarding log
4. Hand off to **`/onboard` prompt** for **Integrity Roadmap** and **Current State of the Union** narrative

#### 1. Legalization Scan

**Discover styling sources** (read what exists; adapt paths to the repo):

- Tailwind: `tailwind.config.js`, `tailwind.config.ts`, `tailwind.config.mjs`, `tailwind.config.cjs`
- Global / entry CSS: e.g. `resources/css/app.css`, `app/globals.css`, `src/index.css`, `assets/css/*.css`
- Component libraries that define CSS variables (note paths only if no Tailwind)

**Extract:**

- **Hex colors** (e.g. `#1a1a1a`, `#fff`) and **rgb/hsl** literals from those files
- **Spacing scale** if present: `theme.spacing`, `theme.extend.spacing`, custom keys

**Write** `docs/ai/onboarding/legacy-token-extract.md` containing:

- Scan date, list of files read
- Tables: **Colors** (value, source file, inferred role if obvious)
- Tables: **Spacing / sizing keys** (name → value) when found

If `tailwind.config.*` and global CSS are **missing**, state that in the extract file and list what was searched.

#### 2. Baseline the codebase (Legacy/Accepted)

**Write** `docs/ai/onboarding/legacy-baseline.md`:

- **Routes:** inventory from framework conventions, e.g. Laravel `routes/*.php`, Next.js `app/**/page.tsx` / `pages/**/*.tsx`, Vue router config, etc.
- **UI components:** representative glob results for `*.tsx`, `*.jsx`, `*.vue`, `*.svelte` (group by top-level folder; if huge, cap listing with note “sample + glob pattern”)
- Tag every listed path or pattern as **`Legacy/Accepted`**
- One paragraph: **Policy** — files/paths listed here (or matching listed globs) are **exempt** from full Toji **Delete Rule** / mandatory TDD retrofit **until** the user requests a **significant modification** to that file or area (see `.github/copilot-instructions.md` **Legacy Grace Period**)

#### 3. Line in the Sand

In `docs/ai/README.md`, under **Toji Governance**, set:

- **Line in the Sand (Toji governance start):** `YYYY-MM-DD` (execution date of onboarding)
- **Onboarding mode:** `Legacy Integration`
- **Links:** `onboarding-log.md`, `legacy-baseline.md`, `legacy-token-extract.md`

#### 4. Onboarding log

**Write** `docs/ai/onboarding/onboarding-log.md` using the template below.

---

## Onboarding log template

```markdown
# Onboarding log

| Field | Value |
|-------|--------|
| Date (ISO) | YYYY-MM-DD |
| Mode | fresh-start \| legacy-integration |
| Line in the Sand | YYYY-MM-DD |
| Operator | (user or agent note) |

## Artifacts

- `docs/ai/README.md` — governance block updated
- `docs/ai/onboarding/legacy-token-extract.md` — (legacy only) or N/A
- `docs/ai/onboarding/legacy-baseline.md` — (legacy only) or N/A

## Notes

- Short freeform notes for the team.
```

---

## Validation

- [ ] Mode recorded in `onboarding-log.md` and `docs/ai/README.md`
- [ ] **Line in the Sand** date is set and consistent across log + README
- [ ] Legacy mode: `legacy-token-extract.md` + `legacy-baseline.md` exist **or** explicit “no Tailwind/CSS found” documented
- [ ] Fresh mode: no false legacy baselines; docs/ai tree ready for features

---

## Coordination

- **`/onboard` prompt** produces the **Integrity Roadmap** and initializes **Current State of the Union** in `docs/ai/README.md` — this skill supplies the **mechanical** artifacts; the prompt ties them into narrative and debt backlog.
- **`scan-codebase`** should read governance from README or `onboarding-log.md` before suggesting deep feature work.
