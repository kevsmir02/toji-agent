# Toji Agent

Toji is a governance layer for AI coding agents. It installs into any Git repository and enforces engineering discipline — structured planning, test-driven implementation, security checks, and evidence-first debugging — through skill files, Iron Laws, and local-only governance artifacts.

Governance files stay off shared Git history by default. Your team sees only product code.

## What it does

- Loads domain-specific skill files before acting (`security`, `testing-strategy`, `accessibility`, `verification-before-completion`, and others).
- Enforces Iron Laws: write a failing test first, verify with evidence before fixing, validate inputs at boundaries, load documentation before integrating an API.
- Blocks completion claims — "Done!", "should work", "I'm confident" — without fresh terminal output as evidence.
- Keeps planning, task, and memory artifacts in `.agent/` and `docs/ai/` — locally excluded from commits via `.git/info/exclude` and a pre-commit hook.
- Resumes where it left off across sessions using `.agent/task.md` as a checkpoint file.
- Includes anti-rationalization tables in core skills that pre-emptively name the excuses agents use to skip process — and counter them.

## Install

Run from the root of the target Git repository.

**Linux / macOS**

```bash
# GitHub Copilot (default)
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/install.sh | bash

# Antigravity only
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/install.sh | bash -s -- --antigravity

# Both
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/install.sh | bash -s -- --both
```

**Windows (PowerShell — requires Git Bash or WSL)**

```powershell
# GitHub Copilot (default)
iwr https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/windows/windows_install.ps1 -OutFile windows_install.ps1
./windows_install.ps1

# Antigravity only
./windows_install.ps1 -Antigravity

# Both
./windows_install.ps1 -Both
```

After install, verify:

```bash
# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/check.sh | bash

# Windows
./windows_check.ps1
```

## Update

```bash
# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/update.sh | bash

# Windows
./windows_update.ps1
```

The updater preserves `docs/ai/` and `.github/lessons-learned.md`. It re-applies governance excludes and refreshes the pre-commit hook idempotently.

## Uninstall

```bash
# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/uninstall.sh | bash -s -- --target .

# Windows
./windows_uninstall.ps1 -Target .
```

## Onboarding

### New project

Run `/onboard` in your AI agent after installing Toji. This sets up:
- The **Line in the Sand** (governance start date) in `docs/ai/README.md`.
- `docs/ai/` as your local working memory for features, implementation notes, and test strategy.
- Stack detection via `/detect-stack` to activate the correct stack skill.

```
1. Install Toji (see above)
2. Open your AI agent (Copilot / Antigravity)
3. Run: /onboard
4. Run: /detect-stack
5. Start work with: /plan
```

### Existing project

Run `/onboard` and select **Legacy Integration** mode. This:
- Scans the codebase and baselines existing routes and components as **Legacy/Accepted** in `docs/ai/onboarding/legacy-baseline.md`.
- Establishes the Line in the Sand so new code is governed while old code is not retroactively penalized.
- Produces an **Integrity Roadmap** listing tech debt to address incrementally.

```
1. Install Toji (see above)
2. Run: /onboard  →  choose Legacy Integration
3. Run: /detect-stack
4. Review docs/ai/onboarding/legacy-baseline.md
5. Start work with: /plan
```

## Daily workflow

```
/plan     →  generate implementation plan and task file
/build    →  implement one task at a time, test-first
/verify   →  confirm implementation matches requirements
/review   →  adversarial code review (dispatches dedicated reviewer agent)
/finish   →  verify tests, choose integration method, clean up task files
```

For debugging: `/debug`
For ambiguous requests: `/clarify`
For documentation: `/document`

## Slash command reference

| Command | Purpose |
|---|---|
| `/onboard` | Initialize governance baseline |
| `/detect-stack` | Detect framework and activate stack skill |
| `/plan` | Generate feature brief and task file |
| `/build` | Implement a task under TDD |
| `/build-tdd` | Like `/build` but writes failing tests first |
| `/verify` | Spec compliance, quality, cleanup audit |
| `/review` | Adversarial pre-push gate |
| `/debug` | Evidence-first root cause analysis |
| `/clarify` | Resolve ambiguity before planning |
| `/refactor` | Simplify existing code |
| `/document` | Document a module and create session handover |
| `/commit` | Generate a Conventional Commits message |
| `/scan` | Produce a codebase architecture map |
| `/lesson` | Manually record a governance instinct |

## Read more

[DOCUMENTATION.md](DOCUMENTATION.md) — architecture, governance internals, folder structure, and script behavior.
