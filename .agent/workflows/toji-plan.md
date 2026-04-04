---
description: "Plan workflow for Canonical + Derived Mirror architecture."
---

# Workflow: Toji Plan

Purpose: translate Toji /plan behavior into Antigravity workflow execution.

## Inputs

- User request
- docs/ai/README.md
- docs/ai/implementation/artifact-hierarchy.md
- Existing docs/ai/features/*.md briefs
- Applicable skills (always check dev-lifecycle first)

## Outputs

### Canonical Outputs

- docs/ai/features/{name}.md (feature brief when scope requires)

### Derived Mirror Outputs

- .agent/implementation_plan.md (derived execution mirror, never policy source)
- .agent/task.md (execution checklist and next action)
- Routing rationale line for the active task

## Steps

1. Run the IDE "List Tools" command and record active MCP tools.
2. Read docs/ai/implementation/artifact-hierarchy.md before planning.
3. Mandatory current-state verification: use available MCP tools (for example DB schema, routes, logs, REPL/tinker) to confirm project facts before planning.
4. Classify scope using .github/skills/dev-lifecycle/SKILL.md.
5. Infer feature name in kebab-case from request context.
6. If scope is Medium+, write or update docs/ai/features/{name}.md before generating mirrors.
7. Build implementation_plan.md as a derived mirror using the canonical feature brief as source:
   - Problem, goals, non-goals
   - User scenarios and acceptance criteria
   - Architecture and key decisions
   - Risk surface (Small+ scope)
   - Delivery plan with explicit file paths and verification commands
8. Update task.md with ordered checkboxes that map to delivery tasks.
9. Emit profile rationale line per `docs/ai/governance-core.md` before substantive content.

## Guardrails

- Single-shot planning; at most one blocking question.
- No unresolved placeholder markers.
- Apply the 1% Rule before writing plan content.
- Prohibit Guessing: if an MCP tool can provide a fact, do not rely on internal memory or local files for that fact.
