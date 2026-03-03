# Toji Agent

A structured GitHub Copilot agent template for software teams who want consistent, well-reasoned AI assistance across the full development lifecycle — from requirements to deployment.

## Why This Exists

GitHub Copilot is powerful out of the box, but without structure it behaves inconsistently: it doesn't know your stack conventions, it skips planning, it produces visually generic UI, and it jumps to code before fully understanding the problem.

This template solves that by giving Copilot:
- **Written context** about your project, stack, and standards — so it doesn't guess
- **Structured workflows** (slash commands) that enforce good engineering habits
- **Domain-specific skills** that activate the right expertise for the task at hand
- **Phase documentation templates** that keep requirements, design, and implementation decisions in one place

The result is an agent that understands before it acts, follows your conventions without being reminded, and produces output that fits your codebase rather than generic patterns.

## Who It's For

- Solo developers and teams using GitHub Copilot Chat
- Projects of any size — works equally well on new and existing codebases
- Any stack — generic by default, with stack-specific conventions activated on demand

## What It Solves

| Problem | How this template addresses it |
|---|---|
| Agent ignores your conventions | `.github/copilot-instructions.md` sets global rules read on every interaction |
| Generic, forgettable UI output | `frontend-design` skill enforces distinctive aesthetic direction |
| Usability problems in generated UI | `ux-design` skill applies Nielsen's heuristics and Laws of UX |
| Agent jumps to code before understanding | `/new-requirement` and `/review-requirements` enforce problem clarity first |
| No consistency across features | `docs/ai/` phase templates keep decisions documented and reusable |
| Stack-specific rules get forgotten | `stack-*` skills activate authoritative conventions per project stack |
| Debugging by guessing | `/debug` skill enforces evidence-first root cause analysis |
| Commits with vague messages | `/create-commit-message` generates Conventional Commits from actual diff |

## What's Included

```
.github/
  copilot-instructions.md   # Global Copilot agent instructions
  prompts/                  # Slash commands for structured workflows (13 total)
    new-requirement, review-requirements, review-design
    execute-plan, update-planning, check-implementation
    writing-test, code-review, debug
    capture-knowledge, simplify-implementation, detect-stack
    create-commit-message
  skills/
    dev-lifecycle/SKILL.md          # End-to-end feature development phases
    debug/SKILL.md                  # Evidence-first debugging workflow
    simplify-implementation/SKILL.md # Refactoring and complexity reduction
    capture-knowledge/SKILL.md      # Document a module, file, or function
    technical-writer/SKILL.md       # Review and improve documentation
    stack-router/SKILL.md           # Detect stack and route to stack-specific skill
    stack-laravel-inertia-react/SKILL.md # Laravel + Inertia + React conventions
    stack-mern/SKILL.md             # MERN conventions
    frontend-design/SKILL.md        # Distinctive, production-grade UI design
    ux-design/SKILL.md              # Usability, flows, forms, and interaction patterns
docs/ai/
  requirements/README.md    # Template: problem statement, user stories, success criteria
  design/README.md          # Template: architecture, data models, API design
  planning/README.md        # Template: milestones, task breakdown, risks
  implementation/README.md  # Template: setup, patterns, error handling
  testing/README.md         # Template: coverage goals, test cases, reporting
  deployment/README.md      # Template: environments, process, checklist
  monitoring/README.md      # Template: metrics, alerting, incident response
```

## Install Options

### Option A: One-command install (recommended)

Install directly into your existing project without cloning manually:

```bash
curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/install.sh | bash -s -- --target .
```

Run this from your project root. Use `--target .` when you're already inside the target project.

Interactive installer will ask:
- How to handle `AGENTS.md` if it already exists (`keep-bridge`, `sidecar-only`, or `overwrite`)
- Whether to run stack detection immediately

Safe defaults:
- Merges `.github/` and `docs/` without overwriting existing files
- Copies `.gitignore` only if missing
- If `AGENTS.md` exists, keeps it and adds a Toji bridge reference + `AGENTS.toji-bridge.md`
- If `AGENTS.md` is missing, creates a minimal bridge `AGENTS.md`
- If stack detection is skipped or unsupported, Active Stack Profile stays `generic`

Useful flags:
- `--yes` non-interactive install with safe defaults
- `--dry-run` preview changes
- `--force` overwrite existing files (creates timestamped backups)
- `--detect-stack` force stack detection in non-interactive mode
- `--agents-mode keep-bridge|sidecar-only|overwrite` set AGENTS behavior explicitly

### Option B: Local installer after clone

```bash
git clone https://github.com/kevsmir02/toji-agent.git
cd toji-agent
chmod +x install.sh
./install.sh --target /path/to/your-project --yes
```

## Using with MCP Servers

Yes — Toji Agent is designed to work alongside MCP servers.

- MCP tools (for example Laravel Boost, memory servers, or custom project servers) provide execution capabilities and structured context
- Toji Agent provides governance: conventions, workflow, architecture discipline, and quality standards

Use this precedence if guidance conflicts:
1. Feature docs in `docs/ai/requirements/` and `docs/ai/design/`
2. Active stack skill from `.github/skills/`
3. `.github/copilot-instructions.md`
4. MCP/tool suggestions

In short: MCP is your tool layer; Toji is your policy layer.

## How to Use

### 1. Copy into your project

Copy the `.github/` and `docs/` folders into your project root. That's it — no install, no build step, no dependencies.

```bash
cp -r .github /path/to/your-project/
cp -r docs /path/to/your-project/
```

Or use this repo as a GitHub template: click **Use this template** at the top.

> **Already mid-project?** That's fine. Drop it in at any point. The skills and slash commands work immediately without any phase docs existing. For existing features you don't need to backfill requirements docs — just use the workflows going forward for new work. Run `/detect-stack` once to activate your stack's conventions.

### 2. Customize

- Edit `.github/copilot-instructions.md` to reflect your project's specific conventions, stack, and standards
- Add new skills to `.github/skills/` as markdown files following the same format as `debug/SKILL.md`
- Add new prompts to `.github/prompts/` for project-specific workflows

### 3. Workflow for each feature

Follow this sequence for consistent, well-documented feature development:

```
1. Create docs/ai/requirements/feature-{name}.md  (copy from docs/ai/requirements/README.md)
2. /review-requirements  →  fill gaps
3. Create docs/ai/design/feature-{name}.md        (copy from docs/ai/design/README.md)
4. /review-design        →  verify architecture
5. Create docs/ai/planning/feature-{name}.md      (copy from docs/ai/planning/README.md)
6. /execute-plan         →  implement task by task
7. /check-implementation →  verify alignment with design
8. /writing-test         →  write tests
9. /code-review          →  pre-push review
```

### 4. Using slash commands

In GitHub Copilot Chat, type `/` and select the prompt:

- `/new-requirement` — start a new feature, creates all phase docs
- `/review-requirements` — review a requirements doc for completeness
- `/review-design` — review a design doc for completeness
- `/execute-plan` — work through planning tasks one by one
- `/update-planning` — reconcile progress with planning doc
- `/check-implementation` — verify implementation matches design
- `/writing-test` — write tests for a feature
- `/code-review` — pre-push review against design docs
- `/debug` — structured root-cause analysis before touching code
- `/capture-knowledge` — document a module, file, or function
- `/simplify-implementation` — refactor code to reduce complexity
- `/detect-stack` — detect stack and update active stack profile
- `/create-commit-message` — generate a Conventional Commits message from current changes

### 5. Using skills

Skills are read automatically by Copilot when the context matches their `description`. You can also reference them explicitly:

| Skill | When to use |
|---|---|
| `dev-lifecycle` | Building a feature end-to-end |
| `debug` | Debugging bugs or regressions |
| `simplify-implementation` | Refactoring complex code |
| `capture-knowledge` | Documenting a module or function |
| `technical-writer` | Reviewing documentation |
| `stack-router` | Detect stack and route to stack-specific conventions |
| `stack-laravel-inertia-react` | Strict Laravel + Inertia + React conventions |
| `stack-mern` | Strict MERN conventions |
| `frontend-design` | Building distinctive UI — avoids generic AI aesthetics |
| `ux-design` | Usability, flows, forms, error states, and interaction patterns |

### Stack-specific behavior (non-generic mode)

This template supports manual stack activation while staying generic by default:

1. Run `/detect-stack`
2. The command detects markers from project files and builds a normalized stack id (e.g. `laravel-inertia-react`)
3. It resolves one of these skills if present:
  - `.github/skills/stack-{stack-id}/SKILL.md`
  - `.github/skills/{stack-id}/SKILL.md`
4. It updates the **Active Stack Profile** in `.github/copilot-instructions.md`:
   - `Mode: stack-specific` if skill found
   - `Mode: generic` if skill not found
5. Agent behavior follows that profile until `/detect-stack` is run again

Example: for Laravel + Inertia + React, create:

`.github/skills/stack-laravel-inertia-react/SKILL.md`

Then run `/detect-stack` once per session (or after major dependency changes) to activate it.

Included stack profiles in this starter:

- `.github/skills/stack-laravel-inertia-react/SKILL.md`
- `.github/skills/stack-mern/SKILL.md`

### 6. Adding more skills

Create `.github/skills/{skill-name}/SKILL.md` following this frontmatter format:

```markdown
---
name: your-skill
description: When to use this skill (triggers the agent to read it automatically)
---

# Skill Title
...instructions...
```

## Philosophy

Agents produce better output when they have written context. The problem with most Copilot setups is that the agent starts every conversation with no memory of your conventions, no understanding of the problem, and no awareness of decisions already made. It fills that gap with generic defaults.

This template takes a different approach: **write the context down, once, in a place the agent always reads.**

- `copilot-instructions.md` is global context — stack profile, code standards, engineering discipline — read on every interaction
- `docs/ai/` is feature context — requirements, design decisions, implementation notes — read when working on a specific area
- Skills are domain expertise — authoritative rules for specific concerns (debugging, UI, UX, stack conventions) — activated when the task matches

The slash commands enforce the discipline that makes this work: understand the problem before writing code, design before implementing, test alongside development, review before pushing. They're not mandatory ceremonies — use the ones that fit the task. A two-line bug fix doesn't need a requirements doc. A new feature that touches the data model does.


