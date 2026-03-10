---
name: stack-laravel-inertia-react
description: Strict conventions for Laravel + React + Inertia projects. Use when the active stack profile is `laravel-inertia-react`.
---

# Laravel + React + Inertia Standards

Apply these rules as authoritative when this skill is active.

## Authoritative Rules

- Controllers are orchestration-only. They may authorize, validate, call an Action, and return an Inertia response/redirect, but must not contain business logic.
- Business logic MUST live in single-responsibility classes under `app/Actions/*`.
- Raw Eloquent models MUST NOT be passed to Inertia. Controller payloads must be mapped through typed Data Objects/DTOs first.
- Every Inertia Page MUST define a corresponding TypeScript interface that matches the backend Data Object/DTO shape.
- Use Ziggy `route()` helpers exclusively for application routes. Hardcoded URLs are forbidden in both backend-generated links and frontend usage.

## Architecture Rules

- Keep controllers thin: authorize, validate, delegate, and return an Inertia response or redirect.
- Put business logic in single-responsibility Action classes, not controllers or Inertia pages.
- Prefer `app/Actions/*` over generic `app/Services/*` for feature use cases. Use service classes only for reusable infrastructure adapters or third-party integrations.
- Use Form Requests for validation (never inline validation in controllers).
- Use policies/gates for authorization (never rely only on UI checks).
- Use Inertia as the API boundary for web flows; keep payloads explicit and minimal.
- Use DTOs or data objects for Controller-to-Inertia transfer. Prefer Spatie Laravel Data or typed DTO/ViewModel classes over passing raw models or ad hoc arrays.
- Share named routes across PHP and JavaScript with Ziggy. Use the `route()` helper in both layers instead of hardcoded URLs.

## Backend (Laravel) Conventions

- Follow PSR-12 style and framework naming conventions.
- Controllers should call an Action, then map the result into a DTO/data object for the Inertia response.
- Return typed payloads from Actions and data objects, not raw model internals.
- Prefer route model binding and scoped queries.
- Wrap multi-step writes in database transactions.
- Prevent N+1 by eager loading relationships intentionally.
- Use queued jobs for heavy/slow side effects (emails, external API calls, report generation).
- Centralize domain errors and map them to user-safe messages.
- Prefer dedicated `Data`, `DTO`, or `ViewModel` classes in `app/Data/*`, `app/DTOs/*`, or a clearly named equivalent.

## Frontend (React + Inertia) Conventions

- Page components orchestrate; shared UI components stay presentational.
- Keep server state from Inertia props as source of truth; avoid duplicating it into local state unless necessary.
- Use typed props/interfaces for every page and shared component, matching the DTO/data-object shape returned by Laravel.
- Keep forms predictable: explicit defaults, validation display, submit pending states.
- Generate links, visits, and form targets with Ziggy's `route()` helper from `ziggy-js` or the project's shared route helper setup.
- Do not embed hardcoded route strings, controller paths, or backend-only naming assumptions in React components.
- Avoid leaking backend-only concepts into UI components.

## Data & Security

- Validate all inbound request data with Form Requests.
- Authorize every mutating endpoint.
- Never trust client-provided identifiers without ownership/tenant checks.
- Protect against mass-assignment: explicit `$fillable`/`$guarded` strategy.
- Map Eloquent models to DTO/data objects before exposing them to Inertia when shape, authorization, or serialization rules matter.
- Store secrets in environment variables only.

## Testing Expectations

- Prefer Pest for backend tests when available.
- Feature tests for HTTP/Inertia behavior, authorization paths, and route-to-page contracts.
- Unit tests for Actions, DTO/data-object transformations, and domain logic.
- Frontend tests should use Vitest when present for page/component behavior and client-side interaction logic.
- Test validation failures and edge cases for every write path.
- Add regression tests for bug fixes before or alongside the fix.

## Code Review Checklist

- `/build` must be blocked if controllers include business logic instead of delegating to `app/Actions/*`.
- `/build` must be blocked if any business rule is not implemented in a single-responsibility Action class.
- `/build` must be blocked if raw Eloquent models are passed to Inertia instead of typed Data Objects/DTOs.
- `/build` must be blocked if an Inertia page does not have a matching TypeScript interface aligned to the backend Data Object/DTO shape.
- `/build` must be blocked if any hardcoded URL exists where Ziggy `route()` should be used.
- Any unbounded queries or missing eager loads?
- Are validation + authorization both enforced on write endpoints?
- Do Inertia pages receive only the props they need?
- Are tests covering happy path + critical failures?

## Preferred Folder Patterns

- `app/Http/Controllers/*` → orchestration only
- `app/Http/Requests/*` → validation rules
- `app/Actions/*` → feature-level business logic
- `app/Data/*` or `app/DTOs/*` → typed payloads for Inertia and domain boundaries
- `app/Services/*` → integrations, shared infrastructure, or adapter logic only
- `resources/js/Pages/*` → Inertia pages
- `resources/js/Components/*` → reusable presentational UI

## If Unsure

Prefer the option that keeps domain logic in backend Actions, contracts explicit through DTO/data objects, routes centralized through Ziggy, and UI components simple.
