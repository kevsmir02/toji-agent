---
name: ux-design-rn
description: "UX framework specialized for React Native mobile flows and interaction patterns — navigation, gestures, offline states, permissions, platform-adaptive behavior. Activate for any Screen or Navigator file, or when designing mobile user flows."
globs: ["**/*Screen.tsx","**/*Navigator.tsx","**/*.tsx","**/*.ts"]
---

# UX Design — React Native

Mobile UX has distinct constraints from web UX. Apply these rules before and during implementation of any React Native screen or navigation flow.

## When to Activate

- Before implementing a new screen or navigation flow
- When designing touch interactions, gestures, or pull-to-refresh
- When the feature involves offline capability or network-dependent states
- When implementing OS permission requests
- When designing platform-specific interactions (Android back button, iOS swipe-to-go-back)

---

## Navigation Patterns

### Stack Navigation
- Use Stack Navigator for flows with a clear hierarchy and back-button intent.
- Always define a meaningful `title` for the header or explicitly hide it — never ship a screen with a raw route name as its header title.
- If a screen requires a custom header, define it as a `headerRight`/`headerLeft` component — do not build a fake header inside the screen body.
- Back button on Android must do the same as the iOS swipe-to-go-back: go to the previous logical screen. Never override back behavior to navigate to an unrelated screen unless the user's current session state requires it (e.g., after auth).

### Tab Navigation
- Use Tab Navigator for top-level destination switching (max 5 tabs).
- Tab badges are reserved for time-sensitive counts (unread, pending action) — do not use decorative badges.
- Preserving tab state (no re-mount on tab switch) requires `detachInactiveScreens` or `lazy` prop configuration — enable this by default for tabs with expensive renders.

### Modal Flows
- Use Modal presentation (not push) for flows that are: (1) short (1–3 steps), (2) self-contained, and (3) do not need tab navigation inside them.
- Modals must have an explicit close/dismiss affordance — hardware back and swipe-down dismissal must both work unless the modal is a blocking gate (e.g., force upgrade screen).
- Full-screen modals that collect data must warn before dismissing with unsaved input.

### Deep Linking
- Critical user-journey screens must be addressable via deep link from day one — retrofitting deep links is expensive.
- Test deep links on both iOS (Universal Links) and Android (App Links) before shipping.

---

## Touch and Gesture UX

### Hit Targets
- Minimum touch target: **44×44 pt** on every interactive element.
- For icon-only buttons, pad the hitSlop or wrap in a container that satisfies the 44pt minimum.
- Never place two interactive targets within 8pt of each other — adjacent small targets cause mis-taps.

### Swipe Actions
- Swipe-to-delete or swipe-to-action must show a visible affordance on first use (hint animation or onboarding overlay).
- Destructive swipe actions (delete) require a confirmation step or an undo mechanism within 5 seconds.
- iOS and Android have different swipe conventions — use `react-native-gesture-handler` and follow platform norms.

### Pull-to-Refresh
- Only use pull-to-refresh on list screens where fresh data is expected by the user.
- Pair with a loading indicator that respects the native platform pull animation.
- After refresh, scroll position should be preserved (do not jump to top unless new items were added).

### Haptic Feedback
- Use light haptic (`HapticFeedbackTypes.impactLight`) for confirmations (send message, complete action).
- Use error haptic (`notificationError`) for form failures, not for every validation check.
- Never use haptics on passive events (receiving a notification, data loading in background).

---

## Offline and Network States

### Loading States
- Show skeleton screens, not activity spinners, for initial data loads on screens the user will wait on.
- Activity spinners are appropriate for triggered actions (button taps, pull-to-refresh).

### Offline Handling
- Every screen that requires network access must have a designed offline state:
  - Show cached data from stale cache with a timestamp ("Last updated 5 min ago")
  - OR show a clear offline banner with a retry action
  - Never show a blank screen with no explanation
- Queued actions (forms submitted offline) need a visible queue indicator and a sync-on-reconnect mechanism.

### Background Sync
- Notify the user when background sync completes or fails — do not silently succeed or fail.
- Sync status should be visible in the UI (e.g., a header indicator or tab badge) until resolved.

---

## Permission Requests

### Pre-Permission Explanation
- Always show a plain-language rationale screen **before** triggering the OS permission prompt.
- The rationale must explain *why* the app needs the permission with a specific benefit to the user ("To show nearby locations, we need your location") — not a legal statement.
- A "Not now" option must be available — do not force permission grant to continue using the app.

### Denied Permission Recovery
- If the user denies a permission, gracefully degrade: use a fallback flow or manual entry instead of crashing or showing a dead screen.
- Link directly to Settings to re-enable via `Linking.openSettings()` when the permission is denied and the feature is blocked.

---

## Platform-Adaptive Behavior

### iOS
- Support swipe-to-go-back on Stack Navigator screens — never suppress `gestureEnabled` unless the screen has unsaved state (and even then, intercept the gesture with a confirmation dialog).
- Respect the iOS safe area for notches, Dynamic Island, and home indicator. Use `useSafeAreaInsets()` — never hardcode pixel offsets.
- Use Haptic Engine patterns that match iOS Human Interface Guidelines.

### Android
- The hardware back button must always do the same logical thing as the in-app back affordance.
- On Android 13+, implement predictive back gesture support where the navigation library supports it.
- Material You dynamic color is optional but should not override the design system token palette.

### Safe Area
- All scrollable screens must wrap content in a `SafeAreaView` or apply `edges` to the enclosing screen container.
- Bottom tab bars and persistent footers must account for the home indicator height.

---

## Onboarding and First-Run UX

- First-run flows must be skippable unless they collect mandatory data (e.g., account setup).
- Progress indicators are required for onboarding flows with 3+ steps.
- Onboarding completion state must be persisted so the user only sees it once (use secure/persistent storage, not in-memory state).

---

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
