---
name: mcp-manager
description: MCP discovery and usage discipline — discover active MCP tools before planning/debugging, map tool priority tiers, and prevent guessing when a fact can be retrieved from a live MCP source. Use before plan/design and during debugging across all stacks.
globs: ["**"]
---

# MCP Manager

Enforce a tool-first discovery ritual before planning and debugging.

## Goal

Move from static assumptions to fact-based planning and diagnosis using active MCP tools.

## Discovery Ritual (mandatory at task start, before any Plan phase)

1. Run the IDE "List Tools" command to enumerate currently active MCP servers and tools.
2. Record available tools by capability (db, logs, docs, routes, repl, browser, git provider).
3. Determine the lessons ledger tags relevant to current scope (`#arch`, `#fix`, `#perf`, `#ux`, `#stack`).
4. If an MCP search tool is available, load only the relevant tag section(s) from `.github/lessons-learned.md` before planning.
5. If ledger size is greater than 30 entries, do not read the entire lessons file; use targeted tag retrieval only.
6. If no MCP tools are active, explicitly note "MCP unavailable" and continue with local evidence.
7. If MCP tools are active, use them first for facts before reading local files for the same fact.

## Tool Tiers

- Tier 1 (runtime truth): DB/schema explorers, tinker/repl, route/api introspection.
- Tier 2 (operations truth): live logs, queue/job status, telemetry/monitoring surfaces.
- Tier 3 (external truth): github-mcp, fetch-mcp, web/docs retrieval for APIs and references.

When multiple tools can answer the same question, prefer lower tier number first.

## Stack-aware recommendations

- Laravel ecosystems: prefer `laravel-boost` for routes, models, migrations, and artisan-aware context.
- MERN/Node ecosystems: prefer `mongodb-mcp` for schema/data truth and `node-logs-mcp` for runtime behavior.
- Any stack: use `github-mcp` or `fetch-mcp` for external API/docs validation.

## Prohibit Guessing Rule

If an active MCP tool can provide a fact, do not guess that fact from memory.

- Planning examples: current routes, schema fields, migration state, queue names, env-dependent behavior.
- Debugging examples: active errors, log stack traces, runtime variable values from REPL/tinker.

Use local file reads for implementation details, but not as a substitute for live runtime facts available via MCP.

## Verify Evidence Contract (Delete Rule hardening)

When `/verify` evaluates cleanup, removal, or replacement decisions (especially UI or design-token changes), evidence must come from tooling output, not intuition.

Required evidence pattern:

1. Run MCP-backed lint/analysis commands when available (AST-aware or type-aware tools first).
2. Capture concrete diagnostics (rule id, file path, line, and failure reason).
3. Propose deletion/replacement only for code directly supported by those diagnostics.
4. If evidence is missing, state `insufficient evidence` and block destructive cleanup.

Acceptable evidence sources include lint analyzers, AST scanners, type-check diagnostics, and framework-specific static analysis surfaced through MCP tools.

## Output Expectations

When applied, report:

- Which MCP tools were discovered from "List Tools".
- Which tier was used for each key fact.
- Which lint/AST evidence justified any deletion or cleanup recommendation (or an explicit `insufficient evidence` note).
- Any missing tool that would improve confidence for this stack.
