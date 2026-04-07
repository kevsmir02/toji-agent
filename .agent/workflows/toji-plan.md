# Workflow: Toji Plan

Purpose: translate Toji /plan behavior into Antigravity workflow execution.

## Inputs

- User request
- docs/ai/README.md
- Existing docs/ai/features/*.md briefs
- Applicable skills (always check dev-lifecycle first)

## Outputs

- .agent/implementation_plan.md (authoritative implementation plan artifact)
- .agent/task.md (execution checklist and next action)
- docs/ai/features/{name}.md (feature brief when scope requires)
- Routing rationale line for the active task

## Steps

1. Run the IDE "List Tools" command and record active MCP tools.
2. Mandatory current-state verification: use available MCP tools (for example DB schema, routes, logs, REPL/tinker) to confirm project facts before planning.
3. Classify scope using .github/skills/dev-lifecycle/SKILL.md.
4. Infer feature name in kebab-case from request context.
5. Build implementation_plan.md with:
   - Problem, goals, non-goals
   - User scenarios and acceptance criteria
   - Architecture and key decisions
   - Risk surface (Small+ scope)
   - Delivery plan with explicit file paths and verification commands
6. Update task.md with ordered checkboxes that map to delivery tasks.
7. If Medium+ scope, ensure docs/ai/features/{name}.md reflects the same plan.
8. Emit profile rationale line per `docs/ai/governance-core.md` before substantive content.

## Guardrails

- Single-shot planning; at most one blocking question.
- No TODO/TBD placeholders.
- Apply the 1% Rule before writing plan content.
- Prohibit Guessing: if an MCP tool can provide a fact, do not rely on internal memory or local files for that fact.
