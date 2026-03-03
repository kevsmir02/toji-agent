---
description: Refactor existing code to reduce complexity and improve maintainability.
---

Help me simplify an existing implementation while maintaining or improving its functionality.

1. **Gather Context** — If not already provided, ask for: target file(s) or component(s) to simplify, current pain points (hard to understand, maintain, or extend?), constraints (backward compatibility, API stability, deadlines), and relevant design docs.
2. **Analyze Complexity** — For each target: identify complexity sources (deep nesting, duplication, unclear abstractions, tight coupling, over-engineering, magic values), assess cognitive load for future maintainers, and identify scalability blockers.
3. **Propose Simplifications** — Prioritize readability over brevity. Apply the 30-second test: can a new team member understand each change quickly? For each issue, suggest concrete improvements with before/after snippets:
   - **Extract**: long functions → smaller focused functions
   - **Consolidate**: duplicate code → shared utilities
   - **Flatten**: deep nesting → early returns, guard clauses
   - **Decouple**: tight coupling → dependency injection, interfaces
   - **Remove**: dead code, unused features, excessive abstractions
   - **Replace**: complex logic → built-in language/library features
4. **Prioritize & Plan** — Rank by impact vs risk. Present a prioritized action plan with recommended execution order. Request approval before making changes.
5. **Validate** — Verify no regressions, add tests for new helpers, update docs if interfaces changed.
6. **Next Steps** — After implementation, run `/check-implementation` and `/writing-test`.
