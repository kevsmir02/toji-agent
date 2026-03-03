---
name: stack-laravel-inertia-react
description: Strict conventions for Laravel + React + Inertia projects. Use when the active stack profile is `laravel-inertia-react`.
---

# Laravel + React + Inertia Standards

Apply these rules as authoritative when this skill is active.

## Architecture Rules

- Keep controllers thin: request validation + orchestration only.
- Put business logic in service classes/actions, not controllers or Inertia pages.
- Use Form Requests for validation (never inline validation in controllers).
- Use policies/gates for authorization (never rely only on UI checks).
- Use Inertia as the API boundary for web flows; keep payloads explicit and minimal.

## Backend (Laravel) Conventions

- Follow PSR-12 style and framework naming conventions.
- Return typed data structures from services (arrays/DTO-like payloads), not raw model internals.
- Prefer route model binding and scoped queries.
- Wrap multi-step writes in database transactions.
- Prevent N+1 by eager loading relationships intentionally.
- Use queued jobs for heavy/slow side effects (emails, external API calls, report generation).
- Centralize domain errors and map them to user-safe messages.

## Frontend (React + Inertia) Conventions

- Page components orchestrate; shared UI components stay presentational.
- Keep server state from Inertia props as source of truth; avoid duplicating it into local state unless necessary.
- Use typed props/interfaces for every page and shared component.
- Keep forms predictable: explicit defaults, validation display, submit pending states.
- Avoid leaking backend-only concepts into UI components.

## Data & Security

- Validate all inbound request data with Form Requests.
- Authorize every mutating endpoint.
- Never trust client-provided identifiers without ownership/tenant checks.
- Protect against mass-assignment: explicit `$fillable`/`$guarded` strategy.
- Store secrets in environment variables only.

## Testing Expectations

- Feature tests for HTTP/inertia behavior and authorization paths.
- Unit tests for service/domain logic.
- Test validation failures and edge cases for every write path.
- Add regression tests for bug fixes before or alongside the fix.

## Code Review Checklist

- Any business logic in controllers/pages? Move to services/actions.
- Any unbounded queries or missing eager loads?
- Are validation + authorization both enforced on write endpoints?
- Do Inertia pages receive only the props they need?
- Are tests covering happy path + critical failures?

## Preferred Folder Patterns

- `app/Http/Controllers/*` → orchestration only
- `app/Http/Requests/*` → validation rules
- `app/Services/*` or `app/Actions/*` → business logic
- `resources/js/Pages/*` → Inertia pages
- `resources/js/Components/*` → reusable presentational UI

## If Unsure

Prefer the option that keeps domain logic in backend services and keeps UI components simple.
