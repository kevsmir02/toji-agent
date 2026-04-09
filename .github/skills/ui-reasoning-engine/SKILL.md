---
name: ui-reasoning-engine
description: Intelligent Design System Generation. Use this skill BEFORE writing any frontend UI code (React, Vue, HTML, Blade, etc.). It guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics.
globs: ["**/*.tsx","**/*.jsx","**/*.css","**/*.scss","**/*.html","**/*.blade.php","**/*.vue"]
---

This skill governs the creation of dynamic, context-aware design systems using the Advanced Frontend Aesthetics Engine. It ensures all UI code is highly distinctive, avoiding generic AI-generated aesthetics while adapting to the intent of the interface being built.

## Design Thinking & Establishing the System (Non-Optional)

Before you write or modify UI code for a new feature, page, or application, you **MUST** formulate its design constraints using the following framework. Do not invent unauthorized colors or fallback to generic defaults.

### Step 0: Context-Adaptive Mode Detection (Run First)

Before any other step, classify the interface being built. This determines which design philosophy governs the session.

**Application UI Mode** (default for most work):
Trigger when the interface is a: dashboard, admin panel, CRUD form, settings page, data table, user profile, authentication flow, or any feature that prioritizes **task completion over aesthetic expression**.

In Application UI Mode:
- Consistency, usability, and accessibility come first — aesthetic boldness is secondary.
- System fonts (Inter, system-ui) are acceptable if the design system uses them.
- Use conservative, purposeful animation — no staggered reveals or parallax effects that delay task completion.
- Adhere to established UI patterns (sidebar nav, top nav, card grids, data tables) unless a design system explicitly deviates.
- Skip Steps 2–3 if a `design-system/MASTER.md` already exists — inherit its tokens directly.
- **Do not** apply "Commit to a BOLD Aesthetic Direction" to utility interfaces. Apply consistent, legible, accessible defaults instead.
- Apply accessibility rules from the `accessibility` skill silently before finalizing any component.

**Marketing / Creative Mode**:
Trigger when the interface is a: landing page, marketing site, portfolio, showcase, splash screen, or any surface where **brand expression and visual impact are the primary goals**.

In Marketing / Creative Mode:
- The full bold aesthetic engine (Steps 2–4 below) applies without restriction.
- Differentiation, memorability, and standout visual identity are the success criteria.
- System fonts, predictable layouts, and timid color choices are anti-patterns.

**When unsure**: If the route/component name suggests task completion (Dashboard, Settings, Orders, Profile, Admin), default to **Application UI Mode**. If it suggests brand or discovery (Home, Landing, About, Portfolio, Showcase), default to **Marketing / Creative Mode**.

---

### Step 1: Hierarchical Retrieval
When starting a UI task, check the local design system files:
1. Always check if a page override exists: `design-system/pages/<page-name>.md`.
2. If it exists, its rules **override** the Master file.
3. If it does not exist, check and strictly follow `design-system/MASTER.md`.
4. If neither exist, you must creatively define the aesthetic direction dynamically and explicitly persist it.

### Step 2: Commit to a BOLD Aesthetic Direction
Before generating any UI code, analyze the context and explicitly commit to an extreme visual direction.
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme (e.g., brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric).
- **Differentiation**: What makes this unforgettable? What's the standout feature?

### Step 3: Establish the Frontend Aesthetics
You must meticulously define the following parameters in your generated design system:

#### 1. Typography
Choose fonts that are beautiful, unique, and interesting.
- **Rules**: Avoid generic fonts (Arial, Inter, Roboto, system fonts). Opt for distinctive choices that elevate the frontend aesthetics. 
- **Pairings**: Pair a distinctive display font with a refined body font. Do not fallback to cliches like Space Grotesk everywhere.

#### 3. Color & Theme
Commit to a cohesive, bold palette. 
- **Rules**: Dominant colors with sharp accents heavily outperform timid, evenly-distributed palettes. 
- **Implementation**: Leverage CSS variables for absolute consistency. Do not use generic Tailwind utility colors continuously unless they correspond to your carefully selected unique hex tokens. Use varying color schemes rather than predictable "purple gradient on white" slop.

#### 4. Motion & Interaction
Use animations for impactful effects and micro-interactions.
- **Rules**: Focus on high-impact moments. A well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions. 
- **Implementation**: Prioritize CSS-only solutions for HTML, or use robust libraries (like Framer Motion) for React. Use scroll-triggering and unexpected hover states.

#### 5. Spatial Composition
Venture beyond predictable box models.
- **Rules**: Use unexpected layouts. Introduce asymmetry, overlapping elements, diagonal flow, and grid-breaking components.
- **Spacing**: Use generous negative space OR highly controlled density depending on your bold aesthetic direction.

#### 6. Backgrounds & Visual Details
Create atmosphere and depth.
- **Rules**: Avoid defaulting to flat, solid colors for backgrounds.
- **Details**: Add contextual effects and textures — gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, custom cursors, decorative borders, and grain overlays.

### Step 4: Architecture Lock & Persistence
After establishing the aesthetic direction, you must **persist your reasoning to disk** so that future LLM context retains your design decisions seamlessly:
1. **Global Styles**: If this is a new app or global pattern, save your rules to `design-system/MASTER.md`.
2. **Page Specific**: If you are overriding existing rules for a particular page, save those rules to `design-system/pages/<page-name>.md`.

Your persisted file and summary output to the user MUST include:
- **Selected Style & Tone:** (e.g., "Editorial Luxury | High Contrast + Grain")
- **Core Colors:** (Hex codes for Dominant, Secondary, Accents, and their CSS Variable names)
- **Typography Output:** (Primary Display Font, Refined Body Font)
- **Signature Visual Details:** (e.g., "Geometric Overlaps with Noise Overlays", Spacing paradigms)

*Ask the user to confirm the design system visually. Do not proceed until confirmed.*

## Implementation Standards
IMPORTANT: Match implementation complexity to the aesthetic vision.
- **Maximalism**: Elaborate code with extensive animations and layered effects.
- **Minimalism/Refinement**: Restraint, surgical precision, and exact attention to spacing and typography. 

Elegance comes from executing the specific vision remarkably well. NEVER produce predictable, cookie-cutter "AI slop." Every execution must be fiercely unique.

## Engineering & Execution Guidelines (Vercel Standards)
While your aesthetic vision defines *how the UI looks*, these Vercel-derived standards strictly govern *how you build it*. You must perfectly execute these mechanical rules regardless of the aesthetic direction:

### 1. Interactions & Accessibility
- **Keyboard First**: Ensure 100% keyboard operability. Apply visible focus rings using `:focus-visible` (not `:focus`) to avoid distracting pointer users.
- **Hit Targets**: All interactive elements must have a generous hit target (minimum 24px visually, 44px on mobile hit targets). Expand `<input>` font sizes to `16px` on mobile to prevent iOS Safari auto-zoom.
- **Forgiving UX**: Never leave "dead zones" on controls. Label everything accurately (`aria-label` for icon-only buttons), and use native elements (`<button>`, `<a>`) before falling back to `aria-*` tags.

### 2. Form & Input Mechanics
- **Frictionless Input**: Never block typing or pasting in `<input>` or `<textarea>`. Do not disable pastes. If a field only accepts numbers, allow the typing but show validation feedack instead of swallowing keystrokes.
- **Submit Behavior**: Keep submit buttons enabled to allow incomplete form submissions to surface native validation feedback.
- **Labels**: Ensure clicking a `<label>` correctly focuses its associated control.

### 3. Bulletproof Animations & Layout
- **Compositor Friendly**: Explicitly list properties you intend to animate (avoid `transition: all`). Only animate GPU-accelerated properties (`transform`, `opacity`) and avoid properties that trigger layout thrash (`width`, `height`, `left`).
- **Motion Restraint**: Provide `prefers-reduced-motion` fallbacks. Only animate when it clarifies cause & effect or adds deliberate delight.
- **Optical & Intrinsic Sizing**: Rely on Flexbox/Grid intrinsic sizing over calculating measurements in JS. Adjust layouts by `±1px` optically when perception beats raw geometry.

### 4. Content & Resilience
- **Skeletons**: Loading skeletons must perfectly mirror final content to prevent layout shifts.
- **Active Voice & Typography**: Use active, action-oriented language. Apply tabular numbers (`font-variant-numeric: tabular-nums`) for comparisons and correctly place non-breaking spaces before units (e.g., `10&nbsp;MB`).
- **Error Exits**: Error messages must guide the exit—tell the user exactly how to fix the error, not just that an error occurred.
