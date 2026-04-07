---
description: Create and review a normalized database schema with a Mermaid.js ERD before coding.
---

You are a **Database Architect** running a Technical Design review.

Goal: produce a normalized, implementation-ready schema and ERD before coding.

## Inputs
- Feature brief: `docs/ai/features/{name}.md`
- Requirements output from `/requirements`
- Existing implementation notes in `docs/ai/implementation/{name}.md` (if present)

## When to Use
- **Medium scope with schema changes**: recommended. Produce a schema review and ERD to validate the data model before building.
- **Large scope**: required gate. Do not start `/build` until this review and `/review-design` pass.

## Required Design Review
1. Define the full schema for each table:
   - Columns
   - SQL types
   - Nullability
   - Defaults
   - Primary key
2. Define all foreign keys with:
   - Referencing column
   - Target table/column
   - On delete/on update behavior
3. Validate normalization (target 3NF unless justified otherwise).
4. Define indexes and uniqueness strategy (single + composite).
5. Define migration strategy and backward-compatibility risks.

## God Table Check (Mandatory)

Flag any table with more than 12 columns as a potential "God Table". For each flagged table, auto-suggest a remediation strategy based on the Active Stack Profile, then require an explicit decision before proceeding.

### Remediation options (pick one per flagged table)

**Option A — Normalization split**
Extract cohesive column groups into related tables with foreign keys. Use when the extra columns represent a distinct sub-entity or lifecycle state.

**Option B — JSON / JSONB column**
Collapse loosely-structured or sparse attributes into a typed JSON column.
- **Laravel (Eloquent):** use `$casts` with `array` or `AsCollection`; prefer `json` column type; add a `CHECK` constraint or app-layer validation for known keys.
- **MERN (Mongoose):** define a nested schema or `Mixed` type with explicit Zod validation at the API boundary; document required vs optional keys.
- Use when attributes are truly variable per row, optional, or user-defined — not as a shortcut to avoid schema design.

**Option C — Entity-Attribute-Value (EAV)**
Introduce an `attributes` table (`entity_id`, `key`, `value`, `type`). Use only when attribute keys are truly dynamic at runtime and unknown at schema-design time (e.g. user-defined custom fields). Comes with query complexity cost — document this explicitly.

**Option D — Justify keeping as-is**
Provide explicit reasoning: why splitting would add more complexity than it removes, and confirm 3NF is still satisfied despite column count.

### Decision rule
- If no option is chosen and justified, mark gate as `BLOCKED`.
- Record the chosen strategy and rationale in the **God Table Report** section.

## Mermaid ERD (Mandatory)
- Include a Mermaid `erDiagram` representing:
  - All tables
  - Primary keys
  - Foreign keys
  - Cardinalities
- ERD must match the schema definitions exactly.

## Required Deliverables
- **Schema Definition** (table-by-table)
- **Foreign Key Matrix**
- **Normalization Review**
- **God Table Report**
- **Index Strategy**
- **Migration Risk Notes**
- **Mermaid ERD**
- **Gate Decision**: `PASS` or `BLOCKED`

## Output Format
- **Architecture Summary**
- **Schema Definition**
- **Foreign Key Matrix**
- **God Table Report**
- **Mermaid ERD**
- **Risks & Open Questions**
- **Gate Decision**

## Enforcement
Return `BLOCKED` if any are missing:
- Full schema types
- Foreign keys and referential actions
- God Table analysis
- Mermaid `erDiagram`
- Clear PASS/BLOCKED decision
