---
name: simplify-implementation
description: Complexity reduction protocol — identify nesting, duplication, tight coupling, and over-abstraction in existing code, then propose and apply targeted simplifications. Enforces a hard rule: no changes until the user approves a plan. Use when code already exists and needs to be made cleaner, smaller, or easier to read. Do NOT use when the goal is to add new behaviour or fix a broken feature (use debug for broken code).
globs: ["**"]
---

# Simplify Implementation Assistant

Reduce complexity with an analysis-first approach before changing code.

## Hard Rules
- Do not modify code until the user approves a simplification plan.
- Readability over brevity. Some duplication beats the wrong abstraction.

## Readability Principles

**Good code reads like a book — naturally, from left to right, top to bottom.**

**DO:**
- Linear flow: read top-to-bottom without jumping around
- Explicit over implicit: clear code over clever shortcuts
- Meaningful names: purpose obvious without comments
- Consistent patterns throughout the codebase
- Single abstraction level per function
- Logical grouping with blank lines between blocks

**AVOID:**
- Nested ternaries (`a ? b ? c : d : e`) → use explicit if/else
- Chained one-liners (`.map().filter().reduce()`) → use named intermediate steps
- Short variable names (`x`, `y`) → use descriptive names (`users`, `activeUsers`)
- Magic one-liners → use documented steps
- Premature DRY (abstracting 2-3 lines of duplication) → some duplication is clearer

**The Reading Test** — all four must be "yes" before accepting a simplification:
1. Can a new team member understand this in under 30 seconds?
2. Does the code flow naturally without jumping to other files?
3. Are there any "wait, what does this do?" moments?
4. Would this code still be clear 6 months from now?

## Workflow

1. **Gather Context** — Confirm targets, pain points, and constraints (compatibility, API stability, deadlines).
2. **Analyze Complexity** — Identify sources (nesting, duplication, coupling, over-engineering, magic values). Assess impact (LOC, dependencies, cognitive load, scalability blockers).
3. **Propose Simplifications** — For each issue, apply a pattern:
   - **Extract**: Long functions → smaller, focused functions
   - **Consolidate**: Duplicate code → shared utilities
   - **Flatten**: Deep nesting → early returns, guard clauses
   - **Decouple**: Tight coupling → dependency injection, interfaces
   - **Remove**: Dead code, unused features, excessive abstractions
   - **Replace**: Complex logic → built-in language/library features
   - **Defer**: Premature optimization → measure-first approach
4. **Prioritize and Plan** — Rank by impact/risk. Present plan with before/after snippets. Request approval.
5. **Validate** — Verify no regressions, add tests for new helpers, and strictly evaluate the refactored code against the `security` and `performance` skill checklists.

## Output Template
- Target and Context
- Complexity Analysis
- Simplification Proposals (prioritized)
- Recommended Order and Plan
- Scalability Recommendations
- Validation Checklist

## Session closure — Atomic Instinct (mandatory)

Use **`.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts** as the single source of truth for lesson capture and closure behavior.

- Do not duplicate or override lesson-capture criteria in this skill.
- After user-approved refactors and validation, apply the global auto-capture rule in the same response as the final change summary.
