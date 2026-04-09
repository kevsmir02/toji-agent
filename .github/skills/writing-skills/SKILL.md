---
name: writing-skills
description: "Meta-skill for creating and hardening Toji skills. Applies TDD to skill development itself: RED (baseline fail without the skill), GREEN (write the skill), REFACTOR (close loopholes). Ensures every new skill handles real pressure scenarios before it ships."
globs: []
---

# Writing Skills

This skill governs how to write, test, and harden new skills in the Toji framework. Writing a skill that passes in ideal conditions is easy. Writing a skill that holds under pressure is the goal.

A skill that can be reasoned around is not a skill — it is a suggestion.

---

## TDD for Skill Development

Apply Red-Green-Refactor to skill writing exactly as you would to code.

### RED — Establish the Baseline Failure

Before writing the skill, construct a pressure scenario where the agent fails in the way the skill is meant to prevent. The scenario must:

- Be a realistic, high-pressure situation (see Pressure Archetypes below)
- Show the exact failure mode (rationalization, shortcut, claim without evidence, etc.)
- Confirm the baseline agent response **without** the skill violates the intended behavior

**Do not write the skill until you have written the scenario and confirmed the baseline fails.**

### GREEN — Write the Skill

Write the skill content until it forces the correct response in the pressure scenario:

1. Start with the trigger condition (when does this skill fire?)
2. State the core rule plainly — one sentence if possible
3. Add the specific sub-steps or protocol that enforce the rule
4. Add the Anti-Rationalization table targeting the rationalizations from the RED scenario
5. Re-run the pressure scenario mentally; the skill should now handle it

**The skill is green when the pressure scenario passes.**

### REFACTOR — Close Loopholes

Apply additional pressure scenarios of different types (see archetypes). For each:

1. Run the scenario against the current skill
2. If the agent can still rationalize around it, the skill has a loophole
3. Patch the loophole — add a rule, anti-rationalization entry, or clarifying constraint
4. Re-run all previous scenarios to confirm no regression

**Minimum: test 3 distinct pressure archetypes before declaring the skill complete.**

---

## Pressure Archetypes

These are the core patterns agents use to bypass discipline. Test against at least 3 per skill.

| Archetype | Trigger phrase pattern | What to watch for |
| :--- | :--- | :--- |
| **Time pressure** | "We're behind, skip this for now" | Agent abbreviates or skips the skill's protocol entirely |
| **Sunk-cost + exhaustion** | "We've already done so much work" | Agent justifies keeping violating work rather than starting over |
| **Authority pressure** | "My tech lead says we don't do it this way" | Agent defers to stated authority over the skill's rules |
| **Social proof** | "Everyone does it this way" | Agent accepts common practice as superseding the skill |
| **Pragmatic exception** | "The spirit of the rule is fine, let's be pragmatic" | Agent claims to follow intent while violating the letter |
| **Confidence claim** | "I'm confident this works" | Agent replaces evidence with self-assertion |
| **Scope minimization** | "This is just a small change" | Agent claims the small size exempts it from the rule |

---

## Skill File Structure (mandatory)

Every skill file must follow this structure exactly:

```yaml
---
name: <slug-in-kebab-case>
description: "<CSO-compliant description — see rules below>"
globs: ["<glob patterns if path-based, otherwise []>"]
---
```

Followed by:
1. **Brief statement** of what the skill governs (1-2 sentences)
2. **The core rule** stated plainly
3. **Sub-steps or protocol** that enforce the rule
4. **Anti-Rationalization table** (at minimum 5 entries targeting real bypasses)
5. **Session Closure — Atomic Instinct** block (mandatory footer)

---

## CSO Description Guidelines (Critical)

The `description` field in the frontmatter is the **only** context that determines if this skill loads. It must be written precisely.

**Rules:**
- Describe **when to trigger** the skill, not what the skill contains
- State the problem domain that activates it, not the solution it provides
- Do not summarize the workflow steps in the description — that causes shortcut-following without reading the skill body
- The description must pass this test: a developer reading only the description should know *when to invoke* this skill but not *what it will say*

**Do:**
> "Passive core skill — fires before any completion claim. Blocks Done/Working claims without fresh command output evidence."

**Do not:**
> "Runs verification gate: identify command, run it, read output, verify criteria, then claim complete."

The second version teaches an agent to approximate the skill without reading it.

---

## Checklist Before Shipping a New Skill

- [ ] Frontmatter: `name`, `description` (CSO-compliant), `globs` all present
- [ ] Flat namespace: skill slug added to skills table in `.github/copilot-instructions.md`
- [ ] No cross-references to other skill internals (skills must be independently loadable)
- [ ] Anti-Rationalization table with ≥5 entries
- [ ] Session Closure footer is present
- [ ] Tested against ≥3 pressure archetypes (document which ones)
- [ ] `node scripts/check-skill-refs.js --verbose` returns exit 0

---

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
