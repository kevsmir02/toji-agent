---
name: ambiguity-resolver
description: "Passive core skill — Intercepts vague feature requests during /plan and forces structured clarification of ambiguities before an implementation plan is generated. Prevents wasted tokens on incorrect plans by resolving edge cases first."
globs: []
---

# Ambiguity Resolver Skill

This is a **passive core skill**. It activates automatically whenever the agent receives a feature request that lacks sufficient precision to safely produce an implementation plan. It acts as a mandatory gate **before** any `/plan` output is written.

## Trigger Conditions (1% Rule)

This skill activates when ANY of the following are true:

- The user initiates `/plan`, `/requirements`, or requests a feature implementation without explicit details.
- The feature request omits any of: error handling strategy, authentication/authorization constraints, database storage approach, pagination behavior, or edge case specifics.
- The codebase has an existing related feature that the new request could conflict with.
- The language of the request is high-level and aspirational (e.g., "add a cart", "build a user profile", "integrate payments").

## Clarification Protocol

When triggered, the agent **must halt** all planning and execute this protocol:

### Step 1 — Context Scan (Silent)
Before asking anything, silently:
1. Read `docs/ai/README.md` to understand the current project state.
2. Search the codebase for any existing implementation related to the request.
3. Read the relevant database schema or model files.
4. Identify what is **known** vs what is **ambiguous**.

### Step 2 — Minimal Question Set
Ask **2 to 3 highly specific, non-obvious questions** that directly block the plan from being safely written. These must be:
- **Concrete**, not vague (e.g., "Should un-authenticated users who add items to cart have those items persisted after login?" not "How should authentication work?")
- **Sequenced**: ask the most critical questions first — only questions whose answers change the architecture of the plan.
- **Non-redundant**: never ask something that can be inferred from the codebase or `docs/ai/README.md`.

**Good examples:**
- "The existing `User` model uses UUID primary keys. Should the new `Order` table use UUID or auto-increment integers?"
- "If a payment fails mid-checkout, should the cart items be preserved or cleared?"
- "Should bulk-importing products via CSV notify all admins immediately or batch-notify at midnight?"

**Bad examples (forbidden):**
- "What tech stack should I use?" (inferable from `detect-stack`)
- "Should I add tests?" (Iron Law — always yes)
- "Do you want pagination?" (Iron Law — always yes on list endpoints)

### Step 3 — Wait for Answers
Do not proceed to `/plan` or write **any** code until the user has answered all clarification questions. Once answered, proceed immediately without asking further questions.

## Edge Cases

- If the request is **Trivial scope** (per `dev-lifecycle`), skip this skill entirely — do not ask clarifying questions about clearly self-contained tasks.
- If `docs/ai/features/` already contains a feature brief for this exact feature, skip Step 2 — the spec is already written.

## Cost Control

- All context scanning is local file reads only — no external API calls.
- No sub-agents — runs in the primary chat thread.
- Evaluate only the most relevant 2-3 files — do not scan the entire `#codebase`.

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
