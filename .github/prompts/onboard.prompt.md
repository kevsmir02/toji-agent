---
description: /onboard — Fresh Start vs Legacy Integration; Legalization Scan; Integrity Roadmap; initialize docs/ai governance and State of the Union. Single-shot default.
---

You are running **`/onboard`**. Follow `.github/skills/onboarding/SKILL.md` for mechanical steps; this prompt defines **user interaction** and **required outputs**.

**Single-shot:** Follow **Single-shot efficiency** in `.github/copilot-instructions.md`. After preflight checks below, **infer** Fresh vs Integration from the user message (e.g. “legacy”, “existing app”, “brownfield” → Integration; “new repo”, “greenfield”, “from scratch” → Fresh). **Do not** ask the classification question if inference is clear. **At most one** question if both modes are equally plausible.

## 1. Hook Integrity Check (mandatory first)

- Check whether **`.git/hooks/pre-commit`** exists.
- **If it does not exist:** stop and inform the user they must run the installer from a **toji-agent source** while in the repository root (for example, `curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/install.sh | bash`) to enable **commit protection** for Toji governance files. Do not continue onboarding until this is resolved (or the user explicitly overrides in a documented emergency).
- **If it exists:** confirm it contains the Toji guard (e.g. `TOJI ERROR` or `Toji Invisible Governance` in the script). If the file is empty or unrelated, still recommend re-running install from a **toji-agent source** to install the correct hook.

## 2. Preflight — Invisible Governance

**Before continuing** the onboarding conversation:

1. **Verify `AGENTS.md`** exists at the repository root and contains the Toji lifecycle mandate (run `install.sh` if missing).
2. **Verify local exclusion** matches installer intent: read `.git/info/exclude` and confirm it includes the **Toji Agent — Invisible Governance** block listing `docs/ai/`, `.github/skills/`, `.github/prompts/`, `.github/lessons-learned.md`, `.github/toji-version.json`, and `AGENTS.md`. Optionally run `git check-ignore -v AGENTS.md` / `docs/ai/` paths — they should be ignored **via exclude** (or equivalent local ignore). If exclusion is missing, tell the user to run install from a **toji-agent source**, then re-run `/onboard`.

If anything is wrong, **fix or instruct** before proceeding — do not assume governance is active.

## 3. Classify (infer or one question)

- **Fresh** → onboarding skill **Mode A — Fresh Start**.
- **Integration** → onboarding skill **Mode B — Legacy Integration** (includes **Legalization Scan** and legacy baseline).

If mode is unclear after inference, ask **once**: *Fresh project or integration (existing codebase)?* — then proceed.

**Legacy Integration — user guidance:** Walk the user through the **Legalization Scan** as **documentation and baseline capture**, not a refactor: extract existing colors/spacing into `docs/ai/onboarding/legacy-token-extract.md` so **`/verify`** can pass for existing UI; list routes/components as **Legacy/Accepted** in `legacy-baseline.md`; set the **Line in the Sand**. Emphasize that **pre-baseline UI is not subject to the verify Delete Rule** until they request a **significant modification** — the goal is to **archive** current UI/logic into `docs/ai/` safely without triggering mass token rewrites.

## 4. Execute the skill

- Read `.github/skills/onboarding/SKILL.md` and perform the steps for the chosen mode.
- **Integration:** run the full **Legalization Scan**, write `legacy-token-extract.md`, write `legacy-baseline.md`, update `onboarding-log.md`, set **Line in the Sand** in `docs/ai/README.md`.

## 5. Initialize or refresh `docs/ai/README.md`

Ensure **`docs/ai/README.md`** contains:

### Toji Governance (required block)

Add or update a section **Toji Governance** with:

- **Onboarding mode:** `Fresh Start` or `Legacy Integration`
- **Line in the Sand (Toji governance start):** `YYYY-MM-DD` (same as onboarding log)
- **Onboarding log:** `docs/ai/onboarding/onboarding-log.md`
- **Legacy artifacts (integration only):** links to `legacy-token-extract.md`, `legacy-baseline.md`

### Current State of the Union, Backlog of Intent, Governance History

- **Current State of the Union** — concise factual snapshot (what is 100% functional; onboarding date + mode).
- **Backlog of Intent** — next Builder tasks from the Architect / briefs.
- **Governance History** — add a row for **Onboarding** with ISO date and mode; under **Legalized Legacy modules**, summarize or link to `legacy-baseline.md` (integration only).

### Integrity Roadmap (required output)

Add or refresh **Integrity Roadmap** (section in README or `docs/ai/onboarding/integrity-roadmap.md` + link).

Content: **prioritized list** of technical debt and design inconsistencies to address **over time**, not in one batch. Examples:

- Token drift vs Toji defaults (reference extract appendix)
- Missing tests on hot paths (name modules; do not mandate immediate rewrites)
- Routes/components that violate future token rules when touched
- Docs gaps

Each item: **title**, **why it matters**, **suggested order** (now / next / later), **non-goal** (explicitly *not* blocking shipping legacy as-is).

## 6. Chat output (mandatory)

In the reply to the user, include:

1. **Mode chosen** and **Line in the Sand** date  
2. **Files created/updated** (paths)  
3. **Integrity Roadmap** (full list or summary + pointer to doc)  
4. **Next steps:** e.g. `/detect-stack` when applicable, `/plan` for first feature, reminder that legacy files are grace-period until modified  

## 7. Rules

- Do **not** mass-rewrite legacy UI in this command; baseline and document instead.
- Do **not** invent hex or spacing; extraction must come from real files or be explicitly empty.
