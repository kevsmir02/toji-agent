# AI Maintainer & Scaling Guide: Toji Agent
**Role:** AI Agent / Dev Maintainer Reference
**Purpose:** How to add features, change architecture, and scale Toji Agent without reintroducing governance bloat.

> **Important:** This file lives in `docs/maintainer/`. It is intentionally ignored by the consumer `update.sh` distribution script. It is for framework maintainers only.

---

## 1. Architectural Philosophy: The Unified Core (v2.1.0+)

Historically, Toji Agent suffered from "governance bloat" caused by maintaining duplicate instructions for two separate execution paths: Copilot (`.github/`) and Antigravity (`.agent/`).

The current architecture is a **Unified Core** system.
- **Rule 1: Never Duplicate Policy.** A rule, skill, or law is authored once.
- **Rule 2: Push, Don't Pull.** Use deterministic sync scripts for static injection; avoid runtime parser complexity.
- **Rule 3: Invisible by Default.** Any new consumer-facing directory must be appended to consumer `.git/info/exclude` in `update.sh`.

---

## 2. How to Scale Features Properly

### 2.1 Adding a New Core Skill
A skill represents domain-specific expertise or a sub-agent prompt behavior.
1. **Location:** Create a new directory and file at `.github/skills/[skill-name]/SKILL.md`.
2. **Structure:** Skills are organized recursively by folders because future skills might require supplementary files (e.g., blueprints, tokens, JSON specs).
3. **Runtime Registration:** No runtime registry is required. The persona loads skills dynamically through the 1% Rule.
4. **Maintainer Registration (Required):** If the new skill should be visible in framework docs/governance lists, update skill discovery surfaces (at minimum `.github/copilot-instructions.md` and `.github/copilot-instructions.template.md`) so guidance does not drift from filesystem reality.
5. **Anti-pattern:** NEVER create a duplicate flat-file in `.agent/rules/`. The Antigravity path executes out of the exact same `.github/skills/` directory.

### 2.2 Modifying Iron Laws or Profile Behaviors
Iron Laws are the strict governing rules of the system.
1. **Location:** Navigate to strictly `docs/ai/governance-core.md` and edit the markdown file.
2. **Sync Required:** Once modified, you MUST run the sync script to push the laws into the various endpoints:
   ```bash
   node scripts/sync-governance.js
   ```
3. **Validation:** Ensure the sync worked correctly without drift:
   ```bash
   node scripts/check-governance-sync.js 
   ```

### 2.3 Creating New Workflows & Prompts
Toji Agent has two separate workflow entry points depending on what the user is interacting with.
- **For GitHub Copilot Slash Commands**: Add new prompt files to `.github/prompts/[command].prompt.md`.
- **For Antigravity Workflows**: Add new workflow documents to `.agent/workflows/toji-[workflow].md`.

**The Abstraction Rule:** If both surfaces require the same set of preflight logic (e.g. checking project state or discovering MCP tools before planning), **you must not duplicate the instructions**. Standardize the ritual in `docs/ai/ritual-preamble.md` and direct both workflows to read it first.

### 2.4 Modifying Installer & Verification Scripts
The installation logic is split intentionally:
- `install.sh`: Primary entry installer (preflight and install orchestration) that invokes `update.sh` for sync logic.
- `update.sh`: The massive engine that copies files gracefully and applies Invisible Governance.
- `check.sh`: The diagnostic validation engine.

**Scaling the Installer:**
If you introduce a new directory that gets synced to end users, you must:
1. Update `init_rollback_snapshot()` and `restore_rollback_snapshot()` within `install.sh` and `update.sh` so failures don't permanently corrupt the consumer repository.
2. Update `apply_excludes_for_mode()` so the folder remains invisible from Git changes.
3. Update `check.sh` so `check.sh --both` successfully tests the existence of your new feature.

All flag contracts across bash scripts (`--from-update`, `--status`) must be manually declared since they invoke one another strictly. 

### 2.5 `copilot-instructions` vs `copilot-instructions.template`
Yes, your understanding is correct with one important nuance.

- `.github/copilot-instructions.md` is the live maintainer/runtime governance file in this framework repo.
- `.github/copilot-instructions.template.md` is the consumer-safe distribution source.
- During consumer sync, `update.sh` prefers the template and writes it to the consumer's `.github/copilot-instructions.md`; if template is missing, it falls back to the live file.
- `scripts/sync-governance.js` updates both files. Keep them aligned and validate with `node scripts/check-governance-sync.js`.

### 2.6 Source-vs-Consumer Context Contract (Explicit)
Before any architecture, skill, prompt, installer, or governance edit, classify repository context.

**Source/Maintainer context (framework repo) if one or more are true:**
- `docs/maintainer/AI_SCALING_GUIDE.md` exists
- `scripts/sync-governance.js` and `scripts/check-governance-sync.js` exist
- `scripts/linux/update.sh` exists in the same repo as `.github/skills/`

**Consumer context (installed project) when maintainer markers are absent:**
- Maintainer docs are missing, and repo primarily contains app/domain code
- Toji surfaces are present as installed artifacts, not framework source

**Contract rules:**
- In **Source/Maintainer** context: follow this guide before edits; apply Unified Core rules and run maintainer verification checks.
- In **Consumer** context: do not invent framework architecture migrations. Use existing distributed Toji surfaces, or recommend `/update-toji` when framework-level change is needed.
- If context is ambiguous, default to **consumer-safe behavior** until source context is confirmed.

### 2.7 Maintainer-Scaling Skill Checklist (Run Every Maintainer Task)
Use this as a mandatory preflight and completion checklist for framework evolution work.

1. **Classify context** using Section 2.6 and state Source/Maintainer vs Consumer.
2. **Classify change type**: skill, governance, prompt/workflow, installer/checker, docs-only.
3. **Apply single-source rule**: add or edit policy in canonical location only (no mirrors).
4. **Instruction surface discipline**:
   - If change is consumer-facing guidance, update both `.github/copilot-instructions.md` and `.github/copilot-instructions.template.md`.
   - If change is maintainer-only doctrine, keep it in maintainer surfaces/docs.
5. **Governance changes**: edit `docs/ai/governance-core.md`, then run:
   - `node scripts/sync-governance.js`
   - `node scripts/check-governance-sync.js`
6. **Skill changes**: update `.github/skills/[skill-name]/SKILL.md`, then verify discoverability references remain accurate where applicable.
7. **Installer/checker changes**: update both `install.sh` and `update.sh` rollback/exclude/flag contracts as needed, and reflect checks in `check.sh`.
8. **Verification gate** (minimum):
   - `node scripts/check-governance-sync.js`
   - `bash scripts/linux/check.sh --both`
   - `bash scripts/linux/check.sh --status`
9. **Drift sweep**: grep for stale paths/terms introduced by the change and resolve them before commit.
10. **Document why**: update maintainer docs when behavior/contracts change.

### 2.8 Artifact Hierarchy (Canonical + Derived Mirror)

Maintainers must preserve a strict hierarchy between policy artifacts and execution mirrors.

- **Git-Is-Truth:** Requirements, architecture decisions, and acceptance criteria live in `docs/ai/features/*.md`. If it is not committed there, it is not policy.
- **Projection Rule:** Antigravity artifacts (`implementation_plan.md`, `task.md`, `walkthrough.md`) are derived mirrors used for execution sequencing and status only.
- **Hierarchy of Edits:** During mid-build pivots, update the Canonical feature brief first and then re-derive mirrors.

Maintainer application:

1. When planning behavior changes, edit the Canonical feature brief first.
2. Treat mirror artifacts as disposable session state and never as long-term source documents.
3. Validate cross-surface alignment against `docs/ai/implementation/artifact-hierarchy.md`.

Anti-pattern:

- Never create `.agent/rules/` skill mirrors. Skills are canonical under `.github/skills/` only.



---

## 3. Anti-Patterns (What Not to Build)

To prevent the agent framework from collapsing under its own weight again, you are explicitly barred from building the following:

- ❌ **Autonomous Routing / "Theater" state-machines.** Do not build complex logic for the agent to auto-determine if it should apply "strict mode" vs "lax mode" using "confidence scores". It proved unmaintainable. Instead, rely on explicit user commands and simple heuristics.
- ❌ **Web UI Dashboards.** Toji is an invisible terminal-and-file framework. Do not build UI layers to manage Toji health. Use `bash scripts/linux/check.sh --status`.
- ❌ **Central Watcher Daemons.** Do not write a background process daemon to automatically inject `.agent/` changes into `.github/`. Use single execution Node sync-scripts instead.
- ❌ **Per-Project Iron Laws.** The Iron Laws must remain universal for all repositories using Toji. Allowing clients to inject overrides will break standardized behavior across your pipeline.
