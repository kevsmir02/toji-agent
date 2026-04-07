---
description: /update-toji — compare local Toji version to upstream, Rule Diff new rituals, ask permission to run update.sh.
---

You are running **`/update-toji`**. Goal: help the user **safely migrate** to the latest Toji framework while **protecting living memory** (`docs/ai/`, `lessons-learned.md`, project `tokens.md`).

## 1. Read current version

- Open **`.github/toji-version.json`** in the working repository.
- Report **`version`** and **`last_update`** to the user.
- If the file is missing, say so and recommend running **the updater from a toji-agent source path (or GitHub raw URL) once** so future updates are trackable.

## 2. Resolve upstream source

- Prefer a path the user provides (local clone of `toji-agent`).
- Default upstream reference: **`https://github.com/kevsmir02/toji-agent`** (same as `update.sh`).
- If you can read files from that source (user attached a folder, submodule, or second workspace), load its **`.github/toji-version.json`** and **key instruction files** for comparison. If you cannot access upstream files, instruct the user to run **`TOJI_SOURCE=/path/to/toji-agent bash /path/to/toji-agent/update.sh`** or stream from GitHub raw, then compare locally, and still perform a **Rule Diff** from whatever upstream snapshot they paste or open.

## 3. Analyze new instructions (upstream vs local)

Compare upstream **`.github/copilot-instructions.md`**, **`.github/skills/*/SKILL.md`**, and **`.github/prompts/*.prompt.md`** to the repo’s current copies (or summarize upstream if only one side is visible).

## 4. Rule Diff (mandatory user-facing section)

Output a section titled **`## Rule Diff`** that explains:

- **Version delta** — upstream `version` vs local `version` (if both known).
- **New or changed “Iron Laws”** — new mandatory rituals, gates, skills, or prompts (e.g. “Version 1.2 adds a Security Audit phase in Security Mode,” “new `/onboard` preflight,” “verify Delete Rule + Legacy Grace”).
- **Behavioral impact** — what the developer and Copilot must do differently after updating.
- **Preserved by design** — explicitly state that **`update.sh` does not overwrite** `.github/lessons-learned.md`, `.github/skills/ui-reasoning-engine/SKILL.md` (if present), or **`docs/ai/`**.

Keep this concise but specific; cite file paths when possible.

## 5. Permission gate

**Do not** tell the user the update is complete until they confirm.

- Ask clearly: **May I proceed with running `update.sh`?** (or: “Run the updater from your toji-agent source path and paste the output if you prefer.”)
- Give the exact suggested command, e.g.:
  - `TOJI_SOURCE=/abs/path/to/toji-agent bash /abs/path/to/toji-agent/update.sh`
  - `curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/update.sh | bash`
  - `TOJI_SOURCE=/abs/path/to/toji-agent bash /abs/path/to/toji-agent/update.sh --dry-run` (local source only; prints planned copies)

If they decline, stop after the Rule Diff and offer to revisit later.

## 6. After approval (or after they run the script)

- If they ran **`update.sh`**, read the new **`.github/toji-version.json`** and confirm **`last_update`** moved forward.
- Summarize what synced and remind them: **`docs/ai/`** and session/design files were **preserved** per **Update Integrity** (see `.github/copilot-instructions.md`).

## Rules

- Never advise mass-deleting **`docs/ai/`** or **`lessons-learned.md`** as part of an update.
- Align narrative with **Governance Privacy**: updated prompts/skills are still **Invisible** unless the user **Publicize Toji**.
