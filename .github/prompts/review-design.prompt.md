---
description: Review feature design for completeness and design-doc token compliance.
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

---

## Design compliance audit (documentation)

**Goal:** Ensure the **design doc** does not prescribe or exemplify off-ledger UI before implementation exists.

1. If the brief includes **UI snippets**, pseudo-Tailwind, or embedded CSS/HTML examples, scan for:
   - **Magic values** — e.g. `text-[#FF5733]`, `w-[321px]`, `gap-[13px]`, `rounded-2xl`, `shadow-lg` without explicit brief exception
   - **Unauthorized palette** — structural chrome described as generic `bg-blue-500`, `text-gray-400`, etc. without mapping to `.github/skills/ui-reasoning-engine/SKILL.md`

2. **Verdict:**
   - **PASS** — Examples use only ledger tokens / allowed spacing scale, or UI is described semantically without contradictory literals.
   - **FAIL** — Magic values or unauthorized colors/spacing appear in the design text or examples.

3. **If FAIL:** Do **not** approve design for `/build`. Require the Architect to revise the design sections to reference **Toji tokens** (`tokens.md`) explicitly or remove contradictory literals. **Delete Rule (design):** strike or replace offending example blocks — no build until the doc matches token discipline.

4. If there are **no UI examples** in the doc, output `Design compliance: N/A (no UI literals in design doc)`.

---

## Output format (mandatory)

```
## Design review summary
...

## Design compliance audit
- Verdict: PASS | FAIL | N/A
- Findings: ...
```

## Next steps

If problem or scope gaps are found, return to `/review-plan`. If design compliance **FAIL**, revise the design doc then re-run `/review-design`. If design is sound and compliance **PASS**, continue to `/build`.
