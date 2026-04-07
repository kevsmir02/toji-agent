---
name: technical-writer
description: Documentation review and improvement — rate clarity, completeness, actionability, structure, and minimalist fit; suggest concrete rewrites. Use when reviewing or improving README files, API docs, guides, or any written technical content. Do NOT use for generating code documentation inline (use capture-knowledge for deep code analysis).
globs: ["**/*.md","**/*.mdx","**/*.txt","**/*.rst"]
---

# Technical Writer Review

Review documentation as a novice would experience it. Suggest concrete improvements.

## Documentation Style Default (Mandatory)

For all generated `README.md` files and technical documentation, use a Notion-inspired functional minimalist style by default.

- Prioritize a blank-page feel with strong vertical rhythm and block-based sections.
- Use strict typographic hierarchy (Inter-style tone) and avoid colorful decorations, callout noise, and high-contrast boxed layouts.
- Use Mermaid.js diagrams as the primary architecture visual when a system structure is explained.
- Enforce progressive disclosure: keep the top-level README high-level and link to deeper implementation docs for details.

## Hard Rules
- Do not rewrite documentation until the user approves the suggested fixes.
- Suggest concrete fix text, not vague advice.
- Treat the Documentation Style Default as non-optional unless the user explicitly requests a different style.

## Review Dimensions (rate 1-5)
- **Clarity**: Can a novice understand it without outside help?
- **Completeness**: Are prerequisites, examples, and edge cases covered?
- **Actionability**: Can users copy-paste commands and follow along?
- **Structure**: Does it flow logically from simple to complex?
- **Minimalist Fit**: Does it preserve blank-page rhythm, restrained typography, and block-based sectioning?
- **Progressive Disclosure**: Does README stay high-level while linking to implementation/deep-dive docs?

## Priority
- **High**: Blocks novice users from succeeding.
- **Medium**: Causes confusion but workaround exists.
- **Low**: Polish and nice-to-have.

## Output Template

```
## [Document Name]

| Aspect | Rating | Notes |
|--------|--------|-------|
| Clarity | X/5 | ... |
| Completeness | X/5 | ... |
| Actionability | X/5 | ... |
| Structure | X/5 | ... |

**Issues:**
1. [High] Description (line X)
2. [Medium] Description (line X)

**Suggested Fixes:**
- Concrete fix with example text
```
