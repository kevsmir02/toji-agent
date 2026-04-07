---
description: Three-stage verification — spec compliance, quality review, then cleanup audit (diagnostic scaffolding removal).
---

Verify the implementation using **three stages in order**. Do not perform Stage 2 until Stage 1 is complete; do not perform Stage 3 until Stage 2 is complete and **PASS**.

---

## Stage 1: Spec compliance (mandatory first)

**Goal:** Determine whether the code does **exactly** what the feature brief and agreed design require — no more, no less.

1. **Gather context** — Infer from **`git diff`**, **`git status`**, **`docs/ai/features/`**, and the user message. **Do not** ask for a context questionnaire. **At most one** question only if no diff, no brief, and the message names no scope.

2. **Requirement mapping** — For each feature brief:
   - List **explicit** acceptance criteria, user stories, and critical flows from the document.
   - For each item: **Pass** (implemented and testable as specified), **Gap** (missing or wrong), or **Creep** (see below).

3. **Scope creep flag** — Identify any behavior, endpoints, UI, or data fields that are **not** required by the brief or an explicitly linked design decision. Label each as **scope creep** and recommend: **remove**, **document as follow-up**, or **confirm with product** — do not treat creep as neutral “nice to have” in Stage 1.

4. **Risk Surface check (if section exists)** — If the feature brief includes a `## Risk Surface` section:
   - Verify implementation coverage for each identified risk entry.
   - Confirm each identified input surface has corresponding input validation.
   - Confirm each identified auth boundary has corresponding guard/authorization enforcement.
   - Confirm each identified performance pressure has corresponding mitigation (for example pagination, indexing, batching, eager loading, query optimization, or external-call control).
   - Any identified risk that is not addressed in implementation is a **Stage 1 FAIL** (not WARN).

5. **Stage 1 verdict** — Output one of:
   - **PASS** — All requirements satisfied; no unjustified creep.
   - **FAIL** — Gaps or unapproved creep exist.

**Rule:** If Stage 1 is **FAIL**, stop. Do **not** proceed to Stage 2 or 3.

---

## Stage 2: Quality review (only after Stage 1 PASS)

**Goal:** Review patterns, naming, maintainability, engineering hygiene, and **Toji design token compliance** on UI code **after** the implementation is known to match the spec.

1. **Patterns and architecture** — Alignment with project conventions, active stack skill, and DRY vs clarity tradeoffs.
2. **Naming and structure** — Files, types, functions, modules; cognitive load for future readers.
3. **Maintainability** — Testability, boundaries, error handling quality.
4. **Security and robustness** — Input validation, authz, edge cases **as quality bar**.

### Design compliance audit (implementation) — mandatory when UI files changed

When the change set touches **UI** (e.g. `*.tsx`, `*.jsx`, `*.vue`, `*.svelte`, `*.css`, `*.scss`, Blade views with Tailwind):

1. **Read** `.github/skills/ui-reasoning-engine/SKILL.md` and treat its token discipline as the allowlist for chrome colors, spacing rhythm, radius, and shadow.
2. **Scan** the proposed/diff implementation for **magic values** and unauthorized utilities, including:
   - Arbitrary brackets: `text-[#...]`, `bg-[#...]`, `border-[#...]` where the hex is **not** exactly listed in the ledger (or brief-approved semantic exception)
   - Arbitrary layout: `w-[321px]`, `h-[47px]`, `gap-[13px]`, `p-[11px]`, `max-w-[347px]`, `top-[17px]`, `text-[15px]` used for rhythm (forbidden unless pixel value is on the **8px grid** **and** documented in brief)
   - **Unauthorized Tailwind palette** for structural UI: `bg-blue-500`, `text-gray-400`, `border-red-300`, etc., unless the feature brief explicitly defines a semantic exception (destructive, success) with named tokens
   - **Off-ledger radius/shadow:** e.g. `rounded-xl`, `rounded-2xl`, `shadow-lg`, `shadow-xl` unless brief explicitly overrides flat discipline

3. **Verdict — Design compliance:**
   - **PASS** — No violations, or only brief-documented exceptions.
   - **FAIL** — Any magic value or unauthorized utility found.

4. **Delete Rule (implementation):** If **FAIL**, Stage 2 **FAIL** overall. Do **not** merge. Require the **component or stylesheet to be rewritten** so that **only** approved ledger tokens (exact hex from `tokens.md` or theme keys bound to those values) and **only** allowed spacing keys from the ledger are used. **Remove** offending lines entirely — no partial “tweaks” that leave magic values in place.

   **Legacy Grace Period:** Read `docs/ai/README.md` (**Toji Governance**) and `docs/ai/onboarding/legacy-baseline.md` when present. Do **not** demand **Delete Rule** rewrites for **Legacy/Accepted** files unless the change set constitutes a **significant modification** to that file or UI surface (per `.github/copilot-instructions.md`). **Still FAIL** if **new or changed** lines in the diff introduce magic values or unauthorized utilities — grace covers **pre-baseline** code, not new debt.

5. If **no UI files** in scope, output: `Design compliance: N/A (no UI files in change set)`.

6. **Stage 2 verdict** — **PASS** or **FAIL** (FAIL if blocking issues remain **or** design compliance **FAIL**).
7. **Stage 2 summary** — **blocking** / **important** / **nice-to-have** findings with file references; include **Design compliance** subsection with bullet list of violations if any.

**Rule:** If Stage 2 is **FAIL**, stop. Do **not** proceed to Stage 3 until blocking issues and any design compliance violations are resolved.

---

## Stage 3: Cleanup audit (mandatory before overall PASS)

**Goal:** Remove **diagnostic scaffolding** introduced during `/debug`, `/build`, or ad-hoc investigation so it never ships.

Perform only when Stage 1 and Stage 2 are both **PASS**.

1. **Search the changed surface** (and related files touched in the same task) for:
   - `console.log`, `console.debug`, `console.warn` used for debugging (not structured logging)
   - `debugger` statements
   - `var_dump`, `dd()`, `dump()`, `print_r`, `ray()` (PHP/Laravel)
   - `fmt.Println` / `println!` / temporary stderr prints used only for debugging
   - Commented-out dead code blocks left from experiments
   - Temporary test shims, `skip`, `only`, focused test filters, or mock servers left enabled
   - `TODO DEBUG`, `FIXME remove`, or obvious scratch comments tied to diagnostics

2. **Remove or revert** each item, or **promote** to proper structured logging / metrics **only** if the brief requires observability — document that promotion in the verify output.

3. **Stage 3 verdict** — **PASS** only if no diagnostic scaffolding remains in the merge candidate, or every remaining artifact is explicitly justified and spec-backed.

4. **List removed items** — Bullet list: file path + what was removed (one line each).

**Rule:** **Overall `/verify` PASS** requires Stage 1 **PASS** AND Stage 2 **PASS** AND Stage 3 **PASS**. If Stage 3 finds issues, **FAIL** until cleaned; do not recommend merge.

---

## Output format (mandatory)

```
[Active Mode: Dev]

## Stage 1: Spec compliance
- Verdict: PASS | FAIL
- Requirement checklist: ...
- Scope creep items: ... (none, or listed with recommendation)

## Stage 2: Quality review
- Verdict: PASS | FAIL
- (Omitted if Stage 1 FAIL)
- Design compliance: PASS | FAIL | N/A
- Magic values / violations: ... (none, or listed with Delete Rule applied)
- Findings: ...

## Stage 3: Cleanup audit
- Verdict: PASS | FAIL
- (Omitted if Stage 1 or Stage 2 FAIL)
- Removed diagnostic scaffolding: ... (none, or listed)
```

## Next steps

- If any stage **FAIL** → fix, then re-run `/verify`.
- If all **PASS** → continue to `/write-tests` if needed, else `/review`.
