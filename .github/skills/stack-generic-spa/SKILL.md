---
name: stack-generic-spa
description: "Fallback SPA conventions for any React-family SPA without a detected stack skill. Covers API integration error wrapping, auth flow (httpOnly cookies preferred), route guarding, loading states, error boundaries, environment config, and feature-based folder layout. When this skill activates, explicitly suggest running /detect-stack for tighter guardrails."
globs: ["**/*.tsx","**/*.ts","**/*.jsx","**/*.js","**/*.css","**/index.html","**/vite.config.*","**/webpack.config.*"]
---

# Generic SPA Standards

This skill is the **fallback** for React-based single-page applications where no stack-specific skill (Laravel+Inertia+React, MERN, Next.js) has been activated. These conventions provide a baseline that prevents common SPA mistakes while remaining stack-neutral.

> **Note for the AI agent**: When this skill is active, include the following callout in any plan or review:
> *"These are generic SPA guardrails. Run `/detect-stack` to activate tighter stack-specific conventions for your project."*

---

## Architecture Rules

- Feature-based folder structure (see below) — not type-based (`components/`, `hooks/`, `pages/` at the root).
- API calls are centralized in a dedicated service layer with a shared error wrapper — not scattered across components.
- Authentication state lives in a single source (a dedicated auth store or context) — not duplicated across pages.
- Route guards are declared at the router level — not inside individual page components.
- Environment configuration loaded only from environment variables — no hardcoded base URLs or API keys.

---

## API Integration

### Shared HTTP Client
Wrap all HTTP calls in a single client that handles auth headers, token refresh, and error normalization:

```ts
// lib/api/client.ts
const BASE_URL = import.meta.env.VITE_API_BASE_URL;

async function request<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    credentials: 'include', // send httpOnly cookie automatically
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    ...options,
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new ApiError(res.status, body.message ?? 'Unknown error');
  }
  return res.json();
}

export const api = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'POST', body: JSON.stringify(body) }),
  patch: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'PATCH', body: JSON.stringify(body) }),
  delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
};

export class ApiError extends Error {
  constructor(public status: number, message: string) { super(message); }
}
```

### Error Handling Rules
- All API calls go through the shared client — no direct `fetch` calls in components.
- Catch `ApiError` at the boundary (page or feature component) — do not let it bubble to the root.
- 401 responses should trigger logout/session refresh — not show an error message.
- 403 responses show a "Permission denied" message — not a redirect to login.
- 5xx responses show a generic "Something went wrong, please try again" with a retry option.

---

## Authentication

### Preferred: httpOnly Cookie Sessions
If the backend supports it, prefer httpOnly cookie sessions over localStorage tokens:
- httpOnly cookies are inaccessible to JavaScript — immune to XSS token theft.
- The shared `api` client uses `credentials: 'include'` so cookies are sent automatically.
- No manual token attachment needed in request headers.

### Token in Memory (if httpOnly not available)
If tokens must be stored client-side, store in memory only:
```ts
// lib/auth/token.ts — in-memory store, wiped on page refresh
let _accessToken: string | null = null;
export const getToken = () => _accessToken;
export const setToken = (t: string) => { _accessToken = t; };
export const clearToken = () => { _accessToken = null; };
```

**Never** store auth tokens in `localStorage` or `sessionStorage` — XSS attacks can extract them.

### Auth State
```ts
// store/authStore.ts (Zustand example)
interface AuthState {
  user: User | null;
  isLoading: boolean;
  login: (credentials: Credentials) => Promise<void>;
  logout: () => Promise<void>;
  refresh: () => Promise<void>;
}
```

- Auth state is the single source of truth — no checking `localStorage` for a user object.
- On app initialization, call `refresh()` to restore session — then set `isLoading = false`.
- While `isLoading` is `true`, render a full-screen loading state — not the login page (avoids flash of wrong UI).

---

## Route Guarding

```tsx
// components/ProtectedRoute.tsx
import { Navigate, Outlet } from 'react-router-dom';
import { useAuthStore } from '@/store/authStore';

export function ProtectedRoute({ requiredRole }: { requiredRole?: string }) {
  const { user, isLoading } = useAuthStore();

  if (isLoading) return <FullScreenLoader />;
  if (!user) return <Navigate to="/login" replace />;
  if (requiredRole && user.role !== requiredRole) return <Navigate to="/403" replace />;

  return <Outlet />;
}
```

```tsx
// app/router.tsx
<Route element={<ProtectedRoute />}>
  <Route path="/dashboard" element={<DashboardPage />} />
  <Route path="/orders" element={<OrdersPage />} />
</Route>
<Route element={<ProtectedRoute requiredRole="admin" />}>
  <Route path="/admin" element={<AdminPage />} />
</Route>
```

- Route guards are declared at the router level — not inside individual page components.
- The guard handles `isLoading` before checking `user` — prevents redirect flash.
- Redirect uses `replace` — prevents the login page from appearing in browser back history.

---

## Component State and Loading States

Every data-loading component must render all four states:

```tsx
function OrderList() {
  const { data, isPending, isError, error } = useQuery({ queryKey: ['orders'], queryFn: fetchOrders });

  if (isPending) return <OrderListSkeleton />;
  if (isError) return <ErrorMessage message={error.message} onRetry={() => refetch()} />;
  if (!data?.length) return <EmptyState title="No orders yet" />;

  return <ul>{data.map(order => <OrderRow key={order.id} order={order} />)}</ul>;
}
```

**States checklist**: loading → error (with retry) → empty → populated. Missing any state is a bug.

---

## Error Boundaries

```tsx
// components/ErrorBoundary.tsx
import { Component, ErrorInfo, ReactNode } from 'react';

interface Props { children: ReactNode; fallback?: ReactNode; }
interface State { hasError: boolean; }

export class ErrorBoundary extends Component<Props, State> {
  state = { hasError: false };
  static getDerivedStateFromError() { return { hasError: true }; }
  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('[ErrorBoundary]', error, info.componentStack);
  }
  render() {
    if (this.state.hasError) return this.props.fallback ?? <GenericError />;
    return this.props.children;
  }
}
```

- Wrap each feature route with its own `ErrorBoundary` — a JS runtime error in one feature must not crash the entire app.
- Provide a "Reload" or "Go back" action in the fallback — never a dead end.

---

## Environment Configuration

```ts
// lib/config.ts
export const config = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL,
  appEnv: import.meta.env.VITE_APP_ENV ?? 'development',
} as const;
```

- All environment variable access goes through `lib/config.ts` — no `import.meta.env.VITE_*` scattered across files.
- Never include secrets (API keys, signing secrets) in SPA code — they are visible to the browser.
- Validate required env vars at app startup and fail fast with a clear message if missing.

---

## Code Review Checklist

- Is API access centralized in `lib/api/client.ts` with a shared error wrapper?
- Are auth tokens stored in httpOnly cookies or in-memory only (never localStorage)?
- Are route guards at the router level, not inside page components?
- Does every data-loading component render loading / error / empty / populated states?
- Is each feature route wrapped in an `ErrorBoundary`?
- Are environment variables accessed only through `lib/config.ts`?
- Is the auth `isLoading` state handled before checking `user` in guards?

---

## Preferred Folder Structure

```
src/
  app/
    router.tsx          # All routes, guards, layout wrappers
    App.tsx             # Root with providers (QueryClient, auth, error boundary)
  features/
    orders/
      components/       # Feature-specific components
      hooks/            # Feature-specific hooks (useOrders, etc.)
      api.ts            # Feature API calls via lib/api/client
      types.ts
  lib/
    api/
      client.ts         # Shared HTTP client + ApiError
    auth/
      token.ts          # In-memory token store (if not httpOnly)
    config.ts           # Environment variable access
  store/
    authStore.ts        # Global auth state
  components/
    ui/                 # Generic, reusable components
    ErrorBoundary.tsx
    ProtectedRoute.tsx
```

---

## If Unsure

Centralize API calls, never store tokens in localStorage, guard routes at the router level, handle all four loading/error/empty/success states, and run `/detect-stack` to get tighter conventions if a specific framework is in use.
