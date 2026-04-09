---
name: defensive-coding
description: "Passive core skill — Resilience Matrix for error containment, edge case guards, async resilience, and loading/error/empty/success state discipline. Auto-triggers via 1% Rule when touching async operations, data fetching, list views, error handlers, or any code path that can fail at runtime."
globs: ["**/*.ts","**/*.tsx","**/*.js","**/*.jsx","**/*.php","**/*.py","**/*.go","**/*.rb","**/*.java","**/*.cs","**/*.swift","**/*.kt","**/*.vue","**/*.blade.php"]
---

# Defensive Coding Skill

This is a **passive core skill**. It activates automatically via the 1% Rule whenever the agent touches code that can fail, return empty, or produce unexpected runtime states.

## Trigger Conditions (1% Rule)

This skill fires when the task involves **any** of:
- Async operations (API calls, database queries, file I/O, queue jobs, timers)
- Data fetching hooks or server-side data loading
- List views, tables, or collections that may be empty
- Error handlers, try/catch blocks, or middleware
- User-facing forms with validation and submission states
- External service integrations (payment processors, email, SMS, webhooks)
- Loops or iterations over external or user-provided data

## Resilience Matrix

For every code change that triggers this skill, silently evaluate each applicable category. Report only FAIL items.

### 1. Error Containment

- [ ] Errors from external services are caught at the boundary and mapped to a safe, user-readable form — never propagate raw third-party error objects to clients.
- [ ] Error messages shown to users do not leak stack traces, internal paths, database errors, or raw exceptions.
- [ ] Domain errors (business rule violations) are distinguished from infrastructure errors (network, DB unavailable) in the response contract.
- [ ] `catch` blocks do not silently swallow errors — at minimum, log the error before continuing.
- [ ] Centralized error middleware / exception handler exists or is used; per-handler ad hoc error formatting is avoided.

### 2. Async Resilience

- [ ] Every async operation (API call, DB query, external service) has a defined failure path — not just a happy path.
- [ ] Promises are not fire-and-forget when failure would leave the system in an inconsistent state.
- [ ] Unhandled promise rejections are treated as bugs; `void` is not used to suppress async errors that matter.
- [ ] Timeout discipline: long-running operations have a timeout or circuit-breaker to prevent indefinite hanging.
- [ ] Jobs or background workers that fail permanently (after retries) have a dead-letter or alerting mechanism.

### 3. Edge Case Guards

- [ ] Null / undefined propagation: code that accesses properties on objects that may be null/undefined uses safe access (`?.`, null coalescing `??`, or explicit guard).
- [ ] Empty collection handling: code that iterates an array or database result set handles the empty case without throwing.
- [ ] Boundary values: integer overflow, zero division, negative indices, and off-by-one cases are considered where the input range makes them possible.
- [ ] Type coercion: implicit comparisons (`==`) and type-unsafe casts are avoided on values that cross system boundaries.
- [ ] Boolean traps avoided: functions do not take boolean flags as the primary way to switch behavior — use named strategies or separate functions.

### 4. Loading / Error / Empty / Success State Machine

Every async data flow in the UI **must** model all four states. A component that only models "success" is incomplete.

- [ ] **Loading state**: skeleton, spinner, or disabled form while data is in-flight — never show stale data without a loading indicator on refetch.
- [ ] **Error state**: a visible, actionable error message — not a blank screen, not a generic "something went wrong" without a recovery path. Tell the user *how* to fix it or what to do next.
- [ ] **Empty state**: when a collection returns zero items, show a designed empty state with context and a call-to-action (not a blank list or `null` render).
- [ ] **Success state**: the data renders correctly; optimistic updates revert on failure.

### 5. User-Facing Error UX

- [ ] Error messages use active voice and tell the user what to do, not just what failed: "Email already in use — try logging in instead" not "Error: duplicate key violation."
- [ ] Validation errors are shown inline next to the relevant field, not only as a top-level banner.
- [ ] On form submission failure, field values are preserved — the user does not have to re-enter data.
- [ ] Destructive actions that fail partially (e.g., deleting 3 of 5 items) communicate partial failure clearly.

### 6. External Service Boundaries

- [ ] Input going into an external service is validated before the call — do not let invalid data hit the external API and rely on its error for validation.
- [ ] Responses from external services are validated/parsed defensively — do not assume the shape of a third-party response.
- [ ] Credentials and API keys used by external service calls come from environment variables, never from client-side code.
- [ ] Webhook payloads are verified (signature check) before acting on them.

## Silent Evaluation Protocol

When this skill triggers, the agent must:

1. **Scan** the code change against all applicable matrix items above.
2. **Mark** each item as PASS or FAIL internally (no output to user for PASS items).
3. **Report** only FAIL items to the user with:
   - The specific matrix category (e.g., "§4 — Empty state missing")
   - The file and line range
   - A concrete fix recommendation
4. **Block** the code from being finalized until all FAIL items are resolved.

If all items PASS, proceed silently — no output needed.

## Stack-Specific Implementation Notes

This skill defines *what* to check. The active stack skill defines *how* to implement the fix:

- **Laravel**: use `app/Exceptions/Handler.php` for centralized mapping; `try/catch` in Actions; Inertia flash messages for user-facing errors.
- **MERN / Express**: use centralized error middleware `(err, req, res, next)` as the last `app.use()`; Zod for boundary validation; TanStack Query error states for frontend.
- **Next.js**: `error.tsx` / `not-found.tsx` for App Router error boundaries; Server Action `try/catch` with typed error returns; `useFormState` / `useActionState` for form error feedback.

## Cost Control

- All checks are local text/pattern analysis — no external API calls.
- No sub-agents — evaluation runs in the primary chat thread.
- Evaluate only the files being changed in this task.

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
