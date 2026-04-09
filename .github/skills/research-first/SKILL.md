---
name: research-first
description: "Passive core skill — Enforces documentation lookup before writing integration code for any framework, API, or external service. Prevents hallucinated API shapes, deprecated method usage, and broken integrations by requiring a cited source before implementation."
globs: []
---

# Research-First Skill

This is a **passive core skill**. It activates automatically via the 1% Rule whenever the agent is about to write integration code for a framework, library, or external API it has not verified in the current session.

## Trigger Conditions (1% Rule)

This skill fires when the task involves **any** of:
- Writing a new integration with a third-party library or SDK (payment processors, email providers, auth libraries, cloud SDKs)
- Calling an external API endpoint for the first time in the codebase
- Using a framework feature that has known version differences (e.g., Next.js App Router vs Pages Router, React 18 vs 19 APIs, Laravel 10 vs 11 conventions)
- Installing a new package and writing code that consumes its public API
- Implementing a protocol with a specification (OAuth 2.0, WebSockets, SSE, SAML, etc.)
- Upgrading a major dependency version and touching code that uses the changed API

## Research Protocol

When triggered, the agent **must** complete this sequence before writing integration code:

### Step 1 — Identify the Dependency

State explicitly:
- Package name and version (from `package.json`, `composer.json`, `pyproject.toml`, etc.)
- The specific feature or API surface being used
- The framework/runtime context (e.g., "Next.js 15 App Router Server Component")

### Step 2 — Verify via MCP or Codebase

**If an MCP tool is available** (fetch-mcp, github-mcp, or framework-specific MCP like laravel-boost):
1. Use the MCP tool to retrieve the current API documentation or source.
2. Cite the retrieved URL or endpoint as the source.

**If no MCP tool is available**:
1. Check if the package's usage already exists in the codebase (`#codebase` search) — infer from existing working patterns.
2. State that docs could not be live-verified and note which version assumption was made.

### Step 3 — State the Assumption or Citation

Before writing any integration code, produce one of:
- **Verified**: "Source: [URL or MCP retrieval]. Confirmed `methodName(param)` signature."
- **Inferred from codebase**: "Based on existing usage in `src/lib/stripe.ts`, confirmed `stripe.charges.create()` pattern."
- **Unverified assumption**: "Docs unavailable — using version assumption: `package@x.y.z`. Flag for review if this breaks."

### Step 4 — Write Integration Code

Only after Step 3 is documented, write the integration code aligned with the verified or stated assumption.

## Anti-Patterns (Blocked)

The following are forbidden without a corresponding Step 3 citation:

- Guessing parameter names or shapes for external library calls
- Assuming a method signature that was available in a prior major version
- Copying a Stack Overflow snippet without verifying it matches the installed version
- Using `any` typing on an external API response to avoid verifying its actual shape
- Hardcoding API endpoint paths that are subject to versioning (use the SDK's built-in methods instead)

## Cost Control

- One lookup per distinct dependency per session — do not re-verify the same library call if it was already researched in the same task.
- Do not perform research for standard library APIs (language built-ins) that have stable, well-known signatures.
- If research adds significant delay and the user has explicitly asked for speed, state the unverified assumption clearly and proceed — never skip the disclosure.

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
