---
name: stack-react-native-bare
description: "Authoritative architecture rules for React Native Bare Workflow — New Architecture as default, React Navigation static API, OS-backed secure storage for tokens, Metro config, Detox E2E. Apply ONLY when Active Stack Profile shows Mode: stack-specific and Stack ID: react-native-bare."
globs: ["**/*.tsx","**/*.ts","**/*.java","**/*.kt","**/*.swift","**/*.m","**/*.objc"]
---

# React Native Bare Workflow Standards

Apply these rules as authoritative when this skill is active. The stack ID `react-native-bare` is detected by the stack router when `react-native` is present without `expo` as a direct dependency and `android/` or `ios/` directories exist.

## Architecture Rules

- **New Architecture is the default** (Fabric renderer, TurboModules, JSI). Do not opt out of new architecture unless a native module explicitly does not support it and no alternative exists — document the exception.
- Keep business logic in plain TypeScript modules, not inside screen components.
- Screen components are orchestrators: they read state, dispatch actions, and render. Business logic belongs in use-case or service modules.
- Shared UI components live in `src/components/`; screen-specific sub-components co-locate with the screen file.

---

## React Navigation

### Typed Static API (v7+)
```ts
// navigation/types.ts
export type RootStackParamList = {
  Home: undefined;
  Profile: { userId: string };
  Settings: undefined;
};
```

- Use the **static navigation API** with typed `ParamList` — do not use the legacy dynamic `useNavigation()` without type generics.
- Declare all navigators with their `ParamList` type at creation: `createNativeStackNavigator<RootStackParamList>()`.
- Every `navigate` call must be type-checked against the `ParamList`.

### Navigation Rules
- Never navigate using `navigation.replace` as a substitute for correct stack architecture.
- Deep linking config must be defined in the `NavigationContainer` `linking` prop from day one.
- Screen `options` (title, header, back button) are defined in the navigator config, not in `useLayoutEffect` inside the screen (prefer declarative over imperative).

---

## Secure Storage

### Token Storage (Non-Negotiable)
- **Auth tokens (access/refresh) MUST be stored in OS-backed secure storage:**
  - iOS: Keychain via `react-native-keychain` or `expo-secure-store` (even in bare workflows)
  - Android: Keystore-backed EncryptedSharedPreferences via the same libraries
- **AsyncStorage is FORBIDDEN for auth tokens** — it stores data in plaintext on the filesystem.
- Non-sensitive user preferences (theme, language, onboarding completed) → MMKV or AsyncStorage is acceptable.
- Session state in memory (Redux, Zustand) is fine for runtime access; persist only to secure storage for persistence across app restarts.

### Secret Detection
Any code that stores a JWT, refresh token, or API key in `AsyncStorage` is an automatic FAIL — rewrite with secure storage before proceeding.

---

## State Management

- Prefer Zustand or Redux Toolkit for global client state.
- Server/remote data → TanStack Query React Native or SWR.
- Always persist auth token to secure storage synchronously on receipt — do not rely on in-memory state surviving a background kill.

---

## Performance

- Enable Hermes engine in both iOS and Android — do not disable it.
- Use `React.memo` for list item components that render in `FlatList`/`FlashList` — unnecessary re-renders in long lists are a critical perf issue.
- Prefer `FlashList` over `FlatList` for long scrolling lists.
- Never use `ScrollView` for lists of 20+ items — use `FlatList` or `FlashList`.
- Use `useCallback` for functions passed as props to memoized children; use `useMemo` for expensive derivations.
- Avoid `useEffect` for data that can be derived synchronously — prefer computed values.

---

## Metro Configuration

```js
// metro.config.js
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

const config = {
  resolver: {
    sourceExts: ['tsx', 'ts', 'jsx', 'js', 'json', 'svg'],
    assetExts: ['png', 'jpg', 'gif', 'webp', 'ttf', 'otf'],
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
```

- Do not modify Metro config without understanding the impact on the bundler — test on both platforms after any change.
- Use `moduleNameMapper` in Jest config to mirror Metro aliases — mismatches cause test pass/app fail issues.

---

## Native Module Bridging

- Prefer JSI-based TurboModules over legacy bridge modules for new native functionality.
- Isolate platform-specific code in `.ios.ts` / `.android.ts` files — do not use `Platform.OS` guards throughout the business logic layer.
- Document every native module dependency in `docs/ai/implementation/` with the reason for native code, iOS/Android setup steps, and known limitations.

---

## Testing Expectations

### Unit and Component Tests (Jest + RNTL)
- Use `@testing-library/react-native` for component tests.
- Mock navigation with `jest-mock-react-navigation` or the library's provided mock — never rely on a real navigation container in unit tests.
- Mock `react-native-keychain` and `@react-native-async-storage/async-storage` in test setup.

### E2E Tests (Detox)
- Detox E2E tests cover critical user flows only: login, primary feature completion, logout.
- Use Detox matchers with accessibility IDs (`testID` prop) — not text content, which is brittle.
- Run E2E tests on both iOS Simulator and Android Emulator in CI.

### Testing Setup
```ts
// jest.setup.ts
jest.mock('react-native-keychain', () => ({
  setGenericPassword: jest.fn(),
  getGenericPassword: jest.fn(),
  resetGenericPassword: jest.fn(),
}));
```

---

## Security

- Never store sensitive data in `AsyncStorage` (see Secure Storage above).
- Enable certificate pinning for production API calls when handling financial or health data.
- Obfuscate the release build (ProGuard/R8 on Android, Bitcode on iOS) — this is enabled by default in release builds; do not disable it.
- Rotate refresh tokens on use — do not allow a single refresh token to be valid indefinitely.
- Use `HTTPS` exclusively — no HTTP allowed in production environment config.

---

## Build and Release

- Keep `android/` and `ios/` directories in `.gitignore` for generated files only — native source and config files must be committed.
- Use Fastlane or similar CI tooling for reproducible builds — never rely on manual Xcode/Android Studio builds for production.
- Hermes bytecode precompilation is enabled by `hermes: true` in Podfile (iOS) — confirm this is set.
- Android build uses `bundleReleaseJsAndAssets` to produce the production JS bundle — test this step in CI.

---

## Code Review Checklist

- Is New Architecture enabled (`newArchEnabled=true` in `gradle.properties`, `:USE_HERMES` in Podfile)?
- Are all auth tokens stored in OS-backed secure storage, not AsyncStorage?
- Are all navigators typed with `ParamList`?
- Are list components using `FlatList` or `FlashList`, not `ScrollView`?
- Are `StyleSheet.create` + design tokens used instead of inline style objects?
- Do platform-specific behaviors use `Platform.select` or file extension splitting?
- Are Detox test IDs (`testID`) present on critical interactive elements?

---

## Preferred Folder Structure

```
src/
  components/          # Shared presentational components
  screens/             # Feature screens (co-located with sub-components)
  navigation/          # Navigators and types
  hooks/               # Reusable custom hooks
  stores/              # Zustand stores / Redux slices
  services/            # API clients, business logic modules
  utils/               # Pure utility functions
  theme/               # Token file, typography, spacing constants
  assets/              # Static images, fonts
```

## If Unsure

Prefer New Architecture patterns, typed navigation, OS-secure storage, and `FlashList` over legacy equivalents. When in doubt, check whether the choice isolates platform-specific code and prevents security regressions.
