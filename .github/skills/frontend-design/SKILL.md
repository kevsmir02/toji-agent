---
name: frontend-design
description: Create production-grade frontend interfaces with a functional minimalist default. Use this skill when the user asks to build web components, pages, dashboards, React components, HTML/CSS layouts, or when styling any web UI.
---

This skill guides creation of production-grade frontend interfaces with a Notion-inspired functional minimalist baseline. The priority is system rigor: clear structure, restrained surfaces, dependable spacing, and quiet polish.

The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

## Design Thinking

Before coding, understand the context and commit to a functional minimalist direction:
- **Purpose**: What task does the interface support? What needs to feel effortless?
- **Hierarchy**: What are the primary surfaces, secondary controls, and background details?
- **Constraints**: Technical requirements, performance expectations, and accessibility requirements. Always consider `prefers-reduced-motion` and WCAG AA contrast ratios.
- **System Rigor**: Favor consistency, legibility, and predictable composability over novelty.

Then implement working code that is:
- Production-grade and functional
- Visually restrained and highly legible
- Systematic in spacing, alignment, and component behavior
- Responsive and mobile-first unless explicitly desktop-only
- Calm enough that content and workflows stay primary

## Functional Minimalist Defaults

Focus on:
- **Typography**: Default to Inter or a clean system stack. Use typographic hierarchy through size, weight, and spacing rather than expressive display fonts.
- **Color**: Favor monochrome-heavy palettes with sparse accent color used only for status, focus, or primary actions. Prefer off-white surfaces, soft neutrals, charcoal text, and subtle dividers.
- **Borders and Surfaces**: Use light borders, hairlines, and gentle background shifts to separate content. Prefer subtle surface elevation over dramatic depth.
- **Spacing**: Use generous whitespace and consistent spacing scales to define structure. Density should feel intentional, never cramped.
- **Motion**: Keep transitions subtle and utility-driven. Use motion to clarify state changes, not to decorate the interface. Always provide `prefers-reduced-motion` fallbacks.
- **Shadows**: Use minimal shadows only when necessary for layering or focus. Avoid complex, colorful, or cinematic shadow treatments.

## System Rigor Rules

- Prefer reusable component patterns over one-off visual flourishes.
- Default to rectilinear layouts, clear columns, and predictable stacking behavior.
- Keep controls understated until interaction or focus makes them relevant.
- Use iconography sparingly and pair icon-only controls with accessible labeling.
- Treat UI polish as precision in spacing, borders, hover states, and typography.
- Avoid gradients, glow effects, ornamental textures, and expressive visual motifs unless explicitly requested.

## Accessibility Baseline

- Use semantic HTML structure.
- Ensure keyboard navigability and visible focus styles.
- Provide ARIA labels for icon-only controls.
- Include meaningful alt text for informative images.
- Respect `prefers-reduced-motion`.
- Maintain WCAG AA contrast ratios.

## What to Avoid

Do not default to:
- Bold, high-intensity visual directions
- Saturated palettes or colorful gradients
- Decorative complexity that competes with content
- Heavy shadows, glassmorphism, or layered visual effects
- Experimental typography that reduces readability
- Layouts optimized for visual surprise instead of task clarity

## If Unsure

Choose the more restrained option. Prioritize calm structure, readable typography, subtle borders, and operational clarity over creative flair.
