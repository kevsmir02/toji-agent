---
name: performance
description: Performance discipline for query-heavy or high-throughput work — enforce no N+1, pagination, index awareness, loop safety, and bounded API payloads. Use when touching database queries, API endpoints, data processing, or when Risk Surface flags performance pressure.
globs: ["**/queries/**","**/models/**","**/repositories/**","**/services/**","**/*.sql"]
---

# Performance Assistant

Apply performance-first implementation discipline before and during code changes.

## Trigger conditions

Use this skill via the 1% Rule when:
- Working on database queries, ORM relations, controllers/services/repositories, API endpoints, or data-processing paths.
- The feature brief Risk Surface includes a performance pressure entry.
- The change can alter query shape, cardinality, or response size.

## Core rules

### Query discipline
- No N+1 query patterns.
- Eager-load required relationships when iterating related data.
- Paginate collection endpoints and list views.
- Avoid `SELECT *` on large tables; select only required columns.

### Index awareness
- Any new `WHERE`, `ORDER BY`, or foreign key column should have an index unless a documented reason says otherwise.
- If no index is added, document why in the feature brief or What changed.

### Loop discipline
- Do not perform database calls inside loops.
- Batch reads/writes where possible.
- Prefer bulk operations over per-record mutations.

### Response size
- API responses must not return unbounded collections.
- Use pagination or explicit limits for all collection payloads.

### Caching signals
- If a query/result is an obvious caching candidate, flag it in What changed.
- Do not add caching unless the feature brief explicitly requires it.

## Verification checklist

- Confirm no N+1 hotspots were introduced.
- Confirm pagination/limits exist for collection responses.
- Confirm index implications were handled or documented.
- Confirm loops do not issue per-item queries.

## Session closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
