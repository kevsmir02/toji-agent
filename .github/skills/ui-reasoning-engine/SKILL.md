---
name: ui-reasoning-engine
description: Intelligent Design System Generation. Use this skill BEFORE writing any frontend UI code (React, Vue, HTML, Blade, etc.). It generates context-aware, adaptive design systems (colors, typography, spacing) based on project type.
globs: ["**/*.tsx","**/*.jsx","**/*.css","**/*.scss","**/*.html","**/*.blade.php","**/*.vue"]
---

This skill governs the creation of dynamic, context-aware design systems using the local UI/UX Pro Max Reasoning Engine. 

## The Reasoning Engine Ritual (Non-Optional)

Before you write or modify UI code for a new feature, page, or application, you **MUST** establish the design system. Do not invent unauthorized colors or ad-hoc typography.

### Step 1: Generate the Design System
Unless the project already has an established `design-system/.../MASTER.md` file that governs this feature, you must execute the Reasoning Engine to generate one.

Run the following command:
```bash
python3 .github/skills/ui-reasoning-engine/scripts/search.py "<product type or description>" --design-system --persist -p "<Project Name>"
```
*Example queries: "SaaS dashboard", "e-commerce luxury", "fintech banking", "crypto landing page"*

*(Note: If you are building a specific page, you can append `--page "<page-name>"` to the command to locally generate page-specific overrides.)*

### Step 2: Read the Generated System (Hierarchical Retrieval)
The script will output files into `design-system/<project-slug>/`.

When implementing a UI:
1. Always check if a page override exists: `design-system/<project-slug>/pages/<page-name>.md`.
2. If it exists, its rules **override** the Master file.
3. If it does not exist, strictly follow `design-system/<project-slug>/MASTER.md`.

You MUST silently read and internalize these files before outputting any UI code.

### Step 3: Architecture Lock
After generating or reading the assigned design system files, state the following to the user:
- **Selected Style & Pattern:** (e.g. "Minimalism | Dashboard + Analytics")
- **Core Colors Selected:** (list the Hex codes returned for Primary, Background, Accent)
- **Typography:** (list the fonts generated)

Ask the user to confirm the design system visually before proceeding to write the UI code. Do not proceed until confirmed.

## Implementation Standards
- Adhere strictly to the spacing variables, classes, and HEX codes defined in the `MASTER.md` or page-specific overrides.
- Do not default to generic Tailwind classes like `bg-blue-500` if the engine supplied a specific primary Hex token. Always wire the generated CSS variables or use arbitrary values (e.g., `bg-[#2563EB]`).
- Check the "Pre-Delivery Checklist" provided at the bottom of the generated design system (WCAG contrast, touch targets, transitions) before completing the component.
