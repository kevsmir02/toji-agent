---
description: Debug an issue with structured root-cause analysis before changing code. Single-shot context; skill-aligned phases.
---

Help me debug an issue using **`.github/skills/debug/SKILL.md`**.

Read the skill first, then follow its phases: **Phase 1 Root Cause Investigation** → **Phase 2 Hypothesize** → **Phase 3 Plan and fix** (no code until approval unless the user already delegated autonomy—state if so).

**Single-shot:** Infer repro, error, and affected files from the message, logs, and repo—**at most one** blocking question.

Do not modify code until I approve a fix plan (unless delegated).

After applying the fix (or after a documented **3-attempt stop**), output **What changed** (≥3 bullets) **and** satisfy **session closure** in the skill (Atomic Instinct append or `Lesson: N/A`).
