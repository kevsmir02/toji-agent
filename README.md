# Toji Agent

## Quick Intro
Toji Agent is a structured GitHub Copilot setup for real project work.
It gives Copilot consistent guidance through:
- project rules (`.github/copilot-instructions.md`)
- reusable skills (`.github/skills/`)
- slash-command workflows (`.github/prompts/`)
- lightweight AI docs (`docs/ai/`)

Use it when you want less random AI output and more predictable engineering behavior.

What you get immediately after install:
- a policy layer for Copilot decisions
- repeatable prompts for planning, building, testing, and reviewing
- optional local guards to prevent committing AI config files

## Features
- Clear global instruction layer for coding standards and decision precedence
- Prompt-based workflows (`/plan`, `/build`, `/verify`, `/review`, etc.)
- Domain skills for debugging, refactoring, docs, UI/UX, and stack routing
- Optional stack detection (`/detect-stack`) for stack-specific conventions
- Optional local Git guards to block committing/pushing Toji AI config files

## Installation
### Option A: One command (recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/install.sh | bash -s -- --target .
```

Interactive curl install:
```bash
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/install.sh | bash -s -- --i
```

### Option B: Local installer
```bash
git clone https://github.com/kevsmir02/toji-agent.git
cd toji-agent
chmod +x install.sh
./install.sh --target /path/to/your-project
```

Interactive mode:
```bash
./install.sh --i
```
This prompts for target path and common options.

### Useful flags
- `--dry-run` preview changes only
- `--force` backup and overwrite existing Toji-related targets
- `--detect-stack` detect stack and update active profile
- `--install-hooks` install local `pre-commit` + `pre-push` guards
- `--i` or `--interactive` run guided interactive setup
- `--ui` force colorful installer UI in terminal
- `--no-ui` disable installer UI (plain output)
- `--agents-mode keep-bridge|sidecar-only|overwrite` control `AGENTS.md` behavior

Default install behavior:
- overwrite `.github/`
- safe-merge `docs/` (keeps existing files)
- keep existing `.gitignore` (copy only if missing)

## Uninstallation
### One command
```bash
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/uninstall.sh | bash -s -- --target .
```

### Local
```bash
chmod +x uninstall.sh
./uninstall.sh --target /path/to/your-project
```

Use `--dry-run` to preview removals.

Uninstaller removes only Toji-related paths:
- `.github/copilot-instructions.md`
- `.github/prompts/`
- `.github/skills/`
- `docs/ai/`
- `AGENTS.toji-bridge.md`
- Toji bridge block from `AGENTS.md` (if present)
- Toji-managed `.git/hooks/pre-commit` and `.git/hooks/pre-push` (if present)

## Commands / Prompts
Run these in Copilot Chat:
- `/plan` plan non-trivial work
- `/build` implement step-by-step
- `/verify` check implementation vs requirements
- `/write-tests` add/expand tests
- `/review` pre-push code review
- `/pr` draft PR description
- `/debug` structured root-cause analysis
- `/document` generate/update technical docs
- `/refactor` simplify existing implementation
- `/detect-stack` activate stack profile
- `/commit` generate Conventional Commit message
- `/scan` refresh stack profile and codebase map

Recommended minimal set for most features:
- `/plan` -> `/build` -> `/verify` -> `/write-tests` -> `/review`

## How To Use
1. Install Toji Agent into your project.
2. (Optional) Run `/detect-stack`.
3. For each feature, create or update docs in `docs/ai/features/`.
4. Use a simple flow: `/plan` -> `/build` -> `/verify` -> `/write-tests` -> `/review` -> `/pr`.
5. If you do not want AI files in Git, install with `--install-hooks` and/or uninstall after delivery.

First-run quick example:
1. `./install.sh --target . --detect-stack --install-hooks`
2. Open Copilot Chat and run `/plan` for your next task.
3. Build with `/build`, then run `/verify` and `/review` before push.

## Important Notes
- Git hooks are local by default (`.git/hooks`) and not shared unless your team standardizes hook distribution.
- `.gitignore` helps with untracked files, but hooks are stronger protection for already tracked files.
- If AI files were committed in the past, hooks prevent future pushes but do not rewrite history.
