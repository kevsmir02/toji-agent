# Workflow: Toji Verify

Purpose: translate Toji /verify behavior into Antigravity workflow execution.

## Inputs

- docs/ai/features/{name}.md (canonical source, if present)
- .agent/implementation_plan.md
- .agent/task.md
- Current diff and test outputs

## Outputs

- Three-stage verification verdict
- Updated task.md verification status

## Stages

1. Spec compliance
   - Compare implementation against acceptance criteria and critical flows in docs/ai/features/{name}.md.
   - Flag missing behavior and scope creep.
2. Quality review
   - Check architecture, naming, maintainability, security robustness.
   - Run design/token compliance for UI changes.
   - Enforce Delete Rule when violations exist on new/changed lines.
3. Cleanup audit
   - Remove debug scaffolding and temporary diagnostics before pass.

## Turbo Blocks

// turbo:start verify-suite
- execute tests required by implementation_plan.md
- execute lint/typecheck for touched scope
- summarize pass/fail with blocking findings
// turbo:end

## Guardrails

- Overall PASS requires all required stages to pass.
- If any stage fails, return explicit remediation and do not mark complete.
- Canonical feature briefs are the verification source of truth; mirror artifacts are not acceptance criteria.
