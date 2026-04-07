# Workflow: Toji Debug

Purpose: translate Toji /debug behavior into Antigravity workflow execution.

## Inputs

- Error report or failing behavior
- Relevant logs/tests
- .agent/task.md (for RCA notes)

## Outputs

- Root-cause analysis record
- Approved fix plan
- Optional implementation after approval/autonomy

## Phases

1. Root Cause Investigation (mandatory)
   - Run the IDE "List Tools" command and identify available MCP tools for logs, REPL/tinker, and runtime inspection.
   - Mandatory: use real-time logs or REPL/tinker MCP tools to confirm observed behavior before hypothesis.
   - Reproduce issue and collect direct evidence.
   - Trace boundaries and identify true failure point.
2. Hypothesis
   - Produce ranked hypotheses tied to evidence.
   - Select most likely root cause.
3. Plan and Fix
   - Present minimal fix plan.
   - Implement only after approval, unless autonomy is explicitly delegated.

## RCA Logging

Record in task.md:

- Evidence
- Root cause
- Fix plan
- Validation commands/results

## Guardrails

- No speculative fixes before RCA.
- Maximum three fix attempts before stop-and-report.
- Conclude with What changed and lesson capture.
- Prohibit Guessing: if an MCP tool can verify a runtime fact, do not hypothesize that fact from static files alone.
