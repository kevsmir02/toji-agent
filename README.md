# Toji Agent

Stop shipping AI-generated mediocrity.

Toji exists for one reason: most AI coding assistants optimize for speed, not engineering integrity. That creates lazy plans, fake confidence, skipped tests, and brittle code. Toji hard-locks the opposite behavior with adversarial governance.

## Why Toji Exists

- Enforce discipline when an agent would rather "just code".
- Block hallucinated architecture and speculative fixes.
- Require verification before trust.
- Keep governance local and invisible to client-facing Git history.

Toji does this with two pillars:

1. **Iron Laws**: non-negotiable rules such as the 1% Rule, TDD Delete Rule, Security checks, and RCA-first debugging.
2. **Invisible Governance**: local `.git/info/exclude` + custom `pre-commit` guardrails that keep Toji artifacts out of shared commits by default.

## What Changed In The Refactor

The execution engine moved into `.agent/`, while canonical skills remain in `.github/skills/`.

- Canonical skills live in `.github/skills/` (for example: `security/SKILL.md`, `ui-reasoning-engine/SKILL.md`).
- Workflows now live in `.agent/workflows/` (for example: `toji-plan.md`, `toji-build.md`, `toji-verify.md`).
- Antigravity and Copilot consume the same governance source via `docs/ai/governance-core.md` and sync tooling.

## Quick Start

Run these commands from a Git repository root.

### Linux and macOS

Install default mode:

```bash
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/install.sh | bash
```

Install Antigravity-only mode:

```bash
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/install.sh | bash -s -- --antigravity
```

Install both bundles:

```bash
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/install.sh | bash -s -- --both
```

### Windows (PowerShell wrapper)

Windows support is native through PowerShell launchers that bridge into `bash` (Git Bash or WSL) and forward flags to Linux core scripts.

Install default mode:

```powershell
iwr https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/windows/windows_install.ps1 -OutFile windows_install.ps1
./windows_install.ps1
```

Antigravity-only:

```powershell
./windows_install.ps1 -Antigravity
```

Both bundles:

```powershell
./windows_install.ps1 -Both
```

## Daily Lifecycle

1. `/onboard`
2. `/plan`
3. `/build`
4. `/verify`
5. `/review`

This is not optional ceremony. It is the contract.



## Core Workflow Files

- `.agent/workflows/toji-onboard.md`
- `.agent/workflows/toji-plan.md`
- `.agent/workflows/toji-build.md`
- `.agent/workflows/toji-verify.md`
- `.agent/workflows/toji-debug.md`
- `.agent/workflows/toji-clarify.md`

## Invisible Governance In One Minute

During install and update, Toji:

- appends protected paths to `.git/info/exclude` (idempotent, mode-aware)
- injects a Toji `pre-commit` hook that blocks accidental staging of governance artifacts
- preserves local project memory surfaces such as `docs/ai/` and lessons files

Result: governance is always active locally, while client-facing commit history stays clean.

## Commands You Will Actually Use

- `/onboard` - initialize governance baseline and Line in the Sand
- `/plan` - produce implementation plan and execution tasks
- `/build` - implement tasks under strict Red-Green-Refactor
- `/verify` - spec compliance, quality checks, cleanup audit
- `/review` - adversarial quality gate before push
- `/debug` - evidence-first root cause workflow



## Read Next

- [DOCUMENTATION.md](DOCUMENTATION.md) for full architecture, script behavior, install and uninstall procedures, and governance internals.
