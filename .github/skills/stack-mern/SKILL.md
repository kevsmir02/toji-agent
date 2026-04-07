---
name: stack-mern
description: Authoritative architecture rules for MERN — thin Express handlers, Use Case classes, Zod-first schemas, ts-rest or tRPC contracts, centralized error middleware, Mongoose conventions, Vitest frontend tests. Apply ONLY when the Active Stack Profile in copilot-instructions.md shows Mode: stack-specific and Stack ID: mern. Overrides generic coding conventions for all TypeScript and JavaScript files in that stack.
globs: ["**/*.ts","**/*.js","**/routes/**","**/models/**","**/services/**","**/components/**"]
---

# MERN Standards

Apply these rules as authoritative when this skill is active.

## Architecture Rules

- Keep route handlers thin: validate, authorize, delegate, and serialize the response only.
- Put complex business logic in single-responsibility Use Case or Command classes, not generic service blobs.
- Keep persistence in repository/data-access modules.
- Enforce end-to-end type safety for API boundaries with `ts-rest`, `tRPC`, or a shared `types` package consumed by both Express and React.
- Use Zod as the canonical schema source for request/response contracts, inferred TypeScript types, and Mongoose model definitions.
- Standardize error handling through the `defensive-coding` skill — see `.github/skills/defensive-coding/SKILL.md` for the Resilience Matrix governing error containment, edge case guards, and user-facing error UX.
- Separate concerns clearly: `routes -> controllers -> use-cases -> repositories`.
- Avoid framework leakage across layers.

## Backend (Node + Express) Conventions

- Use a consistent module structure by feature domain.

### Middleware Order

- Express middleware must be registered in this order: body parsing -> CORS -> rate limiting -> auth -> routes -> 404 handler -> error handler.
- Error handler middleware must be the last `app.use()` call and must use the 4-argument signature `(err, req, res, next)`.
- In Express 4, async route handlers must catch and forward errors via `next(err)`; in Express 5 this is automatic. Verify the project version before choosing a pattern.

- Define request, response, and domain schemas in Zod first. Infer TypeScript types from those schemas instead of hand-writing duplicate interfaces.
- Validate all params, query strings, bodies, and environment config with Zod at system boundaries.
- If using `ts-rest`, define the contract once and implement Express handlers against that contract.
- If using `tRPC`, keep routers thin and delegate domain logic to Use Cases or Commands.
- Use centralized error middleware and a standardized JSON error response format such as `{ error: { code, message, details?, requestId? } }`. See `defensive-coding` skill for the full Resilience Matrix.
- Never block event loop with heavy sync work; move heavy work to background jobs/workers.
- Keep config in environment variables with typed parsing/validation at startup.
- Define a single `config.ts` module at project root that parses and validates all environment variables with Zod at startup; fail fast on missing or invalid variables.
- Never call `process.env.X` directly outside the `config.ts` module.
- Define CORS configuration in one place; never scatter `cors()` calls.
- If credentials are required for cookie-based auth, pair `credentials: true` with an explicit origin allowlist; never use `origin: '*'`.
- Prefer feature-local `contract.ts`, `schema.ts`, and `use-case.ts` style modules over catch-all utility folders.

## Data Layer (MongoDB) Conventions

- Define Zod schemas as the source of truth, then keep Mongoose schemas derived from or strictly aligned to those same constraints.
- Keep persistence validation, API validation, and inferred TypeScript types synchronized from the same Zod schema set.
- Define explicit schema constraints in Mongoose.
- Add indexes for frequently queried fields and unique constraints where required.
- Avoid unbounded queries; always paginate list endpoints.
- Avoid overfetching: use projections/select and lean queries when appropriate.
- Use `.lean()` on read-only queries that do not need Mongoose document methods.
- Never use `.populate()` across more than one level deep; restructure schema or perform manual lookup for deeper joins.
- Do not store arrays that grow unboundedly in a single document; use a separate collection with references.
- Always cast `_id` to string when crossing API boundaries; do not assume frontend handling of raw ObjectId types.
- Use transactions/session when mutating multiple documents that must stay consistent.

## Frontend (React) Conventions

- Keep components focused: container components manage data, presentational components render UI.
- Use TanStack Query (React Query) for all server state; if the project already uses SWR, continue with SWR.
- Do not mix fetching strategies.
- Read existing `package.json` before choosing the fetch strategy.
- Never use raw `useEffect + fetch` for data that requires caching, refetching, or loading states.
- Co-locate `useQuery`/`useMutation` hooks in a `hooks/` or `api/` directory per feature domain; do not inline query logic in components.
- Prefer `ts-rest` clients, `tRPC` clients, or a typed shared API layer over ad hoc `fetch` wrappers with duplicated types.
- Co-locate feature UI + hooks + tests by domain.
- Model loading, empty, error, and success states explicitly — see `defensive-coding` skill for edge case guards and async resilience requirements.
- Consume API contracts through inferred types from the shared contract layer rather than manually duplicated frontend interfaces.

## Security

- Validate and sanitize all input.
- Enforce auth + role/ownership checks server-side for protected resources.
- Never trust client role flags.
- Never return MongoDB `_id`, `__v`, or internal persistence fields in API responses; use explicit projection or serializers.
- Sanitize user input before passing it into Mongoose queries to prevent operator injection (for example `$where`, `$gt` in query params).
- Use rate limiting for sensitive/public endpoints.
- Hash passwords with strong algorithms and secure config.
- Keep JWT/session secrets out of source control.

## Testing Expectations

- Unit tests for Use Cases, Commands, repositories, and contract helpers.
- Integration tests for API routes and procedures (validation, auth, error paths, contract adherence).
- Repository/data tests for query behavior and edge cases.
- Frontend tests should use Vitest when present for components, hooks, client adapters, and contract-driven data flows.
- Add contract tests where `ts-rest`, `tRPC`, or shared types define critical request/response behavior.
- Regression tests for every fixed defect.

## Code Review Checklist

- Is business logic isolated from controllers/routes and implemented as Use Cases or Commands?
- Are request/response contracts shared end-to-end through `ts-rest`, `tRPC`, or a shared types package?
- Is Zod the single source of truth for validation and inferred types?
- Does centralized error middleware map failures into a stable JSON error format?
- Are queries indexed, bounded, and projected appropriately?
- Are auth/authorization checks enforced server-side?
- Do tests cover both expected and failure paths?

## Suggested Structure

- `src/modules/<feature>/routes.ts`
- `src/modules/<feature>/controller.ts`
- `src/modules/<feature>/use-case.ts`
- `src/modules/<feature>/command.ts`
- `src/modules/<feature>/repository.ts`
- `src/modules/<feature>/schema.ts`
- `src/modules/<feature>/contract.ts`
- `src/middleware/error-handler.ts`
- `src/modules/<feature>/__tests__/`

## If Unsure

Prefer explicit contracts, Zod-first schemas, thin handlers, centralized error mapping, and narrowly scoped Use Cases over clever abstractions.
