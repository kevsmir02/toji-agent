---
name: stack-mern
description: Strict conventions for MERN (MongoDB, Express, React, Node) projects. Use when the active stack profile is `mern`.
---

# MERN Standards

Apply these rules as authoritative when this skill is active.

## Architecture Rules

- Keep route handlers thin: validation + delegation only.
- Put business logic in service/use-case modules.
- Keep persistence in repository/data-access modules.
- Separate concerns clearly: `routes -> controllers -> services -> repositories`.
- Avoid framework leakage across layers.

## Backend (Node + Express) Conventions

- Use a consistent module structure by feature domain.
- Validate request payloads with a schema validator (e.g., Zod/Joi) at boundaries.
- Use centralized error middleware and standardized error response format.
- Never block event loop with heavy sync work; move heavy work to background jobs/workers.
- Keep config in environment variables with typed parsing/validation at startup.

## Data Layer (MongoDB) Conventions

- Define explicit schema constraints in Mongoose.
- Add indexes for frequently queried fields and unique constraints where required.
- Avoid unbounded queries; always paginate list endpoints.
- Avoid overfetching: use projections/select and lean queries when appropriate.
- Use transactions/session when mutating multiple documents that must stay consistent.

## Frontend (React) Conventions

- Keep components focused: container components manage data, presentational components render UI.
- Use a predictable data-fetching strategy (React Query/RTK Query/fetch layer) consistently.
- Co-locate feature UI + hooks + tests by domain.
- Model loading, empty, error, and success states explicitly.
- Use TypeScript interfaces/types for API contracts when possible.

## Security

- Validate and sanitize all input.
- Enforce auth + role/ownership checks server-side for protected resources.
- Never trust client role flags.
- Use rate limiting for sensitive/public endpoints.
- Hash passwords with strong algorithms and secure config.
- Keep JWT/session secrets out of source control.

## Testing Expectations

- Unit tests for services and utility logic.
- Integration tests for API routes (validation, auth, error paths).
- Repository/data tests for query behavior and edge cases.
- Frontend component tests for key states and interactions.
- Regression tests for every fixed defect.

## Code Review Checklist

- Is business logic isolated from controllers/routes?
- Are all request bodies/params validated?
- Are queries indexed, bounded, and projected appropriately?
- Are auth/authorization checks enforced server-side?
- Do tests cover both expected and failure paths?

## Suggested Structure

- `src/modules/<feature>/routes.ts`
- `src/modules/<feature>/controller.ts`
- `src/modules/<feature>/service.ts`
- `src/modules/<feature>/repository.ts`
- `src/modules/<feature>/schema.ts`
- `src/modules/<feature>/__tests__/`

## If Unsure

Prefer explicit boundaries and simpler flows over clever abstractions.
