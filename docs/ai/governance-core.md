## Iron Laws (Non-Negotiable)

- **1% Rule**: If there is even a small chance a skill applies, load that skill before acting.
- **TDD Iron Law**: Write a failing test first, observe its failure, then implement. Delete any production code written before a failing test exists.
- **Research-First Iron Law**: Before writing integration code for any framework, API, or external service, perform a documentation lookup and cite the source.
- **Security Iron Law**: When touching auth, input handling, routes, uploads, queries, external systems, UI states, or async operations, silently evaluate the OWASP Threat Matrix and Resilience Matrix. Block code with any FAIL result.
- **Code Quality Iron Law**: Prioritize readability and YAGNI. Silently evaluate for nesting, duplication, over-abstraction, N+1 queries, unbounded loops, and correct HTTP verbs/status codes/pagination. Block code with any FAIL result.
- **UI Reasoning Engine Iron Law**: Verify a design system exists and adhere strictly to its tokens. Block generic or hallucinated Tailwind classes.
- **Delete Rule**: When verify/design compliance fails for new or changed lines, remove violating code and rewrite with approved tokens/patterns.
- **RCA Rule**: For debugging, collect evidence and identify root cause before applying a fix.
- **Ambiguity Iron Law**: Before planning any feature request that lacks architectural specifics, trigger the `ambiguity-resolver` skill and ask 2–3 precise clarifying questions.
- **Baseline Validation Iron Law**: After a plan is approved and before `/build`, silently run the `baseline-validator` skill. Auto-rewrite any violating plan sections before proceeding.
- **Physical Memory Iron Law**: For any task classified as Small scope or larger, generate `.agent/implementation_plan.md` before coding and `.agent/task.md` before executing. Update task.md checkboxes (`[ ]` → `[/]` → `[x]`) after completing each logical unit of work. On session start, read `.agent/task.md` first to recover position. When all tasks are `[x]`, delete both files to clear the mission slate. Trivial scope is exempt.
- **Spirit = Letter Rule**: Violating the letter of these rules is violating the spirit. There is no "following the spirit of TDD" while skipping the failing test. There is no "following the spirit of RCA" while skipping Phase 1. There is no "following the spirit of verification" without running the command. The process IS the discipline — you cannot honor the intent by skipping the steps.


