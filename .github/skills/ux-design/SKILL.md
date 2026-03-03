---
name: ux-design
description: Apply UX principles when designing or reviewing user flows, navigation, forms, states, and interactions. Use this skill when building or evaluating interfaces for usability, task completion, information architecture, error handling, or accessibility — not just visual appearance.
---

This skill applies established UX principles to produce interfaces that are easy to use, predictable, and cognitively lightweight — without sacrificing visual quality. It complements `frontend-design` (which governs aesthetics) by governing behavior, flow, and interaction patterns.

## Core Principle: Conventional Where It Matters, Distinctive Where It Doesn't

The highest-stakes UX decisions involve interaction patterns users already know (navigation, forms, error recovery, CTAs). Break these conventions only with strong justification. Visual distinctiveness (typography, color, motion, decoration) is low-cost to learn; novel interaction patterns are high-cost.

---

## Nielsen's 10 Usability Heuristics

Apply these as a checklist when designing or reviewing any interface:

1. **Visibility of System Status** — Always keep users informed about what is happening. Show loading states, progress indicators, success/error feedback. Never leave the user guessing whether an action registered.

2. **Match Between System and the Real World** — Use language and concepts familiar to the user, not internal system terminology. Order information naturally. Prefer human labels over technical ones.

3. **User Control and Freedom** — Provide clear escape routes. Support undo/redo where destructive actions exist. Never trap a user in a state with no way out.

4. **Consistency and Standards** — Follow platform conventions. Use the same words, icons, and patterns for the same actions throughout. Don't make the user re-learn the same concept twice.

5. **Error Prevention** — Design to prevent problems before they occur. Confirm before destructive actions. Constrain inputs to valid options where possible. Disable actions that aren't currently valid instead of letting them fail.

6. **Recognition Over Recall** — Make options, actions, and information visible. Minimize what the user must remember between steps. Use labels, icons with text, and persistent context cues.

7. **Flexibility and Efficiency of Use** — Support both novice and expert users. Provide shortcuts for frequent actions. Don't force power users through beginner flows.

8. **Aesthetic and Minimalist Design** — Show only what's relevant to the current task. Every extra element competes for attention. When in doubt, remove it.

9. **Help Users Recognize, Diagnose, and Recover from Errors** — Error messages must: (a) clearly state what went wrong in plain language, (b) explain why if non-obvious, (c) tell the user exactly what to do next. Never show raw error codes to end users.

10. **Help and Documentation** — Where complexity is unavoidable, provide contextual help. Inline hints, tooltips, and empty-state guidance beat separate documentation pages.

---

## Laws of UX (Applied)

### Cognitive Load
- **Hick's Law** — More choices = more decision time. Reduce navigation items, form fields, and option lists to only what's needed for the current task. Use progressive disclosure to reveal complexity gradually.
- **Miller's Law** — Working memory holds ~7±2 items. Chunk information into groups of 5–7. Break long forms into steps. Paginate long lists.
- **Cognitive Load** — Every unfamiliar pattern, unexplained label, or missing affordance costs the user mental effort. Minimize total cognitive load per task.

### Interaction Design
- **Fitts's Law** — Larger targets and shorter travel distance reduce interaction effort. Primary CTAs must be large and reachable. On mobile, touch targets minimum 44×44px. Destructive actions should be small and distant from primary actions.
- **Postel's Law** — Be liberal in what you accept (flexible input formats), strict in what you output (consistent, clean results). Auto-format phone numbers, trim whitespace, accept both date formats.
- **Jakob's Law** — Users spend most of their time on other products and expect your product to work the same way. Leverage established patterns (hamburger menus, breadcrumbs, inline validation) rather than reinventing them.

### Perception and Attention
- **Gestalt Principles** — Group related items visually (proximity), use consistent styling for similar items (similarity), guide the eye with alignment and flow (continuity). Grouping communicates structure without requiring labels.
- **Von Restorff Effect** — The item that stands out is most remembered. Use visual contrast deliberately — one primary CTA, not five equally weighted buttons.
- **Serial Position Effect** — Users remember the first and last items in a list better than middle items. Place critical navigation items and CTAs at the start or end of sequences.
- **Doherty Threshold** — System response under 400ms keeps users in flow. Over 1 second, show a loader. Over 10 seconds, show progress with estimated time. Never show a blank or frozen UI.

---

## UX Patterns by Context

### Navigation
- Provide persistent wayfinding — breadcrumbs, active state highlights, page titles
- Maximum 7 top-level navigation items (Hick's Law)
- Mobile: thumb-reachable primary navigation (bottom nav or accessible hamburger)
- Always indicate where the user is in the hierarchy

### Forms
- One column layouts outperform multi-column for completion rates
- Label above field, not placeholder-only (placeholders disappear on focus)
- Inline validation on blur, not on keystroke (reduces noise)
- Group related fields visually (Gestalt proximity)
- Required vs optional: mark the minority — if most fields are required, mark optional ones instead
- Show field-level errors next to the field, not only at the top of the form
- Preserve entered data on validation errors — never clear the form on submit failure
- Use `autocomplete` attributes on all personal data fields

### Empty, Loading, and Error States
Every data-driven UI must design all four states:
- **Empty state** — explain what will appear here and provide a clear action to get started
- **Loading state** — show skeleton screens for predictable layouts; spinner for indeterminate ops
- **Error state** — plain language, reason if non-obvious, recovery action (retry, go back, contact support)
- **Success state** — confirm action completed; indicate next step if one exists

### Destructive Actions
- Require confirmation (modal or inline confirmation step)
- Use red/warning color to signal risk — not for primary actions
- Place destructive buttons away from confirm/save buttons (Fitts's Law)
- Consider soft deletes with undo over hard deletes with confirm dialogs

---

## Accessibility as UX (WCAG AA Baseline)

Accessibility failures are UX failures. Enforce these minimums:
- **Color contrast**: 4.5:1 for body text, 3:1 for large text and UI components
- **Keyboard navigation**: all interactive elements reachable and operable by keyboard; visible focus indicator
- **Screen reader support**: semantic HTML, ARIA labels on icon-only controls, live regions for dynamic content
- **Touch targets**: minimum 44×44px on mobile
- **Motion**: all animations wrapped in `@media (prefers-reduced-motion: reduce)` fallbacks
- **Forms**: every input has a visible, associated `<label>`; error messages linked via `aria-describedby`

---

## UX Review Checklist

Before shipping any UI, verify:

- [ ] All four states handled: empty, loading, error, success
- [ ] Error messages are plain language with recovery actions
- [ ] No action leaves the user in an unrecoverable state
- [ ] Navigation clearly shows the user where they are
- [ ] Form labels are visible (not placeholder-only)
- [ ] Primary CTA is visually dominant; destructive actions are visually subdued
- [ ] Touch targets ≥44×44px on mobile
- [ ] Keyboard navigable, visible focus styles
- [ ] Contrast ratios meet WCAG AA
- [ ] `prefers-reduced-motion` respected
- [ ] No raw error codes or stack traces exposed to users
- [ ] Progressive disclosure used for complex or advanced options
