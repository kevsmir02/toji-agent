---
name: stack-nextjs
description: "Authoritative architecture rules for Next.js App Router — Server Components by default, Server Actions for mutations, data fetching conventions, middleware, ISR/SSG/SSR decision tree, Prisma/Drizzle patterns. Apply ONLY when Active Stack Profile shows Mode: stack-specific and Stack ID: stack-nextjs."
globs: ["**/*.tsx","**/*.ts","**/*.jsx","**/*.js","**/next.config.*","**/middleware.*","**/app/**","**/pages/**"]
---

# Next.js App Router Standards

Apply these rules as authoritative when this skill is active. The stack ID `stack-nextjs` is detected by the stack router when `next.config.*` is present and `next` is in `package.json` dependencies.

## Architecture Rules

- **Server Components (SC) are the default** — do not add `'use client'` unless the component requires browser APIs, event handlers, or React state/effects.
- Business logic belongs in dedicated service modules, not in Server Components or API routes.
- API Routes are for external consumers (webhooks, third-party integrations) — not for same-app data fetching, which belongs in Server Components or Server Actions.
- Keep the `app/` directory focused on routing: layouts, pages, error/loading boundaries. Move logic out.

---

## Server Components vs Client Components

### Decision Rule
```
Does the component need:
  - useState, useReducer, useEffect? → 'use client'
  - onClick, onChange, or other event handlers? → 'use client'
  - Browser-only APIs (window, document, localStorage)? → 'use client'
  - A library that uses React Context internally? → 'use client'
  - Otherwise → Server Component (default, no directive needed)
```

### Composition Pattern
- SC can import and render CC — but CC cannot render SC directly.
- Pass SC-fetched data to CC via props.
- Use the "leaf node" pattern: CC at the leaves of the component tree, SC higher up.

```tsx
// ✅ Correct — SC fetches data, passes to CC
// app/products/page.tsx (Server Component)
export default async function ProductsPage() {
  const products = await db.product.findMany(); // SC fetch, no API call needed
  return <ProductList products={products} />; // CC handles interactivity
}

// components/ProductList.tsx
'use client';
export function ProductList({ products }: { products: Product[] }) { ... }
```

### `'use client'` Placement
- Place `'use client'` as close to the leaf as possible — not at the top of a shared layout.
- A layout with `'use client'` is usually a sign of incorrect component split.

---

## Data Fetching

### Server Components (Preferred)
```tsx
// Fetch directly in async Server Components — no useEffect, no getServerSideProps
async function UserProfile({ userId }: { userId: string }) {
  const user = await db.user.findUnique({ where: { id: userId } });
  if (!user) notFound(); // from 'next/navigation'
  return <div>{user.name}</div>;
}
```

### Caching and Revalidation
```tsx
// Static (cached indefinitely) — default behavior
fetch('https://api.example.com/data');

// Time-based revalidation (ISR equivalent)
fetch('https://api.example.com/data', { next: { revalidate: 60 } }); // 60 seconds

// No cache (dynamic, per-request — SSR equivalent)
fetch('https://api.example.com/data', { cache: 'no-store' });

// Force dynamic rendering for the entire page
export const dynamic = 'force-dynamic';
```

### Caching Decision Tree
```
Is the data the same for every user and changes rarely?
  → Static (default) with periodic revalidation

Is the data personalized per user (auth session, user preferences)?
  → dynamic = 'force-dynamic' or cookies()/headers() in the route automatically opts in

Is the data shown publicly but updated frequently?
  → next: { revalidate: N } (time-based ISR)

Is there a webhook/event that signals when to update?
  → On-demand revalidation: revalidatePath() or revalidateTag()
```

---

## Server Actions

Server Actions are the preferred mutation mechanism for same-app form submissions and button actions.

```tsx
// app/actions/createOrder.ts
'use server';

import { z } from 'zod';
import { auth } from '@/lib/auth';
import { db } from '@/lib/db';

const schema = z.object({ productId: z.string(), quantity: z.number().min(1) });

export async function createOrder(formData: FormData) {
  const session = await auth();
  if (!session) throw new Error('Unauthorized');

  const parsed = schema.safeParse({
    productId: formData.get('productId'),
    quantity: Number(formData.get('quantity')),
  });
  if (!parsed.success) return { error: parsed.error.flatten() };

  const order = await db.order.create({
    data: { userId: session.user.id, ...parsed.data },
  });
  revalidatePath('/orders');
  return { order };
}
```

### Server Action Rules
- Always validate with Zod inside Server Actions — never trust `formData` values directly.
- Always check authentication inside Server Actions — they are not automatically protected.
- Return typed responses: `{ data } | { error }` — do not `throw` for expected business errors.
- Use `revalidatePath()` or `revalidateTag()` after mutations to invalidate stale cache.
- Server Actions do not replace API routes for webhook endpoints or third-party integrations.

---

## Route Segment Files

| File | Purpose |
|---|---|
| `page.tsx` | Public UI for the route segment |
| `layout.tsx` | Persistent UI wrapper, shared across child segments |
| `loading.tsx` | Suspense boundary skeleton shown during route transition |
| `error.tsx` | Error boundary with recovery UI for the segment |
| `not-found.tsx` | 404 UI triggered by `notFound()` |
| `template.tsx` | Like layout but re-rendered on every navigation (for animations) |
| `route.ts` | API endpoint for external consumers |

- `loading.tsx` and `error.tsx` must be created for any route that fetches significant data.
- `error.tsx` must have a "Try again" `reset` action for recoverable failures.
- Do not use `template.tsx` unless animations require it — it carries a performance cost.

---

## Middleware

```ts
// middleware.ts (at project root)
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('session-token');
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/protected/:path*'],
};
```

### Middleware Rules
- Use middleware for: auth redirects, locale detection, A/B routing, header injection.
- Do NOT use middleware for: business logic, database queries, heavy computation — the Edge Runtime has no Node.js APIs.
- Always export a `config.matcher` — do not run middleware on every route including static assets.
- Middleware runs on Edge Runtime — no Prisma, no Node.js built-ins. Use lightweight JWT verification only.

---

## Database Layer

### Prisma (Preferred)
```ts
// lib/db.ts — singleton client
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };
export const db = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db;
```

- Always use the singleton pattern above for the Prisma client in Next.js — prevents connection pool exhaustion in development hot-reload.
- Use Prisma's `select` and `include` to fetch only required fields — never `findMany()` without constraints.
- Paginate list queries with `take` and `skip` or cursor-based pagination.
- Use `prisma.$transaction` for multi-step operations that must be atomic.

### Connection Pooling for Serverless
- In Vercel/serverless: use `@prisma/adapter-neon`, `@prisma/adapter-planetscale`, or similar edge-compatible adapters.
- Do not create new `PrismaClient()` instances per request — they exhaust connection pools.

---

## Authentication

- Use **NextAuth.js** (Auth.js v5) for most authentication needs.
- Session in Server Components: `auth()` from the auth config.
- Session in Client Components: `useSession()` from `next-auth/react`.
- Never implement custom JWT signing or session management — delegate to Auth.js or a dedicated auth service.
- Protect API routes with `auth()` checks at the top of the handler.

---

## Testing Expectations

- **Unit tests**: Pure utilities, Server Action business logic (with mocked db), Zod schema validation — Vitest.
- **Component tests**: CC components with React Testing Library + Vitest (MSW for API mocking).
- **Integration tests**: API routes with `fetch` or Supertest, Server Actions with mocked Prisma.
- **E2E tests**: Playwright for critical flows (auth, primary feature, checkout).
- Server-side rendering paths: test with Playwright against the running Next.js dev server, not with unit tests of the component render.

---

## Code Review Checklist

- Are SC used by default with `'use client'` only where required?
- Is data fetching done in SC directly (not via `useEffect` or client-side API calls where SC would suffice)?
- Are Server Actions validated with Zod and authenticated before mutation?
- Are `loading.tsx` and `error.tsx` present for data-heavy routes?
- Is the Prisma singleton pattern used (no `new PrismaClient()` per request)?
- Are paginated queries using `take`/`skip` or cursor pagination?
- Is middleware scoped with `config.matcher`?
- Are cache invalidations (`revalidatePath`/`revalidateTag`) called after mutations?

---

## Preferred Folder Structure

```
app/
  (auth)/            # Route group — auth pages (no shared layout)
    login/page.tsx
    register/page.tsx
  (dashboard)/       # Route group — protected app pages
    layout.tsx       # Auth check + dashboard shell
    orders/
      page.tsx       # Server Component — list orders
      [id]/page.tsx  # Server Component — order detail
  api/
    webhooks/        # External-only API routes
lib/
  db.ts              # Prisma singleton
  auth.ts            # NextAuth config + auth() helper
actions/             # Server Actions by domain
  createOrder.ts
  updateProfile.ts
components/
  ui/                # Generic presentational components
  features/          # Feature-specific client components
```

## If Unsure

Prefer Server Components, minimize `'use client'` boundaries, validate all Server Action inputs with Zod, and let Next.js handle caching rather than adding manual state management for data that comes from the server.
