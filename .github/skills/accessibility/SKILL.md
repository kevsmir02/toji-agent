---
name: accessibility
description: "Passive core skill — WCAG 2.1 AA compliance checklist. Auto-triggers via 1% Rule on any UI file change. Enforces semantic HTML, contrast ratios, keyboard operability, focus management, and ARIA discipline. Models the same silent evaluation pattern as the security skill."
globs: ["**/*.tsx","**/*.jsx","**/*.vue","**/*.svelte","**/*.html","**/*.blade.php","**/*.erb","**/*.jinja","**/*.njk"]
---

# Accessibility Skill

This is a **passive core skill**. It activates automatically via the 1% Rule whenever the agent modifies any user-interface file. Accessibility is not optional UX polish — it is a minimum standard for every user-facing feature.

## Trigger Conditions (1% Rule)

This skill fires when the task involves **any** of:
- New or modified HTML elements, JSX/TSX components, or template files
- Interactive elements: buttons, links, forms, modals, dropdowns, menus
- Color changes, theme changes, or design token modifications
- Dynamic content updates (AJAX, state transitions, real-time data)
- Navigation additions or route changes
- Image, icon, or media content additions

## WCAG 2.1 AA Compliance Matrix

For every UI change that triggers this skill, silently evaluate each applicable item. Report only FAIL items.

### 1. Perceivable

**Text Alternatives (1.1)**
- [ ] Every `<img>` has a meaningful `alt` attribute. Decorative images use `alt=""` (empty string, not missing).
- [ ] Icon-only buttons have `aria-label` or a visually hidden `<span>` describing the action.
- [ ] SVG icons used interactively have a `<title>` or `aria-label`; purely decorative SVGs have `aria-hidden="true"`.

**Contrast (1.4.3 / 1.4.6)**
- [ ] Normal text (< 18pt or < 14pt bold) achieves **4.5:1** contrast ratio against its background.
- [ ] Large text (≥ 18pt or ≥ 14pt bold) achieves **3:1** contrast ratio.
- [ ] UI components (input borders, focus rings, button outlines) achieve **3:1** against adjacent colors.
- [ ] Never use color as the **only** means of conveying information (chart lines, form error state, status badges).

**Resize (1.4.4)**
- [ ] Content reflows and remains usable when browser text size is set to 200% — no horizontal scrollbar required for single-column content.
- [ ] Do not use `px` for font sizes on primary text — use `rem` or `em` so the OS/browser font preference is respected.

---

### 2. Operable

**Keyboard (2.1)**
- [ ] Every interactive element is reachable and operable with keyboard alone (Tab, Shift+Tab, Enter, Space, arrow keys).
- [ ] No keyboard trap: the user can always Tab out of a component without using the mouse.
- [ ] Custom widgets (date pickers, comboboxes, drag-and-drop) implement the appropriate [ARIA keyboard patterns](https://www.w3.org/WAI/ARIA/apg/patterns/).

**Focus Visibility (2.4.7 / 2.4.11)**
- [ ] All interactive elements have a **visible focus indicator** using `:focus-visible`. Never `outline: none` without a replacement focus style.
- [ ] Focus rings must meet the 3:1 contrast requirement against adjacent colors.

**Skip Navigation (2.4.1)**
- [ ] Multi-page apps have a "Skip to main content" link as the first focusable element on the page.

**Focus Management**
- [ ] When a modal opens, focus moves to the modal (first focusable element or the modal heading).
- [ ] When a modal closes, focus returns to the element that triggered it.
- [ ] Focus is never placed on a non-interactive element (use `tabindex="-1"` on the container for programmatic focus, not a `<div>` without a role).

**Sufficient Time (2.2)**
- [ ] Auto-updating content (countdowns, live feeds) can be paused or the update interval can be extended.
- [ ] Session timeout warnings give the user at least 20 seconds to respond before the session expires.

---

### 3. Understandable

**Labels (3.3.2)**
- [ ] Every form input has a visible `<label>` associated via `for`/`id` or `aria-label` / `aria-labelledby`.
- [ ] Placeholder text is not used as a substitute for a visible label — it disappears on input.

**Error Identification (3.3.1 / 3.3.3)**
- [ ] Error messages identify the field in error and describe how to correct it.
- [ ] Error state is communicated to screen readers via `aria-invalid="true"` on the input and `aria-describedby` pointing to the error message element.
- [ ] Error messages persist until the user corrects the input — they are not dismissed automatically after a timeout.

**Consistent Navigation (3.2.3)**
- [ ] Navigation elements appear in the same place and order across pages.
- [ ] Component behavior is consistent: a button that opens a menu in one part of the app does not open a modal in another.

---

### 4. Robust

**Valid HTML / Correct ARIA (4.1)**
- [ ] Use native HTML elements for their intended purpose before reaching for ARIA: `<button>` not `<div role="button">`, `<nav>` not `<div role="navigation">`.
- [ ] ARIA roles, states, and properties are used according to the ARIA spec — never invent role names.
- [ ] `aria-hidden="true"` is not applied to elements that contain focusable children.
- [ ] Dynamic content changes are announced via `aria-live` regions: `polite` for non-critical updates, `assertive` only for critical alerts.

**Heading Hierarchy**
- [ ] Pages have exactly one `<h1>`.
- [ ] Heading levels do not skip (no jumping from `<h2>` to `<h4>`).
- [ ] Screen-only headings that structure regions for AT users are acceptable with `sr-only` / `visually-hidden` CSS utility classes.

---

## Silent Evaluation Protocol

When this skill triggers, the agent must:

1. **Scan** the changed UI elements against all applicable matrix items above.
2. **Mark** each item PASS or FAIL internally (no output for PASS items).
3. **Report** only FAIL items with:
   - The specific matrix category (e.g., "§2 — No focus indicator on custom dropdown")
   - The file and element location
   - A concrete fix (e.g., "Add `:focus-visible { outline: 2px solid #005FCC; }` to the `.dropdown-trigger` class")
4. **Block** the UI change from being finalized until all FAIL items are resolved.

If all checks PASS, proceed silently.

---

## Automated Testing Integration

Automated a11y scanning supplements but does not replace manual evaluation:

- Use `axe-core` via `@testing-library/jest-dom` matchers or `jest-axe` in component tests:
  ```ts
  import { axe, toHaveNoViolations } from 'jest-axe';
  expect.extend(toHaveNoViolations);
  const { container } = render(<MyComponent />);
  expect(await axe(container)).toHaveNoViolations();
  ```
- Run `axe` on every new page-level component in its primary rendering state.
- Automated tools catch ~30–40% of WCAG issues — do not rely on them alone for keyboard, focus, and AT announcements.

---

## Cost Control

- All matrix checks are static analysis against the changed files.
- No sub-agents, no external API calls.
- Evaluate only changed files in the current task.

---

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
