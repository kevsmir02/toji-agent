---
description: Manual override for Atomic Instinct capture — force one strict rule append when auto-capture would reject it (preferences, team conventions, business rules). Single-shot.
---

Run **`/lesson`** as a **manual override** when you want to force project memory capture that the automatic lesson filter would likely reject.

**Single-shot:** Infer the lesson from the session, message, and recent edits; produce the instinct and file append in **one** response. **Do not** ask for confirmation before drafting — the user can correct in a follow-up if wrong.

## Goal

Analyze the **current session** (or the slice the user points to): user preferences, team conventions, business rules, or explicit guidance that should persist even if it is not a broad engineering instinct.

Produce **exactly one Atomic Instinct** — a **single** concise rule a future session can apply without re-reading the whole chat.

## Rules for an Atomic Instinct

- **One rule only** per `/lesson` invocation (if multiple lessons apply, run `/lesson` again or split into separate bullets in one append operation only if the user explicitly asks for multiple).
- **Mandatory tag format:** `- [#category] Title: Atomic lesson.` where `#category` is one of `#arch`, `#fix`, `#perf`, `#ux`, `#stack`.
- **Imperative voice:** e.g. “Always validate X before Y”, “Never call Z without holding W”.
- **No placeholders:** forbidden: `TODO`, `TBD`, vague “be careful with…”.
- **Testable:** another engineer can check compliance without guessing.
- **Max ~2 sentences** or one long sentence — not a paragraph.
- `/lesson` is **not** the default capture path; automatic capture runs after every task via `copilot-instructions.md`.
- **De-duplication required:** scan the matching category section before append; if equivalent insight exists, do not append.

## Bad vs good

- Bad: *“We had some issues with the API.”*
- Good: *“Before merging any PR that touches `billing/`, run `pnpm test:billing` — integration tests are the only guard for idempotency keys.”*

## Actions

1. **Infer context** — One-line summary of the override reason (preference/convention/business rule), then proceed.
2. **Select category** — Choose one category tag from `#arch`, `#fix`, `#perf`, `#ux`, `#stack`.
3. **Draft the instinct** — Final tagged form only; no preamble in the file.
4. **De-duplicate** — If a matching lesson already exists, politely report the existing entry and skip append.
5. **Append to** `.github/lessons-learned.md` under the matching category section (new bullet, preserve existing bullets).
6. **Confirm** — Show the new bullet or the duplicate match you detected.

## Next steps

- Next task: Copilot will load instincts automatically per `copilot-instructions.md`.
- Optionally run `/document` with Session Handover if this lesson changes roadmap or state.
