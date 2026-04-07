---
name: api-design
description: API contract discipline for endpoint behavior, response structure, status codes, versioning, and pagination. Use when building or modifying API endpoints, API controllers, or API resources.
globs: ["**/routes/**","**/controllers/**","**/*Controller*","**/handlers/**","**/endpoints/**"]
---

# API Design Assistant

Design and implement API behavior consistent with existing project contracts.

## Trigger conditions

Use this skill via the 1% Rule when:
- Building or modifying API endpoints/routes.
- Editing API controllers or API resources/transformers.
- Changing request/response contracts or error payloads.

## Core rules

### Response structure
- Read existing API responses first (prefer `#codebase`) before introducing structure changes.
- Use the established project envelope consistently (for example `{ data, message, status }` if that is the project pattern).

### HTTP verbs
- `GET` reads.
- `POST` creates.
- `PUT`/`PATCH` updates.
- `DELETE` removes.
- Do not invent custom verb conventions.

### Status codes
- Use the standard mapping correctly:
  - `200` success
  - `201` created
  - `204` no content
  - `400` bad request
  - `401` unauthenticated
  - `403` unauthorized
  - `404` not found
  - `422` validation error
  - `500` server error

### Versioning
- If the project uses API versioning (for example `/api/v1/`), new endpoints must follow the existing version namespace.

### Error responses
- Include both:
  - Human-readable message
  - Machine-readable error code
- Never return an error with HTTP status alone.

### Pagination
- All collection endpoints must be paginated.
- Never return unbounded arrays from API list endpoints.

## Verification checklist

- Contract shape matches existing API conventions.
- Verb/status code pairing is correct.
- Version namespace is respected.
- Error payload includes message + code.
- Collection endpoints are paginated.

## Session closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
