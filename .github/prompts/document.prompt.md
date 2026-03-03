---
description: Document a code entry point — module, file, folder, function, or API.
---

Guide me through creating structured documentation for a code entry point.

1. **Gather & Validate** — If not already provided, ask for: entry point (file, folder, function, API), why it matters (feature, bug, investigation), and desired depth or focus areas. Confirm the entry point exists; if ambiguous or not found, clarify or suggest alternatives.
2. **Collect Source Context** — Read the primary file/module and summarize purpose, exports, key patterns. For folders: list structure, highlight key modules. For functions/APIs: capture signature, parameters, return values, error handling. Extract essential snippets (avoid large dumps).
3. **Analyze Dependencies** — Build a dependency view up to depth 3, tracking visited nodes to avoid loops. Categorize: imports, function calls, services, external packages. Note external systems or generated code to exclude.
4. **Synthesize** — Draft overview (purpose, language, high-level behavior). Detail core logic, execution flow, key patterns. Highlight error handling, performance, security considerations. Identify potential improvements or risks.
5. **Create Documentation** — Normalize name to kebab-case (`calculateTotalPrice` → `calculate-total-price`). Create `docs/ai/implementation/knowledge-{name}.md` with sections: Overview, Implementation Details, Dependencies, Visual Diagrams (mermaid), Additional Insights, Metadata (date, depth, files touched), Next Steps.
6. **Review & Next Actions** — Summarize key insights and open questions. Suggest related areas for deeper dives and confirm file path.
