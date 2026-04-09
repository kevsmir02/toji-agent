---
name: frontend-design-rn
description: "Visual design and styling conventions specialized for React Native — StyleSheet.create discipline, design token consumption in JS, Platform-adaptive styling, typography scaling, dark mode, and Reanimated animation patterns."
globs: ["**/*.tsx","**/*.ts"]
---

# Frontend Design — React Native

Visual implementation discipline for React Native. Covers styling architecture, design token consumption, platform adaptation, typography, dark mode, and animation conventions.

## Design System Token Consumption

React Native does not have CSS variables. Tokens must be maintained as JavaScript constants.

### Token File Convention
```ts
// design-system/tokens.ts (or src/theme/tokens.ts)
export const colors = {
  primary: '#1A1A2E',
  surface: '#FFFFFF',
  error: '#D32F2F',
  textPrimary: '#111111',
  textSecondary: '#666666',
} as const;

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
} as const;

export const typography = {
  displayLarge: { fontSize: 32, lineHeight: 40, fontWeight: '700' as const },
  bodyMedium: { fontSize: 16, lineHeight: 24, fontWeight: '400' as const },
} as const;
```

### Rules
- **Never hardcode hex values or numeric spacing in component StyleSheets.** Import from the token file.
- If the project has a `design-system/MASTER.md`, derive token values from it — the JS token file is the runtime translation of that spec.
- Do not create per-component token overrides. All overrides live in the token file under a named key.

---

## StyleSheet Discipline

### Use `StyleSheet.create` Always
```ts
// ✅ Correct
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
});

// ❌ Wrong — inline style objects recreated on every render
<View style={{ flex: 1, backgroundColor: '#fff' }} />
```

### Avoid Dynamic Styles Inside `StyleSheet.create`
- `StyleSheet.create` freezes the object at startup — do not put computed values inside it.
- For dynamic values (theme-driven, user-preference-driven), use a style factory function or hook:

```ts
// ✅ Correct — factory pattern for dynamic styles
const useStyles = () => {
  const { colors } = useTheme();
  return StyleSheet.create({
    container: { backgroundColor: colors.surface },
  });
};
```

### Flexbox Defaults
- React Native defaults to `flexDirection: 'column'` and `alignItems: 'stretch'` — do not re-declare defaults as it adds noise.
- Use `flex: 1` to fill available space; never rely on pixel dimensions for layout containers.

---

## Platform-Adaptive Styling

### Platform.OS Branching
```ts
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  shadow: Platform.select({
    ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.1, shadowRadius: 4 },
    android: { elevation: 4 },
  }),
});
```

- Use `Platform.select` inside `StyleSheet.create` for `ios`/`android` style variants.
- Use `.ios.tsx` and `.android.tsx` file extensions only for components with substantial platform differences — not for minor style tweaks.
- Test on **both platforms** when using any `Platform.select` branch.

### Shadows
- iOS uses `shadowColor`, `shadowOffset`, `shadowOpacity`, `shadowRadius`.
- Android uses `elevation`.
- Neither works on the other platform — always provide both.

---

## Typography

### Font Scaling and Accessibility
- Never set `allowFontScaling={false}` on user-readable text. Respect the user's system font size.
- Only suppress font scaling on UI chrome elements (icons, badges) where layout would break — document why.
- Use `maxFontSizeMultiplier` for elements that cannot scale beyond a safe maximum without breaking layout.

### System Fonts vs Custom Fonts
- If the design system specifies a custom font, register it via `react-native.config.js` and `fonts/` directory — do not use `expo-font` in a bare workflow.
- Always include a fallback font stack: `fontFamily: Platform.select({ ios: 'Georgia', android: 'serif' })`.
- Custom fonts must be loaded in the app entry before the first render — use a splash screen or skeleton gate.

---

## Dark Mode

### Appearance Detection
```ts
import { useColorScheme } from 'react-native';

const colorScheme = useColorScheme(); // 'light' | 'dark' | null
```

- Always subscribe to `useColorScheme()` — never read `Appearance.getColorScheme()` and cache it, as it won't update on system theme change.
- Token switching pattern: maintain separate `lightTokens` and `darkTokens` objects; select via colorScheme in a theme provider.
- All new UI components must render correctly in both light and dark mode — include both in the review checklist.

### Dark Mode Token Rules
- Map semantic token names (`colors.surface`, `colors.textPrimary`) — not raw values — so the entire palette switches by swapping the token set.
- Test contrast ratios in dark mode: minimum 4.5:1 for normal text, 3:1 for large text and UI elements.

---

## Animation Conventions

### Use Reanimated for Performance-Critical Animations
- Prefer `react-native-reanimated` (v3+) for gestures, transitions, and layout animations that run on the UI thread.
- Use `Animated` API only for simple, infrequent animations where Reanimated would be over-engineering.
- Never animate `width`, `height`, or `top`/`left` with layout animations — use `transform: [{ translateX }]` which stays on the UI thread.

### `useAnimatedStyle` Pattern
```ts
import Animated, { useAnimatedStyle, useSharedValue, withSpring } from 'react-native-reanimated';

const offset = useSharedValue(0);
const animatedStyles = useAnimatedStyle(() => ({
  transform: [{ translateX: offset.value }],
}));
```

### Gesture Handler
- Use `react-native-gesture-handler` for all gesture-driven interactions — never `PanResponder`.
- Wrap the app root in `GestureHandlerRootView` — missing this causes silent gesture failures on Android.

### Motion Restraint
- Provide `prefers-reduced-motion` equivalents: use `ReduceMotionConfig` from Reanimated or check `AccessibilityInfo.isReduceMotionEnabled()` before starting complex animations.
- Animations should reinforce cause/effect — not decorate. A button press response animation is appropriate; an autonomous looping animation on a static card is not.

---

## Image and Asset Handling

- Use `require('../../assets/image.png')` for static assets — never string paths.
- Use `resizeMode="cover"` only when intentional cropping is acceptable; `resizeMode="contain"` for logos and icons.
- All user-generated remote images need a fallback (placeholder or initials avatar) for load failure.
- Prefer SVG via `react-native-svg` for icons — PNG assets at 3× resolution as a fallback.

---

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
