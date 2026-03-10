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
- **Typography**: Strictly use Inter or a clean system sans-serif stack. Establish hierarchy through weight and spacing, with `600` for headings and `400` for body text, rather than relying on color shifts.
- **Color**: Default to a soft dark theme. Never use pure black `#000000`.
- **Dark Theme Tokens**: Use these defaults unless the user explicitly requests a different palette:
	- Background: `#131314` or `#1e1e1e`
	- Surface/Card: `#2b2b2b`
	- Border: `#3c3c3c`
	- Text: off-white or Gray-200 equivalent for readable contrast
- **Borders and Surfaces**: Use subdued borders and low-contrast surface separation. Surfaces should feel gently layered, not sharply boxed.
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
- Prefer modular, block-based composition over dashboard card mosaics.
- Use a blank-page main content area where blocks are separated by spacing and subtle dividers rather than heavy outer containers.

## Strict Technical Requirements (Hard Gates)

These requirements are mandatory for every feature implementation:

- Every list or table feature must include an Empty State block design in the shipped UI.
- Every async action must render Skeleton Loaders that mirror the final block structure.
- Every hidden menu action must have a documented keyboard shortcut in feature docs or UI help text.
- All margins and padding must align to a strict 8px grid system.
- Use a maximum of 3 font sizes across the feature.

## Block Interaction Rules

- Treat content modules as block rows within a calm vertical flow.
- When hovering a block, apply only a very faint highlight such as `#ffffff0a`.
- On block hover or active state, reveal a 6-dot drag handle icon as the movement affordance.
- Keep drag handles, move controls, and block menus hidden until hover, focus, or active state.
- Preserve low visual noise: hover states should clarify interactivity without creating strong contrast jumps.

## Accessibility Baseline

- Use semantic HTML structure.
- Ensure keyboard navigability and visible focus styles.
- Provide ARIA labels for icon-only controls.
- Include meaningful alt text for informative images.
- Respect `prefers-reduced-motion`.
- Maintain WCAG AA contrast ratios.

## Delivery Checklist

- [ ] List/table surfaces include an Empty State block
- [ ] Async states use structure-mirroring skeleton loaders
- [ ] Hidden menu actions include documented keyboard shortcuts
- [ ] Spacing follows a strict 8px grid for margin and padding
- [ ] Typography uses no more than 3 font sizes

## What to Avoid

Do not default to:
- Bold, high-intensity visual directions
- Saturated palettes or colorful gradients
- Pure black backgrounds such as `#000000`
- Decorative complexity that competes with content
- Heavy shadows, glassmorphism, or layered visual effects
- Experimental typography that reduces readability
- Layouts optimized for visual surprise instead of task clarity

## If Unsure

Choose the more restrained option. Use the soft dark palette, Inter typography, subtle block hover states, and operational clarity over creative flair.
