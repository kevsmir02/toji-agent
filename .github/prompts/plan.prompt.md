---
description: Zero-context planning — feature brief with Delivery Plan tasks broken into 2–5 minute actions, explicit paths, code, and verification commands. No TODO/TBD placeholders. Single-shot: infer from docs/ai/ and message; at most one question if blocking.
---

Start a new feature with **zero-context planning**: every task must be executable by someone who has **never seen this repository** without asking follow-up questions.

**Single-shot:** Follow **Single-shot efficiency** in `.github/copilot-instructions.md`. Read **`docs/ai/README.md`**, **`docs/ai/features/`** (existing briefs), and the user message **first**. Infer **feature name** (kebab-case), problem, users, stories, constraints, and risks from that context. **Do not** ask a questionnaire. **At most one** question, only if a **blocking** ambiguity remains (e.g. two equally valid feature names and none named in the message).

## Ritual (mandatory)

1. **MCP Discovery (mandatory before planning)** — Run the IDE "List Tools" command. If MCP tools are active, use them to verify current-state facts (schema, routes, runtime constraints) before writing plan assumptions. If no MCP tools are active, explicitly note MCP unavailable.

2. **Ingest** — Derive feature name, problem, users, stories, constraints, and risks from **`docs/ai/`** + the user message. If the user gave a feature name or path, use it. Otherwise prefer the **most recently modified** `docs/ai/features/*.md` only when the message clearly continues that work; else derive a sensible new kebab-case name from the message.

3. **Mandatory Design Selection (UI features)** — Before any implementation steps or Delivery Plan tasks:

   - Read `.github/skills/ui-reasoning-engine/SKILL.md` and **select exactly one** archetype: **Minimalist Dashboard (Notion)**, **Data-heavy (Linear)**, or **Convergent page (Apple)**.
   - If the feature has **no user-visible UI** (pure API, CLI-only, batch job), state **Design archetype: N/A** and skip the Visual Strategy body except one line explaining why.
   - Output a **Visual Strategy** section **in the planning response** (and copy it into the feature brief under a `## Visual Strategy` heading):
     - **Chosen archetype** (full name from blueprints).
     - **Why it fits** this request (2–4 sentences tied to user stories / surface type).
     - **Tokens from `tokens.md`** — explicit list of token names (e.g. `bg.page`, `border.default`, `text.muted`, spacing keys such as `gap-4` / `p-8`, `radius.*`, `shadow.*`) that will carry the look — **no** palette colors outside the ledger.
     - **Suggested UI patterns** — at least two named patterns from the archetype’s blueprint list (e.g. `Filter-Bar-Top`, `Sidebar-Nav-Fixed`).
   - **Order:** This step completes **before** step 3. Do not generate the Delivery Plan until Design Selection (or N/A) is done.

4. **Create the primary feature brief** by copying `docs/ai/features/README.md` to `docs/ai/features/{name}.md`.

5. **Create companion docs only if needed**:
   - `docs/ai/implementation/{name}.md` for deeper implementation details
   - `docs/ai/testing/{name}.md` for a dedicated testing strategy

6. **Fill the feature brief** — problem, goals/non-goals, user stories, critical flows, proposed solution, architecture, data/contracts, key decisions, success criteria. Include the **Visual Strategy** from step 3 when UI exists. **No placeholders** in prose: forbidden words/phrases include `TODO`, `TBD`, `FIXME`, `later`, `add error handling` without specifying *what* error, *where*, and *how*.

7. **Risk Surface (mandatory for Small+)**

   - Classify scope using `.github/skills/dev-lifecycle/SKILL.md`.
   - If scope is **Trivial**, skip this section entirely.
   - If scope is **Small**, **Medium**, or **Large**, add `## Risk Surface` to `docs/ai/features/{name}.md` and answer these **exact four questions** before writing the Delivery Plan:
     - **Input surface:** What user-controlled input does this feature accept? (form fields, file uploads, URL params, API payloads)
     - **Data exposure:** What data does this feature read or return? Is any of it sensitive?
     - **Auth boundary:** Does this feature cross a permission or authentication boundary? Which roles or guards apply?
     - **Performance pressure:** What is the realistic worst-case data volume or request frequency? Is there a query, loop, or external call that could degrade under load?
   - Answers must be concrete. Use `N/A` only when genuinely not applicable and include a one-line reason.
   - This is **not** a security audit and does **not** gate planning or require approval. It is a forced visibility section in the brief.

8. **Delivery Plan — zero-context granularity (mandatory)**

   Every item in the `Delivery Plan` / task breakdown must:

   - **Granularity:** Each task is a **2–5 minute** action (e.g. “write failing test for X”, “run test, confirm red”, “implement minimal change in file Y”, “run test, confirm green”, “run linter on Z”).
   - **Zero-context engineer:** Write as if the assignee has **zero prior context** on this project. Include:
     - **Exact file paths** (repo-relative) for every create/edit/delete.
     - **Complete code blocks** for every intended change (or exact function signatures + full body for new code — not “add a handler”).
     - **Specific shell commands** for verification after each task (exact test command, lint command, or build command as used in this repo).
   - **No placeholders:** Forbidden in the Delivery Plan: `TODO`, `TBD`, `...`, “implement appropriately”, “add validation”, “handle errors” without explicit behavior, types, and locations. Every requirement must be **explicitly specified** in the plan text or embedded code blocks.

9. **Physical Memory (mandatory for Small+ scope)** — Write `.agent/task.md` with a Mission Header and the Delivery Plan checkboxes. Also write `.agent/implementation_plan.md` with the full plan. These files are **Physical Memory** and persist across sessions until deleted on mission completion. If scope is **Small**, a full feature brief is not required, but these physical files must still be created.

10. **Conflict Check** — If `.agent/task.md` already exists, you MUST warn the user and ask whether to delete-and-replace or continue the existing mission before overwriting.

11. **Keep planning in the same file** — milestones, task breakdown, dependencies, and risks stay in the feature brief’s `Delivery Plan` section and are reflected in `.agent/task.md`.

12. **Next Steps** — Run `/review-plan` to validate the brief, `/review-design` for architecture sections when applicable, then `/build` or `/build-tdd` to implement. Frontend work must follow **ui-reasoning-engine**: user confirmation of **Visual Strategy** before UI code (see skill **Pre-flight Design Lock**).

## Enforcement

If any Delivery Plan task cannot be executed from the document alone (paths, code, commands missing), the plan is **incomplete** — revise before implementation.
