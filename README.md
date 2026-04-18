# Toji Agent

Toji is a governance layer for AI coding agents. It installs into any Git repository and enforces engineering discipline — structured planning, test-driven implementation, security checks, and evidence-first debugging — using a **modular, multi-agent architecture**, native **Hooks**, and local-only governance artifacts.

Governance files stay off shared Git history by default. Your team sees only product code.

## What it does

- **Specialized Multi-Agent architecture**: Deploys localized domain experts like `Toji Builder`, `Toji Planner`, and `Code Reviewer`, with seamless handoffs and sub-agent workflows. 
- Loads domain-specific **Skill files** before acting (`security`, `testing-strategy`, `accessibility`, `verification-before-completion`, and others), compatible with the Agent Skills open standard.
- Enforces Iron Laws: write a failing test first, verify with evidence before fixing, validate inputs at boundaries, load documentation before integrating an API.
- Native **VS Code Copilot Hooks** actively enforce Security guardrails (blocking destructive shell commands) and trigger Code Quality checks (Post-edit validation) deterministically, regardless of AI prompt decisions.
- Keeps planning, task, and memory artifacts in `.agent/` and `docs/ai/` — locally excluded from commits via `.git/info/exclude` and a pre-commit hook.
- Resumes where it left off across sessions utilizing **Copilot Memory** and `.agent/task.md` as a checkpoint file.

## Specific Scenario: Building a New Feature

Here is what the Toji multi-agent workflow looks like when building a new "User Profile Setup" feature:

1. **Start the Session:** Open Copilot Chat, select the main **@Toji** agent and ask to build the feature: "I want to build a User Profile Setup page."
2. **Context Auto-Injection:** Because of the `SessionStart` hook, Toji immediately knows your project details and what tech stack is being used.
3. **The Handoff:** Since you asked for a new feature, Toji prompts you with a guided click button to hand off to **@Toji Planner**. 
4. **Planning & Research:** You click the handoff. **@Toji Planner** spins up a hidden **Researcher** sub-agent to analyze the best way to integrate with your existing Database, and then asks you 2-3 precise questions to resolve edge cases (Ambiguity Resolver skill). Once resolved, it writes out the implementation plan to `.agent/implementation_plan.md` and generates tasks.
5. **Implementation:** A new handoff button appears: "Build It". Clicking it transitions the context to **@Toji Builder**. It uses the TDD Runner sub-agent in read/write mode to write the tests and construct the UI based precisely on the agreed specs. Security hooks silently ensure you don't execute dangerous bash codes.
6. **Code Review:** After the builder is done, click the "Review Code" handoff. The **@Code Reviewer** adversarial persona evaluates everything the builder did and ensures all requirements passed!

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
5. Ask Toji Planner to build something and let the multi-agent system handoffs carry the work!
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
5. Begin your work with Toji Planner!
```

## Daily workflow

The standard operating procedure leverages handoffs natively via custom agents. Start a session with **Toji**, and follow the action buttons:
```
📋 Plan Feature   →  @Toji Planner generates implementation plan and task file natively.
🔨 Build It       →  @Toji Builder implements tasks sequentially.
🔍 Review Code    →  @Code Reviewer runs adversarial validation to ensure rules didn't drift.
```

The agent will seamlessly navigate the lifecycle dynamically resolving problems.

## Slash command reference (Legacy/Optional)
You can still directly invoke workflows manually via chat skills if you need to perform an isolated operation without the handoff flow:

| Command | Purpose |
|---|---|
| `/onboard` | Initialize governance baseline |
| `/detect-stack` | Detect framework and activate stack skill |
| `/verify` | Spec compliance, quality, cleanup audit |
| `/debug` | Evidence-first root cause analysis |
| `/clarify` | Resolve ambiguity before planning |
| `/refactor` | Simplify existing code |
| `/document` | Document a module and create session handover |
| `/commit` | Generate a Conventional Commits message |
| `/scan` | Produce a codebase architecture map |
| `/lesson` | Manually record a governance instinct |

## Read more

[DOCUMENTATION.md](DOCUMENTATION.md) — architecture, governance internals, folder structure, and script behavior.
