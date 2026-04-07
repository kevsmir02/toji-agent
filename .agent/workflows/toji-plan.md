---
description: "Plan workflow for Canonical + Derived Mirror architecture with Physical Memory enforcement."
---

# Workflow: Toji Plan

Purpose: translate Toji /plan behavior into Antigravity workflow execution. Enforce Physical Memory creation for Small+ scope.

## Inputs

- User request
- docs/ai/README.md
- docs/ai/implementation/artifact-hierarchy.md
- Existing docs/ai/features/*.md briefs
- Applicable skills (always check dev-lifecycle first)

## Outputs

### Canonical Outputs

- docs/ai/features/{name}.md (feature brief when scope requires)

### Physical Memory Outputs (mandatory for Small+ scope)

- .agent/implementation_plan.md — durable execution plan for the active mission
- .agent/task.md — mission state file with ordered checkboxes and a Mission Header

## Steps

1. Run the IDE "List Tools" command and record active MCP tools.
2. Read docs/ai/implementation/artifact-hierarchy.md before planning.
3. Mandatory current-state verification: use available MCP tools (for example DB schema, routes, logs, REPL/tinker) to confirm project facts before planning.
4. Classify scope using .github/skills/dev-lifecycle/SKILL.md.
5. **Physical Memory gate**: If scope is **Small or larger**, you MUST create `.agent/implementation_plan.md` and `.agent/task.md` on disk. Chat-only plans are a governance violation for Small+ scope. If scope is **Trivial**, skip Physical Memory creation.
6. **Conflict check**: If `.agent/task.md` already exists when planning a new mission, warn the user and ask whether to delete-and-replace or continue the existing mission. Do not silently overwrite.
7. Infer feature name in kebab-case from request context.
8. If scope is Medium+, write or update docs/ai/features/{name}.md before generating Physical Memory.
9. Build .agent/implementation_plan.md as the mission execution plan:
   - Mission Header: feature name, scope classification, ISO timestamp, canonical source path
   - Problem, goals, non-goals
   - User scenarios and acceptance criteria
   - Architecture and key decisions
   - Risk surface (Small+ scope)
   - Delivery plan with explicit file paths and verification commands
10. Write .agent/task.md with:
    - Mission Header (same as implementation_plan.md)
    - Ordered checkboxes mapping to each delivery task
    - Format: `- [ ] Task description`
11. Emit profile rationale line per `docs/ai/governance-core.md` before substantive content.

## Guardrails

- Single-shot planning; at most one blocking question.
- No unresolved placeholder markers.
- Apply the 1% Rule before writing plan content.
- Prohibit Guessing: if an MCP tool can provide a fact, do not rely on internal memory or local files for that fact.
- Physical Memory files must exist on disk before implementation begins (Small+ scope).
- Chat-only plans are a governance violation for Small+ scope.
- Conflict check is mandatory: never silently overwrite an existing task.md.
