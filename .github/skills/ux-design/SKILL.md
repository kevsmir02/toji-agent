---
name: ux-design
description: Apply a Notion-inspired UX framework when designing or reviewing user flows, navigation, forms, states, and interactions. Use this skill when building or evaluating interfaces for usability, task completion, information architecture, error handling, or accessibility.
---

This skill applies a Notion-inspired UX framework: block-based architecture, progressive disclosure, and functional minimalism. It complements `frontend-design` by governing information flow, interaction density, and behavioral clarity.

## Core Principle: Calm Structure Over Visual Novelty

The default experience should feel organized, quiet, and dependable. Users should feel that content is made of understandable blocks, actions are discoverable when needed, and interface chrome stays out of the way until context calls for it.

The interface should feel like a blank page that becomes powerful through interaction. Structure comes from modular blocks, whitespace, and subtle dividers rather than obvious framing.

## Notion-Inspired UX Framework

### 1. Block-Based Architecture
- Treat every meaningful UI element as a self-contained, draggable-style block.
- Design information and actions as composable blocks with clear boundaries.
- Each block should represent one job: a paragraph, form section, database row group, task list, properties panel, comment thread, or action region.
- Blocks should be individually scannable, movable in concept, and understandable without relying on surrounding decoration.
- Each block should support an active, hover, and editable state without changing the overall page scaffold.
- The block is the primary unit of composition, focus, insertion, reordering, and command targeting.
- Use spacing, alignment, and subtle dividers to define structure instead of heavy visual containers.
- Prefer modular page composition over monolithic screens with mixed concerns.

### 2. Progressive Disclosure
- Reveal complexity only when the user needs it.
- Keep the default surface focused on the primary task; advanced controls belong behind secondary actions, toggles, menus, expandable sections, or slash-command-style triggers.
- Borrow from slash-command interaction patterns: make powerful actions searchable, contextual, and fast for experienced users without overwhelming first-time users.
- Hide advanced block actions such as delete, move, duplicate, settings, and transform until a block is hovered, focused, or active.
- Use hover states, inline toolbars, kebab menus, block handles, and command menus to preserve a calm canvas while keeping power accessible.
- Default to showing the next useful action, not the entire system.

### 3. Functional Minimalism
- Every visible element must earn its place through task support, orientation, or feedback.
- Favor whitespace, typographic hierarchy, and subtle borders over color, gradients, or dramatic effects.
- Minimize persistent chrome. Sidebars, headers, breadcrumbs, and toolbars should support orientation, not dominate the layout.
- Prefer plain language and concise labels over decorative copy.
- Make dense workflows feel manageable through rhythm and grouping, not through aggressive visual contrast.
- Default to a blank-page feel for the main workspace: no bordered main container, no boxed canvas, and no unnecessary framing around content.
- Create hierarchy through whitespace, indentation, block spacing, and subtle dividers rather than obvious cards or panels in the main reading/editing surface.

## Interface Patterns

### Navigation and Layout
- Use stable page scaffolding: sidebar, top bar, content column, and optional contextual panel.
- Keep navigation lightweight and predictable. Users should always know where they are and what surface they are editing.
- Use nested structure carefully: indentation, breadcrumbs, and hierarchy labels should clarify parent-child relationships without adding clutter.
- Let the main content column breathe. Avoid dashboard-style fragmentation unless the task genuinely requires multiple simultaneous data views.
- The main content area should feel open and borderless, with blocks floating in a clear vertical rhythm.

### Editing and Commands
- Design around direct manipulation of content blocks where possible.
- Inline editing should feel natural: click into content, edit in place, and avoid unnecessary modal interruptions.
- Use command menus and contextual insertion patterns for advanced creation flows.
- Secondary actions should appear near the object they affect.
- Make undo, cancel, and recovery obvious.
- Block handles, drag affordances, and action menus should appear only on hover or active focus, not as persistent clutter.

### Forms and Data Entry
- Break long forms into logical block sections with clear headings.
- Default to one-column form layouts.
- Show only the fields needed for the current decision; advanced options should be collapsed by default.
- Treat labels, helper text, validation, and inline confirmations as part of the same block.
- Preserve entered data on failure and return users to the affected block with clear guidance.

### States and Feedback
- Empty states should teach the block model: explain what belongs here and offer a direct next action.
- Loading states should preserve structure with calm skeletons or reserved space instead of jarring spinners everywhere.
- Success states should be lightweight and local when possible.
- Error states should appear close to the affected block, in plain language, with an obvious recovery action.
- Autosave, sync, and background updates should be communicated quietly rather than interruptively.

## Strict Technical Requirements (Hard Gates)

The following rules are mandatory for every UX proposal and review outcome:

- Every list or table feature must include a dedicated Empty State block design with purpose text and a primary next action.
- Every async action must use a Skeleton Loader that mirrors the final block structure and layout rhythm.
- Every hidden menu action must have a corresponding documented keyboard shortcut.
- All spacing must follow a strict 8px grid system for margins and padding (8, 16, 24, 32, ...).
- Typography is limited to a maximum of 3 font sizes across the feature.

## Accessibility Requirements

Accessibility is part of the product feel. A calm interface that fails keyboard or screen-reader users is not calm.

- Maintain WCAG AA contrast ratios.
- Ensure every interactive control is keyboard reachable with a visible focus state.
- Use semantic structure and consistent heading hierarchy so block relationships are understandable outside visual layout.
- Every form input needs a visible label and linked error/help text via `aria-describedby` when relevant.
- Use touch targets of at least 44×44px on mobile.
- Respect `prefers-reduced-motion` for all transitions and animations.

### Live Updates and Async States
- Add a persistent `aria-live="polite"` region for non-blocking updates such as autosave confirmation, sync completion, inserted blocks, and successful inline actions.
- Use `aria-live="assertive"` only for urgent failures or destructive-action problems that require immediate attention.
- Mark actively refreshing areas with `aria-busy="true"` during async loads, saves, filtering, or block reordering, then clear it immediately when complete.
- After command-menu actions or dynamic insertions, move focus to the created or updated block when that best preserves continuity.
- After validation failures, move focus to the first invalid field or block-level error summary.
- Do not rely on color alone to communicate saved, syncing, warning, or error states.

## UX Review Checklist

- [ ] Every meaningful element behaves like a self-contained block
- [ ] The main workspace feels open and borderless rather than boxed in
- [ ] The page is organized into clear, comprehensible blocks
- [ ] Primary tasks are visible without exposing every advanced control
- [ ] Advanced block actions stay hidden until hover or active state
- [ ] Secondary actions are progressively disclosed through contextual UI
- [ ] Visual treatment is quiet and task-oriented rather than decorative
- [ ] Navigation clarifies hierarchy without adding noise
- [ ] Forms are grouped into logical block sections
- [ ] Empty, loading, success, and error states are handled at the appropriate block level
- [ ] Every list/table includes a dedicated Empty State block design
- [ ] Every async interaction uses structure-mirroring skeleton loaders
- [ ] Hidden menu actions have documented keyboard shortcuts
- [ ] All margins and padding follow a strict 8px grid
- [ ] No more than 3 font sizes are used across the feature
- [ ] Keyboard navigation works across all interactive surfaces
- [ ] Live updates use the correct `aria-live` behavior
- [ ] Async regions use `aria-busy` during updates
- [ ] Validation errors move focus and explain recovery clearly
- [ ] The interface feels calm, structured, and operationally clear
