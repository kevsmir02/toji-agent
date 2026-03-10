# AI Docs

Use `docs/ai/` as the written source of truth for product intent, architecture, delivery, and operational concerns.

The default process now uses mandatory design gates before implementation, plus a dedicated UI/UX redesign path.

## Structure

- `features/{name}.md` — primary feature brief combining requirements, design, and delivery plan
- `implementation/{name}.md` — optional deep implementation notes, setup details, and integration specifics
- `testing/{name}.md` — optional test strategy, coverage notes, and manual validation checklist
- `deployment/README.md` — deployment checklist and environment notes
- `monitoring/README.md` — metrics, alerting, and incident response guidance

## Prompt Workflows

- `/plan` — create the initial feature brief in `features/{name}.md`
- `/requirements` — mandatory requirements-discovery gate (Interrogator-style data gap check)
- `/review-plan` — validate brief completeness after requirements discovery
- `/design-db` — mandatory technical design gate for normalized schema + Mermaid ERD
- `/review-design` — validate technical design readiness before coding
- `/build` — implement only after both mandatory gates pass
- `/verify` — confirm implementation matches requirements/design
- `/write-tests` — add and validate test coverage
- `/review` — pre-push review against requirements and design
- `/redesign` — dedicated UI/UX overhaul workflow (visual audit + data contract check + functional minimalist React updates)
- `/refactor` — required first if `/redesign` identifies backend contract changes (Action/Controller updates)

## Default Workflow

1. Start with `features/{name}.md` via `/plan`
2. Run `/requirements` as a mandatory gate to discover missing fields and hidden constraints
3. Run `/review-plan` and resolve gaps
4. Run `/design-db` and produce a Mermaid ERD as a mandatory technical design gate
5. Run `/review-design` and resolve all blocking design issues
6. Implement with `/build` only after requirements and technical design gates pass
7. Validate with `/verify`, then run `/write-tests` and `/review`
8. Keep docs aligned in `features/`, `implementation/`, and `testing/` as changes land

## UI/UX Redesign Workflow

Use `/redesign` when the primary goal is visual/interaction quality rather than net-new feature scope.

1. Run a Visual Audit against the UX and frontend skill standards
2. Run a Data Contract Check on Inertia props/API payloads
3. If backend fields must change, run `/refactor` first to update the Action/Controller contract
4. Deliver updated React UI aligned to the Notion-inspired Functional Minimalist system (soft-gray baseline `#131314`, modular block structure, restrained contrast)

## Legacy Layout

Older Toji templates split feature work across `requirements/`, `design/`, and `planning/`.
This template consolidates those concerns into `features/{name}.md` to reduce duplication and drift.