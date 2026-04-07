---
description: Document a code entry point — module, file, folder, function, or API — with optional Session Handover for governance continuity. Single-shot.
---

Guide me through creating structured documentation for a code entry point.

**Single-shot:** Follow **Single-shot efficiency** in `.github/copilot-instructions.md`. Infer entry point, motivation, and depth from the user message, open files, and `git status` / recent changes. **At most one** question only if no entry point can be identified.

1. **Gather & Validate** — Resolve the entry point (file, folder, function, API); confirm it exists. If ambiguous, pick the best match from context and state **Assumed:** — **do not** run a multi-field questionnaire.
2. **Collect Source Context** — Read the primary file/module and summarize purpose, exports, key patterns. For folders: list structure, highlight key modules. For functions/APIs: capture signature, parameters, return values, error handling. Extract essential snippets (avoid large dumps).
3. **Analyze Dependencies** — Build a dependency view up to depth 3, tracking visited nodes to avoid loops. Categorize: imports, function calls, services, external packages. Note external systems or generated code to exclude.
4. **Synthesize** — Draft overview (purpose, language, high-level behavior). Detail core logic, execution flow, key patterns. Highlight error handling, performance, security considerations. Identify potential improvements or risks.
5. **Create Documentation** — Normalize name to kebab-case (`calculateTotalPrice` → `calculate-total-price`). Create `docs/ai/implementation/knowledge-{name}.md` with sections: Overview, Implementation Details, Dependencies, Visual Diagrams (mermaid), Additional Insights, Metadata (date, depth, files touched), Next Steps.
6. **Review & Next Actions** — Summarize key insights and open questions. Suggest related areas for deeper dives and confirm file path.

---

## Session Handover (Governance Capture) — major tasks only

When this documentation pass closes a **major** task, milestone, or feature slice (e.g. end of `/build` tranche, release candidate, or explicit user request for handover), you **must** update **`docs/ai/README.md`** in addition to any knowledge doc:

1. Open `docs/ai/README.md`.
2. Ensure these two sections exist at the **end** of the file (create or replace their bodies — keep section headings stable):

### Current State of the Union

Write **what exactly works right now** in concrete terms: shipped behaviors, passing tests or commands checked, known-good entry points, and versions or flags if relevant. No wishful thinking — only verified state.

### Backlog of Intent

Write **what the implementation model (Builder) must do next**, strictly from the planning model’s (Architect) remaining design: ordered next steps, file/feature references, and blockers. If no Architect doc exists, derive from the feature brief’s Delivery Plan unchecked items.

3. **Timestamps** — Add an italic one-line update stamp under each section, e.g. `*Updated: YYYY-MM-DD — brief label*`.

4. If `docs/ai/README.md` is missing, create it using the repo template structure, then append these sections.

**Rule:** Session Handover is **mandatory** when the user or workflow indicates a major task boundary; optional for tiny doc-only edits.
