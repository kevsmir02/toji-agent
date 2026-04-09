---
name: deployment-safety
description: "Deployment discipline for migrations, rollback safety, feature flags, health checks, and zero-downtime patterns. Auto-triggers via 1% Rule when touching database migrations, deploy config, CI/CD workflows, or environment configuration."
globs: ["**/migrations/**","**/*Migration*","**/database/migrations/**","**/deploy*","**/Dockerfile","**/docker-compose*","**/.github/workflows/**","**/ci/**","**/.env*","**/config/database*","**/flyway*","**/liquibase*"]
---

# Deployment Safety Skill

Touching a migration or deploy config is a high-stakes operation. This skill ensures that every deployment-affecting change is safe to ship, safe to rollback, and does not require downtime.

## Trigger Conditions (1% Rule)

This skill fires when the task involves **any** of:
- Creating or modifying database migrations
- Changes to deployment configuration (Dockerfile, docker-compose, CI/CD workflows)
- Environment variable additions or changes
- Changes that affect the app's startup sequence or health check behavior
- Feature work that modifies data shape in a way that requires a migration

---

## Migration Safety

### The Golden Rule: Every Deploy Must Be Rollback-Safe

A deployment is rollback-safe when:
1. The *new code* works with *both the old schema* and *the new schema* (during the rollout window)
2. Rolling back the code does not make the new schema break the old code
3. Data migrations are reversible or their data loss is explicitly accepted and documented

### Non-Locking Migration Patterns

Large tables (> 100k rows) require non-blocking migrations:

**Adding a column (safe)**:
```sql
-- Step 1: Add column nullable (no rewrite, no lock on most DBs)
ALTER TABLE orders ADD COLUMN shipped_at TIMESTAMP NULL;
-- Application deploys — now writes shipped_at
-- Step 2 (next deploy): Add NOT NULL + DEFAULT after backfill
ALTER TABLE orders ALTER COLUMN shipped_at SET NOT NULL;
```

**Never do in a single deploy on a large table**:
- `ADD COLUMN ... NOT NULL` without a default — requires table rewrite
- `ALTER COLUMN` type change on an indexed column
- `ADD CONSTRAINT ... CHECK` without `NOT VALID` + separate `VALIDATE CONSTRAINT`

### Column Removal Pattern (Non-Destructive)
1. **Deploy 1**: Remove code references to the column (column still exists in DB)
2. **Deploy 2**: Remove the column in migration (application no longer reads/writes it)
Never drop a column in the same deploy as the code change that stops using it.

### Rename Pattern
1. **Deploy 1**: Add new column, write to both old and new, read from old
2. **Deploy 2**: Backfill new column, switch reads to new column
3. **Deploy 3**: Remove writes to old column
4. **Deploy 4**: Drop old column
Renames via a single `RENAME COLUMN` migration are only safe if the application is fully stopped during deploy.

### Checklist for Every Migration

- [ ] Is this migration reversible? If not, document why and explicitly accept the data loss / non-reversibility.
- [ ] Does this migration lock the table? If so, is the table small enough that this is acceptable (< 100k rows with minimal traffic)?
- [ ] Does the code deployed *with* this migration work if the migration has not run yet? (deploy window)
- [ ] Does the code deployed *before* this migration work after it runs? (rollback window)
- [ ] Are indexes added `CONCURRENTLY` (Postgres) or using the non-blocking equivalent for the target DB?
- [ ] Is there a `down` migration that reverses this change?

---

## Feature Flags

Use feature flags for any change that:
- Affects a significant portion of users and cannot be easily rolled back via code
- Involves a customer-facing behavior change that stakeholders want to toggle
- Is being shipped incrementally (dark launch, percentage rollout, A/B test)
- Has downstream dependencies that may not be ready at deploy time

### Implementation Rules
- Feature flag checks belong in the business logic / service layer — not scattered through controllers and view templates.
- Use a centralized `FeatureFlag` service or library, not ad hoc environment variable checks.
- Default flag state is **off** — a new flag that has not been explicitly enabled should not activate new behavior in production.
- Document each flag in `docs/ai/features/` or a flag registry: flag name, purpose, owner, and intended removal date.
- Clean up flags within 2 weeks of full rollout — permanent flags are a code smell.

---

## Health Checks

Every deployable service must expose a health endpoint:

```
GET /health         → { status: "ok", version: "1.2.3", timestamp: "..." }
GET /health/ready   → { status: "ok" } or 503 if not ready to serve traffic
GET /health/live    → { status: "ok" } or 503 if the process should be restarted
```

### Rules
- `/health/ready` should check dependent services (DB connection, cache connectivity) — return 503 if any critical dependency is unavailable.
- `/health/live` (liveness) should only check that the process itself is functioning — not DB health. Failing liveness causes the orchestrator to restart the container.
- Health endpoints must **not** require authentication.
- Health endpoints must **not** expose sensitive information (connection strings, internal IPs, secret values).

---

## Zero-Downtime Deployment Checklist

Before shipping any change, verify:

- [ ] **Rolling deploy compatible**: new code works with old schema and old code works with new schema (see migration safety above).
- [ ] **Graceful shutdown**: the app handles `SIGTERM` by finishing in-flight requests before exit (configurable drain timeout, typically 30s).
- [ ] **Connection draining**: load balancer removes the instance from rotation before shutdown, giving in-flight requests time to complete.
- [ ] **Startup health gate**: the deployment tool waits for `/health/ready` to return 200 before routing traffic to new instances.
- [ ] **Rollback plan documented**: if deploy fails, what is the exact rollback procedure? Is it a one-command rollback or a manual recovery?

---

## Environment Configuration

### Environment Parity
- Staging must mirror production in config *shape* (same environment variable names, same external service integrations with sandbox credentials).
- Document environment-specific overrides (e.g., email delivery disabled in staging) explicitly — do not rely on developers knowing the differences.
- Differences between staging and production are bugs by default unless documented as intentional.

### Secret Management Rules
- [ ] All secrets come from environment variables or a secret manager (Vault, AWS Secrets Manager, 1Password Secrets Automation) — never hardcoded.
- [ ] Secrets have a documented rotation plan — at minimum, describe how to rotate without downtime.
- [ ] New environment variables added in code must be documented in `.env.example` with placeholder values and a comment explaining the purpose.
- [ ] Secrets are never logged, even at debug level.

---

## CI/CD Pipeline Discipline

- Migrations must run **before** new application code is deployed — never after. The deploy pipeline is: `migrate → deploy-new-code → verify-health`.
- If migration fails, the deploy must abort — do not deploy new code against a failed migration.
- CI must run the full test suite (including integration tests against a test DB) before any deploy to production.
- Production deploys must require a passing build on main — no manual "hotfix" bypasses without an incident record.

---

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
