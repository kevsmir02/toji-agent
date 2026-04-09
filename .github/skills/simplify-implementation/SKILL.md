---
name: simplify-implementation
description: "YAGNI gate and complexity enforcer — scores code for nesting depth, duplication, over-abstraction, and function length before and after refactoring. Use when running /refactor, when the Code Quality Iron Law fires, or when reviewing implementation choices for unnecessary complexity."
globs: ["**/*.ts","**/*.tsx","**/*.js","**/*.jsx","**/*.php","**/*.py","**/*.go","**/*.rb","**/*.java","**/*.cs","**/*.swift","**/*.kt","**/*.vue"]
---

# Simplify Implementation Skill

Enforce the Code Quality Iron Law: **readability first, YAGNI always**. Stop over-engineering before it ships.

## When to Activate

- When `/refactor` is triggered by the user
- When the Code Quality Iron Law fires during an implementation review
- When a planning review finds a proposed design is more complex than the problem warrants
- Passively: when adding a new abstraction layer, service class, helper module, or utility function

## YAGNI Gate (Non-Negotiable)

Before adding **any** abstraction (helper function, service class, trait/mixin, interface, wrapper, utility module), answer:

1. **Is this used in more than one place right now?** If no → inline it.
2. **Does the spec explicitly require this abstraction?** If no → defer it.
3. **Is the abstracted thing actually different from its call sites?** If no (just renaming) → it's noise, not abstraction.

If all three answers are "no" — do not create the abstraction. Write the code inline and document why no abstraction was needed in the `What changed` section.

## Complexity Signals (Review Checklist)

Evaluate the changed code against these signals before and after changes:

### Nesting Depth
- [ ] No function has more than **3 levels of nesting** (conditionals, loops, callbacks).
- [ ] If nesting exceeds 3 levels, extract the innermost into a named function with a descriptive name.
- [ ] Guard clauses (early returns) are preferred over deeply nested if-else trees.

### Function Length
- [ ] No function exceeds **50 lines** (excluding blank lines and comments).
- [ ] A function that exceeds 50 lines is doing more than one thing — split it at the natural seam.
- [ ] Constructors and render functions that exceed 80 lines are subject to the same rule.

### Class / Module Size
- [ ] No class has more than **7 public methods** (excluding constructor, getters/setters for simple DTO-like objects).
- [ ] A class with more than 7 public methods likely has multiple responsibilities — apply Single Responsibility.
- [ ] Avoid "God classes" or "God services" that accumulate logic from unrelated features over time.

### Duplication
- [ ] Identical or near-identical logic blocks appearing in **2 or more places** must be extracted.
- [ ] "Near-identical" means the same sequence of operations with only literal values differing — parameterize, don't copy.
- [ ] Copy-paste with minor modifications is always a duplication violation; extract a shared form with parameters.

### Over-Engineering Warnings
- [ ] A factory that produces only one concrete type — remove the factory.
- [ ] An interface with only one implementation — remove the interface unless extension points are required by spec.
- [ ] A service/helper that wraps a single method call without adding logic — inline the call.
- [ ] A DTO/ViewModel that only redistributes properties with identical names — evaluate if it adds contract value.
- [ ] Event classes with no additional behavior beyond a name — use a typed constant instead.

### Boolean Parameters
- [ ] No function uses a boolean parameter as a behavior flag (`createUser(admin: true)`).
- [ ] Split into two functions (`createAdminUser()`, `createRegularUser()`) or use a named enum/type.

## Refactor Workflow

When `/refactor` is triggered:

1. **Baseline** — Measure the target file/function against the checklist. Document current signals (nesting depth, function count, line count, duplication count).
2. **Identify** — Pick the one highest-impact simplification (not all of them at once).
3. **Apply** — Make the change. Run tests. Confirm green.
4. **Measure** — Re-check the signal that was targeted. Confirm it improved.
5. **Stop** — Do not refactor beyond the original scope of the task. One improvement at a time.

## What Not to Simplify

- Do not simplify code that is complex **because the domain is complex** — domain complexity is legitimate.
- Do not simplify performance-critical code that is intentionally verbose for cache/memory reasons — document why.
- Do not apply this checklist to generated code, migration files, or vendor/library code.
- Legacy code under the Legacy Grace Period is exempt from YAGNI enforcement on existing lines.

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
