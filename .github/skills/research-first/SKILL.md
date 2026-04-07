---
name: research-first
description: "Passive core skill — forces documentation/web lookup before writing implementation code for any framework, library, API, or external service. Prevents hallucinated APIs and outdated patterns. Fires via 1% Rule automatically."
globs: ["**/*.ts","**/*.tsx","**/*.js","**/*.jsx","**/*.php","**/*.py","**/*.go","**/*.rb","**/*.java","**/*.cs","**/*.swift","**/*.kt","**/*.vue","**/*.blade.php"]
---

# Research-First Skill

This is a **passive core skill**. It activates automatically via the 1% Rule whenever the agent detects work involving a framework, library, API, or external integration. You do not need to invoke it manually.

## Why This Exists

AI agents confidently generate plausible-looking code that calls APIs that don't exist, use deprecated method signatures, or follow outdated patterns. A single documentation lookup before writing code eliminates this entire class of failure.

## Trigger Conditions (1% Rule)

This skill fires when the task involves **any** of:
- A framework or library the agent is not 100% certain about (version-specific APIs)
- A third-party API or service integration (Stripe, Twilio, SendGrid, etc.)
- Database driver or ORM features beyond basic CRUD
- A package or dependency the agent has not seen in this project before
- Cloud provider services (AWS, GCP, Azure, Vercel, etc.)
- Authentication/OAuth flows with external providers

## Workflow

### 1. Detect research need (silent)
Before writing any implementation code for the detected topic, pause and evaluate: *"Am I 100% certain this API/method/pattern exists in the exact version used by this project?"*

If the answer is anything less than absolute certainty, proceed to step 2.

### 2. Perform ONE targeted lookup
- Use MCP tools, web search, or documentation search to find the **official documentation** for the specific version in use.
- Prioritize: official docs → GitHub repo README → Stack Overflow accepted answers.
- **Budget rule:** One search call per topic. Do not chain multiple searches unless the first returned zero results.

### 3. Cite before you write
Before producing implementation code, briefly state (in 1-2 lines):
- What you looked up
- What you confirmed (e.g., "Confirmed: `stripe.paymentIntents.create()` accepts `automatic_payment_methods` in Stripe SDK v14+")

### 4. Write with confidence
Now write the implementation code, knowing the API surface is verified.

## What This Skill Does NOT Do

- It does **not** trigger for basic language constructs (loops, conditionals, string manipulation).
- It does **not** trigger for project-internal code (calling your own functions/classes).
- It does **not** spawn sub-agents or external services.
- It does **not** perform recursive research chains — one lookup, one confirmation, move on.

## Cost Control

This skill is designed for a solo developer on a budget:
- **One search per topic** — not per file, not per function.
- **Skip if certain** — if the agent has already confirmed the API in this session, do not re-search.
- **No sub-agents** — all research happens in the primary chat thread.

## Enforcement

| Violation | Required action |
| :--- | :--- |
| Writing integration code without a documentation lookup | Flag and verify retroactively before the code is finalized |
| Citing a deprecated API after lookup | Update the implementation to the current API |
| Chaining 3+ searches on a single topic | Stop researching, use best available result |
