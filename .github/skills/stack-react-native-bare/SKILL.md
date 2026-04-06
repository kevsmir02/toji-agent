---
name: stack-react-native-bare
description: "Authoritative architecture rules for React Native bare workflow — thin screens, custom hooks for logic, centralized API services, typed navigation, AsyncStorage patterns, Android/iOS permission handling, performance-aware lists. Apply ONLY when the Active Stack Profile in copilot-instructions.md shows Mode: stack-specific and Stack ID: react-native-bare. Overrides generic coding conventions for all TypeScript and React Native files in that stack."
globs: ["**/*.tsx","**/*.ts","**/screens/**","**/navigation/**"]
---

# React Native Bare Workflow Standards

Apply these rules as authoritative when this skill is active.

## Architecture Rules

- Screens are orchestration only: compose hooks and components, with no direct API calls or complex business logic.
- Business logic and side effects live in custom hooks under `src/hooks/`.
- All API calls are centralized in `src/services/`; never call Axios or fetch directly from a screen or component.
- Shared TypeScript types belong in `src/types/`; never inline types used across more than one file.
- Utilities in `src/utils/` must be pure functions only: no React imports and no side effects.
- Never use Expo-specific APIs (`expo-file-system`, `expo-secure-store`, etc.); this skill targets bare workflow projects.
- Treat React Native New Architecture as the default baseline (React Native 0.76+): do not add legacy-architecture-only guidance unless explicitly required by a compatibility constraint.

## Navigation Conventions

- Use React Navigation native-stack for navigation, not JS stack.
- Prefer React Navigation static configuration when possible; it reduces boilerplate and improves type inference.
- Define navigation param list types in `src/types/` and type every screen's navigation and route props.
- Never hardcode screen names as raw strings; use a typed `AppRoutes` (or equivalent) constant.
- Keep `useNavigation` default typing when possible; use manual navigator-specific annotations only when APIs like `push` or `openDrawer` are required.
- Always clean up navigation event listeners in `useEffect` cleanup functions.
- Handle Android hardware back button behavior explicitly where default back behavior is incorrect.

## API & HTTP Conventions

- If Axios is used, all requests go through one configured Axios instance.
- Never create ad hoc Axios instances.
- Set base URL, timeout, and default headers on the shared instance at initialization, not per request.
- Use Axios interceptors for auth token/cookie attachment and centralized error handling — see `defensive-coding` skill for the Resilience Matrix governing error containment, async resilience, and user-facing error UX.
- For cookie-based sessions, use `@react-native-cookies/cookies` to read/write cookies.
- Never manually parse `Set-Cookie` headers.
- Never store auth tokens or session cookies in component state.
- Never persist tokens in AsyncStorage; AsyncStorage is unencrypted.
- For credentials/tokens, use secure OS-backed storage wrappers (for example `react-native-keychain`) and keep access behind a dedicated auth module.

## AsyncStorage Patterns

- Always `await` AsyncStorage calls; never treat AsyncStorage as synchronous.
- Wrap AsyncStorage access in `try/catch`; calls can fail on low storage or platform issues.
- Never call AsyncStorage directly in component bodies; use `useEffect` or a custom hook.
- Use typed wrapper functions per stored key instead of scattered raw string keys.
- AsyncStorage is for non-sensitive persisted state only; never use it for secrets, passwords, or long-lived auth tokens.

## State Management

- Read the project's `package.json` before assuming any state library.
- If no dedicated state library exists, use component state + custom hooks + React Context for shared state.
- Never introduce a new state management library unless it is explicitly required by the feature brief.
- For server or async state, prefer dedicated hook patterns (useQuery-style).
- Avoid mixing fetched server data into local UI state structures unnecessarily.

## Performance

- Always use `FlatList` or `SectionList` for lists; never use `ScrollView` with `.map()` for more than roughly 10 items.
- Provide `keyExtractor` with a stable unique string; never use array index keys.
- Tune `FlatList` intentionally for large datasets (`initialNumToRender`, `maxToRenderPerBatch`, `updateCellsBatchingPeriod`, `windowSize`) based on device profiling.
- Use `getItemLayout` when item dimensions are fixed.
- Avoid anonymous `renderItem`; wrap callbacks with `useCallback`.
- Use `useCallback` for functions passed to list items or child components to reduce unnecessary re-renders.
- Use `useMemo` for expensive computed values only when profiling indicates benefit.
- Avoid inline object/array creation in JSX props; extract constants or memoize where needed.
- Profile performance in release builds, not only dev mode.
- Avoid shipping `console.*` calls in production bundles.

## Platform & Android Specifics

- Request permissions at point of use, not app launch; use `PermissionsAndroid` for runtime permission flows.
- Always check permission results before accessing hardware features (camera, storage, location).
- Use `KeyboardAvoidingView` with `behavior="height"` on Android where keyboard overlap must be handled.
- Test file system, network, and hardware features on physical device or emulator; simulator-only checks are insufficient.
- For `react-native-fs` operations, clean up temp/cache files after use.
- Never assume identical paths across Android and iOS; use `react-native-fs` path constants such as `DocumentDirectoryPath` and `CachesDirectoryPath`.

## TypeScript Conventions

- Use strict mode and avoid `any` as a type escape hatch.
- For React Navigation + TypeScript, ensure `moduleResolution: "bundler"` in `tsconfig.json` to match Metro behavior.
- Define explicit interfaces for API response shapes in `src/types/`.
- Use discriminated unions for mutually exclusive states (loading, error, success with data).
- Type navigation params so all `route.params` access is typed.

## Security

- Never log sensitive values (tokens, passwords, cookies) to console, including debug builds.
- Validate API responses before use; never assume server shape correctness.
- Never store plaintext passwords in AsyncStorage.
- Never ship secrets or private API keys inside the mobile app bundle.
- For OAuth flows, prefer PKCE-capable implementations and never pass sensitive data in deep links.
- Enable release obfuscation for Android with ProGuard/R8 in `android/app/build.gradle`.
- Keep Android keystores outside the repository and document secure storage expectations in project docs.

## Testing Expectations

- Use Jest with `@testing-library/react-native` for component and screen tests.
- Unit test custom hooks using `renderHook` patterns (`@testing-library/react-hooks` or modern equivalents).
- Unit test service and utility functions independently; they should be testable without device-only runtime behavior.
- Mock `@react-native-async-storage/async-storage`, `react-native-fs`, and navigation dependencies in tests.
- Test loading, error, and success states for every data-fetching screen.
- Include navigation type checks in CI (TypeScript compile step) so route/params regressions fail fast.

## Code Review Checklist

- Are screens free of direct API calls and complex business logic?
- Is Axios (or the project's HTTP client) used via the centralized service layer?
- Are all navigation screen names typed and backed by constants?
- Are lists implemented with `FlatList` plus `keyExtractor`?
- Are `useEffect` cleanups present for navigation listeners/subscriptions?
- Are permissions requested at point of use?
- Is AsyncStorage always awaited and wrapped in `try/catch`?
- Are API response shapes typed in `src/types/`?

## Preferred Folder Patterns

- `src/screens/` — screen-level orchestration components
- `src/components/` — reusable presentational components
- `src/hooks/` — custom hooks for logic, fetching, and auth
- `src/services/` — API service modules and shared Axios instance
- `src/navigation/` — navigator setup and route typing
- `src/types/` — shared TypeScript interfaces and types
- `src/utils/` — pure utilities and constants
- `__tests__/` (or feature-local `__tests__/`) — test suites

## If Unsure

Prefer thin screens, logic in hooks, API calls through the service layer, typed contracts throughout, and explicit platform-aware handling over assumptions about cross-platform behavior.

## Related Skills

- UI styling: `.github/skills/frontend-design-rn/SKILL.md`
- UX patterns: `.github/skills/ux-design-rn/SKILL.md`
