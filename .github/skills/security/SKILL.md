---
name: security
description: "Passive core skill — OWASP-aligned security boundary discipline. Auto-triggers via 1% Rule when touching auth, input handling, routes, uploads, queries, or data exposure. Silently evaluates a Threat Matrix before presenting code."
globs: ["**/*.php","**/*.ts","**/*.tsx","**/*.js","**/*.jsx","**/*.py","**/*.go","**/*.rb","**/*.java","**/*.cs","**/*.swift","**/*.kt","**/*.vue","**/*.blade.php"]
---

# Security Audit Skill

This is a **passive core skill**. It activates automatically via the 1% Rule whenever the agent touches security-sensitive code. You do not need to invoke it manually.

## Trigger Conditions (1% Rule)

This skill fires when the task involves **any** of:
- Risk Surface includes input surface, auth boundary, or data exposure
- Authentication or authorization flows (login, registration, password reset, OAuth)
- API route creation or modification
- User-facing forms or file upload handling
- Database queries that accept user-controlled input
- Middleware, guards, or access control changes
- Environment variables, secrets, or credential handling
- Error response formatting visible to end users

## OWASP Top 10 Threat Matrix

For every code change that triggers this skill, the agent must **silently evaluate** each applicable category below. No output is shown to the user unless a FAIL is detected.

### 1. Injection (A03)
- [ ] All user-controlled input is parameterized or escaped before reaching SQL, OS commands, LDAP, or template engines.
- [ ] No string concatenation in query construction.
- [ ] ORM or query builder used exclusively for database access.

### 2. Broken Authentication (A07)
- [ ] Authentication endpoints enforce rate limiting or lockout.
- [ ] Passwords are hashed with bcrypt/argon2 — never stored in plaintext or MD5/SHA1.
- [ ] Session tokens are regenerated after login.
- [ ] Password reset tokens are single-use and time-limited.

### 3. Sensitive Data Exposure (A02)
- [ ] No secrets, API keys, or credentials hardcoded in source files.
- [ ] Sensitive data is not logged (passwords, tokens, PII).
- [ ] HTTPS enforced for sensitive endpoints.
- [ ] Error responses do not expose stack traces, internal paths, or raw DB errors.

### 4. Broken Access Control (A01)
- [ ] Every new or modified route has explicit authorization middleware/guard.
- [ ] No reliance on client-side checks for server-side authorization.
- [ ] Resource ownership verified before access (e.g., user can only edit their own records).
- [ ] No IDOR (Insecure Direct Object Reference) — IDs validated against the authenticated user.

### 5. Security Misconfiguration (A05)
- [ ] Debug mode is off in production configuration.
- [ ] Default credentials are not present.
- [ ] CORS is restrictive, not wildcard (`*`).
- [ ] Directory listing is disabled.

### 6. Cross-Site Scripting / XSS (A03)
- [ ] User input is escaped before rendering in HTML/templates.
- [ ] Framework's built-in XSS protection is not bypassed (e.g., `{!! !!}` in Blade, `dangerouslySetInnerHTML` in React).
- [ ] Content-Security-Policy headers are considered for new pages.

### 7. Mass Assignment (Framework-specific)
- [ ] Models touched by user input have explicit `$fillable` or `$guarded` (Laravel), `attr_accessible` (Rails), or equivalent.
- [ ] No `request()->all()` passed directly to `create()`/`update()` without whitelisting.

### 8. File Uploads
- [ ] MIME type validated server-side (not client-side only).
- [ ] Files stored outside the web root.
- [ ] Filenames randomized — never trust client-provided names.
- [ ] File size limits enforced server-side.

### 9. SQL Safety
- [ ] No raw SQL with user input (use parameterized queries or ORM).
- [ ] `whereRaw`, `DB::raw`, or equivalent calls are audited for injection paths.

### 10. Secrets Management
- [ ] All credentials come from environment variables or secret managers.
- [ ] `.env` files are in `.gitignore`.
- [ ] No API keys in frontend JavaScript bundles.

## Silent Evaluation Protocol

When this skill triggers, the agent must:

1. **Scan** the code change against all applicable matrix items above.
2. **Mark** each as PASS or FAIL internally (no output to user for PASS items).
3. **Report** only FAIL items to the user with:
   - The specific matrix category (e.g., "A01 — Broken Access Control")
   - The file and line range
   - A concrete fix recommendation
4. **Block** the code from being finalized until all FAIL items are resolved.

If all items PASS, proceed silently — no output needed.

## Cost Control

- All checks are local text/pattern analysis — no external API calls.
- No sub-agents — evaluation runs in the primary chat thread.
- No recursive scanning — evaluate only the files being changed in this task.

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
