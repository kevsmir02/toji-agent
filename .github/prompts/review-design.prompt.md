---
description: Review feature design for completeness.
---

Review the design sections in `docs/ai/features/{name}.md`.

1. Summarize:
   - Architecture overview (verify a mermaid diagram is present and accurate when the feature is non-trivial)
   - Key components and their responsibilities
   - Technology choices and rationale
   - Data models and relationships
   - API/interface contracts (inputs, outputs, auth)
   - Major design decisions and trade-offs
   - Non-functional requirements that must be preserved
2. Highlight inconsistencies, missing sections, or diagrams that need updates.
3. **Next Steps** — If problem or scope gaps are found, return to `/review-plan`; if design is sound, continue to `/build`.
