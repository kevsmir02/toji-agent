---
name: frontend-design-rn
description: Authoritative UI and styling rules for React Native apps — StyleSheet conventions, density-independent spacing, touch targets, platform-aware design, safe areas, typography scale. Apply when the Active Stack Profile shows Stack ID: react-native-bare (or any react-native-* stack). Overrides frontend-design for React Native files.
globs: ["**/*.tsx","**/*.jsx","**/screens/**","**/components/**"]
---

# React Native UI and Styling Standards

Apply these rules as authoritative when this skill is active.

## Core Principle

There is no CSS in React Native. All styling is via `StyleSheet.create()` or inline style objects.
Web CSS properties, Tailwind classes, and CSS variables do not apply.
The Delete Rule equivalent here is: no magic numbers in StyleSheet. All spacing, colors,
and typography must reference the project's design token constants.

## Design Token Ledger (mobile)

Define `src/theme/tokens.ts` (or equivalent) as the single source of truth containing:

- Color palette: named semantic colors (`primary`, `surface`, `onSurface`, `error`,
  `success`, `border`, `textPrimary`, `textSecondary`, `textDisabled`, `background`)
- Spacing scale: base-8 dp units (`spacing.xs: 4`, `spacing.sm: 8`, `spacing.md: 16`,
  `spacing.lg: 24`, `spacing.xl: 32`, `spacing.xxl: 48`)
- Typography scale: `fontSize` and `lineHeight` pairs for each text role (`heading1`,
  `heading2`, `body`, `caption`, `label`, `button`)
- Border radius: named values (`radius.sm: 4`, `radius.md: 8`, `radius.lg: 16`,
  `radius.full: 9999`)
- Elevation/shadow: named presets for Android `elevation` and iOS shadow props

No raw hex values, no raw numbers for spacing, and no raw font sizes outside this file.
The same Delete Rule applies: if a StyleSheet uses `color: '#3B82F6'` or `padding: 13`,
that is a violation.

## StyleSheet Conventions

- Always use `StyleSheet.create()`.
- Never inline style objects except for truly dynamic values (for example animated
  transforms, computed widths).
- Inline styles for dynamic values only: `style={[styles.base, { width: computedWidth }]}`.
- Never put StyleSheet definitions inside the component function.
- Keep styles at file bottom or in a separate `styles.ts` file.
- Name styles semantically (`container`, `header`, `title`, `row`), not structurally
  (`div1`, `wrapper2`).
- For theming, pass tokens via ThemeContext or props.
- Never import theme directly inside presentational components.

## Touch Targets

- Minimum `44x44` dp for any tappable element.
- This is non-negotiable for accessibility.
- Use `hitSlop` to extend small icon touch area without changing visual size:
  `hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}`.
- Never place two tappable elements with less than `8dp` between them.
- Use `TouchableOpacity` with `activeOpacity={0.7}` as default pressable, or `Pressable`
  with style function for advanced control.
- Never use `TouchableHighlight` unless a highlight color is explicitly required.

## Density-Independent Units

- All dimensions are in dp (Android) / pt (iOS); React Native style numbers already map
  to dp/pt.
- Never use `px` units or assume pixel-perfect consistency across devices.
- For responsive elements, use `Dimensions.get('window')` or `useWindowDimensions`.
- Never hardcode screen-specific values.
- Test on at least one small screen (`360dp` wide) and one large screen (`414dp+` wide).

## Safe Areas

- Always wrap root screen content with `SafeAreaView` from
  `react-native-safe-area-context`.
- Do not use the built-in SafeAreaView for primary layout boundaries.
- Apply `edges` selectively: `edges={['top']}` for custom bottom tab screens,
  `edges={['top', 'bottom']}` for full-screen views.
- Never hardcode status bar height; use safe area insets.

## Platform-Aware Styling

- Use `Platform.OS === 'android'` / `Platform.OS === 'ios'` only for real platform
  differences, not aesthetic preference.
- Use `Platform.select()` for platform-specific style variants.
- Define both Android elevation and iOS shadow props for cross-platform shadows.
- Use `KeyboardAvoidingView` behavior with
  `Platform.OS === 'ios' ? 'padding' : 'height'`.

## Typography

- Define a Text wrapper component enforcing the typography scale.
- Never use raw `<Text>` with inline font sizes in screens.
- Set `allowFontScaling={false}` only where layout genuinely breaks with large
  accessibility fonts.
- Otherwise respect user font scaling settings.
- Never assume `fontWeight` values are supported; verify font family weight support.

## Color and Contrast

- Maintain minimum contrast ratio `4.5:1` for normal text and `3:1` for large text
  (WCAG AA).
- Never use color alone to communicate state; pair with icon or label.
- Define separate token values for light and dark mode when both are supported.
- Do not hardcode dark-mode-hostile colors.

## Lists and Scrollable Content

- `FlatList` is default for any scrollable list.
- Never use `ScrollView + .map()` for more than `10` items.
- Always define `getItemLayout` when item height is fixed.
- Use `contentContainerStyle` for inner list/scroll padding.
- Never wrap list content in extra padding views.
- Use `refreshControl` for pull-to-refresh.
- Never implement custom manual pull gesture behavior.

## Loading and Empty States

- Every data-fetching screen must implement explicit loading, empty, and error states.
- Loading: prefer skeleton/shimmer for content areas.
- `ActivityIndicator` is acceptable for action-level waits, not full-screen content load.
- Empty: show helpful message and CTA where appropriate.
- Never render blank screens for empty data.
- Error: show actionable error with retry option.
- Never fail silently.

## Accessibility

- All interactive elements must have `accessibilityLabel` when not obvious from children.
- Use `accessibilityRole` on custom interactive components.
- Images must include `accessible={true}` and `accessibilityLabel` or
  `accessibilityHint`.

## Code Review Checklist

- Are all colors, spacing, and font sizes sourced from the token file?
- Are all tappable elements at least `44x44` dp?
- Is `SafeAreaView` from `react-native-safe-area-context` used on all screens?
- Are list screens using `FlatList` rather than `ScrollView + map`?
- Are loading, empty, and error states all handled?
- Are StyleSheet definitions outside component functions?
- Is `KeyboardAvoidingView` behavior platform-aware?

## If Unsure

Prefer token references over raw values, FlatList over ScrollView, SafeAreaView over
manual insets, and explicit loading/empty/error states over assuming data always
arrives.
