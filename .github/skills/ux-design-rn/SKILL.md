---
name: ux-design-rn
description: UX flow and interaction rules for React Native apps — navigation patterns, gesture conventions, feedback, mobile-first flows, thumb zones, offline states. Apply when the Active Stack Profile shows Stack ID: react-native-bare (or any react-native-* stack). Overrides ux-design for React Native files.
globs: ["**/*.tsx","**/screens/**","**/navigation/**"]
---

# React Native UX Flow Standards

Apply these rules as authoritative when this skill is active.

## Navigation UX

- Primary navigation actions (tabs, home) belong in bottom tab bars for thumb reach.
- Secondary/contextual actions belong in top headers or action sheets.
- Do not place primary/secondary controls as floating actions in the screen middle.
- Prefer native-stack transitions for deep navigation flows to keep animations on the main UI thread.
- Destructive actions (delete, logout, reboot) must require confirmation via Alert
  dialog or explicit confirmation bottom sheet.
- Back navigation must always work.
- Test Android hardware back behavior on every screen.
- Deep screens (3+ levels) should provide jump-to-root affordance (breadcrumb,
  home-tab reset, or header shortcut).
- Use `navigation.replace()` after auth success to prevent returning to login screen.
- Keep route params strongly typed and navigator-safe; avoid ad hoc screen-name strings in UX flow logic.

## Gestures

- Modal screens should support swipe-to-dismiss by default.
- If disabled (`gestureEnabled: false`), add a code comment explaining why.
- Provide pull-to-refresh on screens with lists or live data.
- Support long press for contextual list actions (rename, delete, copy).
- Do not force users into detail pages for common item actions.
- Swipe gestures must include visual affordance for discoverability.

## Feedback and Response

- Every tap must produce immediate visual feedback.
- Use `activeOpacity` on `TouchableOpacity` or pressed-state styling with `Pressable`.
- Any operation taking more than 300ms must show loading feedback.
- Disable trigger controls while requests are in flight to prevent double submits.
- Success states must be visible (toast, brief animation, or state change).
- Never silently complete significant actions.
- Errors must be visible and actionable.
- Use inline errors for forms, toast/snackbar for API issues, full-screen error only
  for fatal states.

## Forms and Input

- Auto-focus first input field on form screens where appropriate.
- Use correct `keyboardType` per input (`email-address`, `numeric`, `phone-pad`, `url`).
- Use `returnKeyType` intentionally (`next`, `done`, `go`) based on field position.
- Always handle `onSubmitEditing` on last field to trigger submit flow.
- Provide show/hide password toggles for password fields.
- Disable submit while request is in flight.
- Never allow double-submission.

## Connectivity and Offline

- Every network call must handle `Network request failed` gracefully.
- Show connection status when core functionality depends on network.
- Cache/persist last known good state when meaningful.
- Avoid blank screens offline when stale data exists.
- Implement one automatic retry with exponential backoff for transient failures,
  then surface actionable error.

## Thumb Zone Design

- Place primary actions/navigation in bottom 40% of the screen.
- Rare or destructive actions may live in top zones to require deliberate reach.
- Floating Action Buttons should be bottom-right.
- Never place FABs top or center.
- Prefer bottom sheets over top modals for selection/input workflows.

## Platform Conventions

- Android: follow Material bottom navigation, back-stack behavior, and snackbar
  patterns for transient feedback.
- iOS: follow nav-bar button conventions, swipe-back expectations, and toast/alert
  conventions.
- Do not fight platform conventions without explicit reason.
- If Android users expect back button behavior, provide it.
- If iOS users expect swipe-back, do not disable it casually.
- If disabling gestures/back behavior, leave an inline reason in code because this is a high-friction UX change.
- Match `StatusBar` `barStyle` to screen background contrast.

## Performance Perception

- Use optimistic UI updates where rollback is safe.
- Example: remove list item immediately on delete, restore on failure.
- Prefer skeleton screens over spinners for initial content load.
- Reserve layout space to avoid visible shift after data arrives.
- Animations must run at 60fps.
- Use `useNativeDriver: true` for Animated values limited to transform/opacity.

## Code Review Checklist

- Do destructive actions require confirmation?
- Does Android hardware back work correctly on every screen?
- Does every tappable element provide immediate feedback?
- Do forms use correct `keyboardType`, `returnKeyType`, and `onSubmitEditing`?
- Are network errors visible with retry options?
- Are animations using `useNativeDriver: true` where applicable?
- Are primary actions in thumb-reachable zones?

## If Unsure

Prefer bottom-of-screen placement for primary actions, confirmation dialogs for
destructive operations, explicit feedback for every user action, and graceful
 degradation over blank screens during network failure.
