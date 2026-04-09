---
name: state-management
description: "Decision tree for client-side state — server state, global client state, form state, or local component state. Prevents state duplication, prop drilling, and the wrong library for the wrong problem. Auto-triggers via 1% Rule when adding stores, contexts, data fetching hooks, or global state."
globs: ["**/*.tsx","**/*.jsx","**/*.vue","**/*.ts","**/*.js"]
---

# State Management Skill

Client-side state management is one of the most over-engineered and under-thought problems in frontend development. This skill routes state decisions to the right pattern before any implementation begins.

## Trigger Conditions (1% Rule)

This skill fires when the task involves **any** of:
- Adding a new global state store (Redux, Zustand, Pinia, Recoil, MobX)
- Adding a new data fetching hook (`useQuery`, `useSWR`, `useFetch`)
- Adding a new React context or Vue provide/inject
- Forms with multi-step state or complex validation
- State that needs to persist across page navigation or app restarts
- Sharing state between more than 2–3 distantly related components

---

## Step 1 — Classify the State

Before choosing a solution, classify what kind of state you are managing:

```
Is this data fetched from a server and needs caching, refetching, or invalidation?
  → SERVER STATE

Is this data local to the UI that no API cares about (open/close, selected tab)?
  → LOCAL UI STATE

Is this data shared across many unrelated components AND not from a server?
  → GLOBAL CLIENT STATE

Is this data from a form the user is filling out?
  → FORM STATE

Is this a complex flow with multiple valid states and transitions (wizard, checkout)?
  → STATE MACHINE
```

---

## Server State

**The most common mistake**: putting server data in Redux or Zustand when a server state library will handle caching, background refetch, stale-while-revalidate, and optimistic updates automatically.

**Solutions by framework**:
- React: **TanStack Query** (preferred) or SWR
- Vue: **TanStack Query for Vue** or Pinia with action-based fetching
- React Native: **TanStack Query** (same library)
- Nuxt: `useFetch()` / `useAsyncData()` built-ins

**Rules**:
- Do not mix server state strategies — if the project uses TanStack Query, do not introduce SWR.
- Read `package.json` first to identify the existing server state library before adding one.
- Never use raw `useEffect + fetch` for data that requires caching, loading states, or refetching.
- Invalidate related queries on mutations — do not rely on timeout-based stale invalidation for data that changes immediately.

```ts
// ✅ Correct — TanStack Query handles loading/error/caching
const { data: user, isLoading, error } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
});

// ❌ Wrong — manual state management for server data
const [user, setUser] = useState(null);
const [loading, setLoading] = useState(false);
useEffect(() => { setLoading(true); fetchUser(userId).then(setUser).finally(() => setLoading(false)); }, [userId]);
```

---

## Local UI State

Local state is the **default**. Escalate to global state only when the "Shared State Checklist" passes.

**Solution**: `useState`, `useReducer` (React), `ref`/`reactive` (Vue)

**Shared State Escalation Checklist** — only escalate if ALL are true:
- [ ] The state is needed by 3+ components that do not share a direct parent-child relationship
- [ ] Passing the state via props would require 3+ levels of prop drilling
- [ ] The state is not derivable from server state via a query

If any condition is false — keep it local or lift to the nearest common parent.

---

## Global Client State

For state that is genuinely shared (user preferences, auth status, shopping cart before checkout, UI theme) AND is not server state.

**Solutions**:
- React: **Zustand** (preferred for simplicity) or Redux Toolkit (for complex, team-scale apps with devtools requirement)
- Vue: **Pinia**
- React Native: **Zustand**

**Rules**:
- Each store has a single, clearly named concern. Do not create a "global store" or "app store" that accumulates everything.
- Store actions are the only way to mutate store state — no direct state mutation from components.
- Auth token state belongs in the store; the token value itself belongs in secure storage.
- Do not use global state for data that the server is the source of truth for — use server state libraries instead.

```ts
// ✅ Correct Zustand store — single concern, named actions
const useCartStore = create<CartStore>((set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  removeItem: (id) => set((state) => ({ items: state.items.filter(i => i.id !== id) })),
  clear: () => set({ items: [] }),
}));
```

---

## Form State

Forms with validation, async submission, and error feedback have dedicated tools that are better than manual `useState` chains.

**Solutions**:
- React / React Native: **React Hook Form** (preferred), Formik (acceptable if already in project)
- Vue: **VeeValidate** or FormKit

**Rules**:
- Use the library's `register`/`control` pattern — do not maintain a parallel `useState` object for field values alongside a form library.
- Validation schema belongs in a Zod/Yup schema, not inline in the `onChange` handler.
- Multi-step forms: persist step state in the form library's `watch` / stored values — do not reset the form on step navigation.
- On submission error, mark the specific fields in error using the library's `setError` — do not show only a generic top banner.

```ts
// ✅ Correct — React Hook Form with Zod resolver
const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
  resolver: zodResolver(schema),
});
```

---

## State Machines

For complex flows with multiple valid states and explicit transitions (checkout, onboarding, document editor, game logic).

**Solution**: **XState** or a `useReducer` with explicit action types and a state shape.

**When NOT to use a state machine**: Simple boolean toggles, form disabled/enabled states, loading flags. These are local state.

**When to use**: When a flow has states like `idle → loading → submitting → succeeded | failed` AND some transitions are only valid from specific states.

---

## Persistence

| Storage | Use For | Never Use For |
|---|---|---|
| In-memory store (Zustand, Redux) | Runtime access to active session data | Auth tokens, sensitive PII |
| `localStorage` / `AsyncStorage` | Non-sensitive user preferences (theme, locale, dismissed banners) | Auth tokens, session data |
| `sessionStorage` | Temporary form data for the current browser session | Long-lived preferences |
| Secure Storage (Keychain, EncryptedStorage) | Auth tokens, API keys, sensitive credentials | Non-sensitive data (unnecessary overhead) |
| Server-side session | Auth session for cookie-based apps | Data that must survive session expiry |

**Non-Negotiable**: Never store JWTs or refresh tokens in `localStorage` — use `httpOnly` cookies (web) or OS secure storage (native).

---

## Hydration (SSR / SSG)

When using Next.js, Nuxt, or any SSR framework:
- Hydrate global store from server-rendered data in `_app.tsx` / `nuxt.config` / layout server data — not in individual components.
- Ensure store state on server matches initial client render to prevent hydration mismatches.
- Server state libraries (TanStack Query) handle dehydrate/hydrate natively — follow their SSR pairing docs.

---

## Anti-Patterns

- **Global state for local concerns**: putting a modal's open/close state in Redux because "it might be needed elsewhere someday."
- **Duplicating server state into a store**: fetching user data and storing it in Zustand AND keeping it in TanStack Query cache — leads to stale state.
- **Prop drilling beyond 2 levels**: if you're passing a prop through 3+ components to reach the consumer, it should be context or a store.
- **Mega-store**: a single store holding auth, cart, preferences, UI state, and notifications. Split by concern.
- **Async in reducers**: Redux/Zustand reducers are synchronous — async logic belongs in middleware (Redux Thunk/Saga) or store actions.

---

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
