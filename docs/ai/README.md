# AI Docs

Use `docs/ai/` as the written source of truth for product intent, architecture, delivery, and operational concerns.

## Current State of the Union

*Summary of features and logic that are **100% functional** (verified behaviors, tests, entry points). Update after `/onboard` or Session Handover (`/document`).*

- *(Not yet captured — run `/onboard` or document verified state.)*

## Backlog of Intent

*Technical tasks defined by the Architect for the **Builder** to execute next (ordered steps, dependencies, blockers).*

- *(Not yet captured — maintain from feature briefs and Session Handover.)*

## Governance History

*Living log of Toji adoption and legacy legalization.*

| Event | Date (ISO) | Notes |
|-------|------------|--------|
| **Toji installed** | *Run `install.sh`; record date here.* | Invisible Governance: exclude + `pre-commit` active. |
| **Onboarding** | *Run `/onboard`; record date + mode.* | Line in the Sand; see **Toji Governance** below. |

### Legalized Legacy modules

*Routes, components, or areas baselined as **Legacy/Accepted** during **Legacy Integration** (see `docs/ai/onboarding/legacy-baseline.md`). List high-signal modules here for quick reference.*

- *(None until Legacy Integration onboarding produces `legacy-baseline.md`.)*

---

## Maintenance Policy (Living Memory)

`docs/ai/` is the **living memory** of the product: feature briefs, implementation notes, onboarding artifacts, and governance state. Under **Invisible Governance** (`install.sh`), this tree is listed in **`.git/info/exclude`** so it stays **on the developer’s machine** and does not appear in the **client-facing Git history**.

- Treat everything here as **local working context** unless your team has explicitly chosen to **“Publicize Toji”** and removed exclusions/hooks.
- Back up or sync `docs/ai/` through your own means if you need redundancy — do not rely on the client remote for this data.

## Toji Governance

| Field | Value |
|-------|--------|
| **Onboarding mode** | *Not set — run `/onboard` (Fresh Start or Integration).* |
| **Line in the Sand (Toji governance start)** | *Not set — run `/onboard`.* |
| **Onboarding log** | `docs/ai/onboarding/onboarding-log.md` (created by `/onboard`) |

**Legacy Grace Period:** After Legacy Integration onboarding, code baselined as **Legacy/Accepted** in `docs/ai/onboarding/legacy-baseline.md` is not subject to the verify **Delete Rule** until that file or area receives a **significant modification** (see `.github/copilot-instructions.md`).

## Structure

- `features/{name}.md` — primary feature brief combining requirements, design, and delivery plan
- `implementation/{name}.md` — optional deep implementation notes, setup details, and integration specifics
- `testing/{name}.md` — optional test strategy, coverage notes, and manual validation checklist
- `deployment/README.md` — deployment checklist and environment notes (create when needed)
- `monitoring/README.md` — metrics, alerting, and incident response guidance (create when needed)

## Scope-Tiered Workflow

Classify scope before choosing a workflow. See `.github/skills/dev-lifecycle/SKILL.md` for the canonical workflow table and Lite Lane definition.

## Prompt Reference

- `/plan` — create or update a feature brief
- `/requirements` — requirements discovery (Medium+ scope)
- `/review-plan` — validate feature brief completeness (Large scope)
- `/design-db` — database schema design with Mermaid ERD (Large scope, recommended at Medium with schema changes)
- `/review-design` — validate technical design (Large scope)
- `/build` — implement task by task
- `/verify` — confirm implementation matches requirements/design (includes cleanup audit)
- `/write-tests` — add and validate test coverage
- `/review` — pre-push review against requirements and design
- `/redesign` — UI/UX overhaul (visual audit + data contract check + functional minimalist React updates)
- `/refactor` — delegates to `simplify-implementation` skill (required first if `/redesign` identifies backend contract changes)
- `/lesson` — record an Atomic Instinct in `.github/lessons-learned.md`
- `/document` — documentation + Session Handover to this file when closing major work
- `/onboard` — Fresh Start or Legacy Integration; Line in the Sand, Legalization Scan (integration), Integrity Roadmap

## Integrity Roadmap

*Created or refreshed by `/onboard` (especially Legacy Integration). Design/token debt and test gaps to fix incrementally — not mandatory bulk rewrites.*

- *(Prioritized items: now / next / later.)*

## Legacy Layout

Older Toji templates split feature work across `requirements/`, `design/`, and `planning/`.
This template consolidates those concerns into `features/{name}.md` to reduce duplication and drift.
