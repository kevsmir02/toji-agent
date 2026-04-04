# Lessons learned — Atomic Instincts

**Project memory** for this repository. Each line is a single **Atomic Instinct**: a strict, testable rule to prevent repeating a past mistake.

Copilot must **read this file at the start of every task** and apply matching instincts to the current context (see `.github/copilot-instructions.md`).

## How to add an instinct

1. After a roadblock, bug, or non-obvious fix, run **`/lesson`** in Copilot Chat.
2. Add exactly one tagged bullet using this format: `- [#category] Title: Atomic lesson.`
3. Keep lessons **atomic**: one rule per bullet and one category per bullet.

## Ledger

### #arch
- [#arch] Comprehensive Skill Deprecation: When replacing a core skill directory (like frontend-design with ui-reasoning-engine), comprehensively grep for the old skill directory name and its explicit artifacts across all installer scripts, update shell scripts, prompts, other skill dependencies, and README.md notes to ensure clean architectural deprecation.
- [#arch] Template Sync Discipline: Any change to `.github/copilot-instructions.md` MUST be immediately mirrored to `.github/copilot-instructions.template.md`. Editing only the generated file breaks all consumer installs — the template is the source of truth for distribution.
- [#arch] Documentation Drift Guard: After adding a skill directory under `.github/skills/`, always cross-check the skills table in both `copilot-instructions.md` and `copilot-instructions.template.md`. New skill folders are invisible to the framework router until documented.
- [#arch] Profile Overlay Contract: Runtime operating profiles must tune execution style only and can never override persona-level governance, tool constraints, or instruction-priority rules.
- [#arch] Dual Agent Profile Sync: Keep operating-profile routing sections in `.github/agents/toji.agent.md` and `.agent/agents/toji.agent.md` synchronized; parity drift creates cross-surface behavior mismatches.
- [#arch] Canonical Skills Boundary: Keep `.github/skills/*/SKILL.md` as the only skill source of truth; treat `.agent/` as persona/workflow surface only and remove any mirrored `.agent/rules/skill-*.md` copies to prevent cross-surface drift.
- [#arch] Canonical Artifact Hierarchy: Store requirements and acceptance criteria only in `docs/ai/features/*.md`; treat Antigravity `implementation_plan.md` and `task.md` as disposable derived mirrors that must be re-derived after spec pivots.
- [#arch] Release Metadata Discipline: Use a single release-prep command to enforce docs-impact checks, SemVer bumping in `.github/toji-version.json`, and changelog entry creation before maintainer commits.


### #fix
- [#fix] Invisible Governance Self-Blocking: When committing new files inside the Toji source repo itself, Toji's own pre-commit hook and `.git/info/exclude` rules will silently prevent `git add` from staging `.github/skills/` files. Use `--no-verify` only for framework source commits, never for consumer projects.
- [#fix] check.sh Flag Contract: Any flag passed by `update.sh` to `check.sh` must be explicitly handled in `check.sh`'s argument parser. An unrecognized flag causes `check.sh` to exit non-zero, which triggers `update.sh`'s rollback mechanism, silently reverting the entire update.
- [#fix] Transient Artifact Discipline: Never generate install-time receipt files under `.toji_tmp/` unless they are consumed by behavior; transient metadata creates commit noise and should be blocked by pre-commit guards.
- [#fix] Maintainer Release Hook Gap: Release metadata discipline must be enforced in the pre-commit hook template for source repos; documenting prepare-release alone does not prevent unbumped commits.
- [#fix] Commit-Time Release Automation: For source repos, pre-commit release prep should trigger on any non-metadata staged change and pass a docs-check bypass flag, otherwise normal maintainer commits can be blocked instead of auto-versioned.


### #perf

### #ux

### #stack
