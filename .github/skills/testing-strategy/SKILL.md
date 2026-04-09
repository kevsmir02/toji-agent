---
name: testing-strategy
description: "Layer-appropriate test type selection — unit vs integration vs E2E vs contract. Determines what kind of test to write for each architectural layer. Complements the TDD skill (which governs when and in what order to test) with guidance on what kind of test to write."
globs: ["**/*.test.*","**/*.spec.*","**/__tests__/**","**/tests/**","**/test/**"]
---

# Testing Strategy Skill

The TDD Iron Law governs *when* to write tests (always, before implementation). This skill governs **what kind** of test to write for each layer. These are complementary — both must be followed.

## Test Type Decision Tree

For each behavior slice identified in the TDD workflow, select the appropriate test type:

```
Is it a pure function, domain rule, or transformation with no I/O?
  → Unit test

Does it involve a database query, ORM method, or repository layer?
  → Integration test with a real test database (or in-memory equivalent)

Does it involve HTTP routing, middleware, request/response contracts, or authorization?
  → Integration test (API-level, full request lifecycle)

Does it involve a critical multi-page user flow from the browser's perspective?
  → E2E test (Playwright, Cypress, or Detox for RN)

Does it involve a contract between two services or between frontend and backend?
  → Contract test (Pact, ts-rest contract assertions, or schema validation)

Is it a React/Vue component with user interaction (clicks, input, state changes)?
  → Component test (React Testing Library, Vue Testing Library, RNTL)
```

---

## Unit Tests

**What belongs here**: Pure functions, utility modules, domain model logic, DTO transformations, calculations, validators, string formatters.

**Rules**:
- A unit test must be fast (< 5ms per test), deterministic, and require no external setup.
- No database connections, no network calls, no filesystem access — mock all of these.
- Test **behavior**, not **implementation**: assert on outputs and side effects, not on which internal methods were called.
- Do not unit test private methods or internal state — only the public contract.

**Anti-patterns**:
- Mocking the subject under test (you're testing the mock, not the code)
- Testing that a constructor was called (tests implementation, not behavior)
- Testing trivial getters/setters with no logic

---

## Integration Tests

**What belongs here**: API routes, controllers, middleware, database queries, repository methods, service layer with real dependencies.

**Rules**:
- Use a separate test database — never run integration tests against production or development DB.
- Each test is responsible for seeding its own data and cleaning up after itself (or use transactions that roll back).
- Test the full request lifecycle for HTTP endpoints: request in → middleware → handler → response out. Do not mock the router.
- Test both happy path AND critical failure cases (validation failure, auth denied, resource not found, duplicate key).
- Authorization tests are **mandatory** for every protected route — at minimum: unauthenticated (401), wrong role (403), correct owner (200).

**Framework examples**:
- Laravel: Pest feature tests with `RefreshDatabase` trait; test HTTP with `$this->postJson(route('...'))`.
- Express/MERN: Supertest for HTTP integration; mongoose-memory-server or a test MongoDB instance.
- Next.js: Vitest + inline API handler tests; Playwright for App Router routes.

---

## E2E Tests

**What belongs here**: Critical user journeys that span multiple pages or screens, OAuth flows, checkout flows, core onboarding paths.

**Rules**:
- E2E tests are expensive to write, slow to run, and brittle — use them sparingly.
- Target the **5–10 most critical user paths**, not exhaustive page-by-page coverage.
- Use `testID` (React Native / web `data-testid`) attributes as selectors — never text content or CSS classes, which are brittle.
- E2E tests run in CI on every PR for the critical paths; extended suites run on merge to main.
- A failing E2E test is a **blocking issue** — do not merge with a known E2E regression.

**Minimum E2E coverage**:
1. Authentication: sign up, log in, log out
2. Core value action: the primary feature the product is built around
3. Error recovery: one important error case (e.g., failed payment, network failure on submit)

---

## Component Tests (UI)

**What belongs here**: Interactive React/Vue/Svelte/RN components with meaningful user interaction — buttons with callbacks, forms with validation, modals, dropdowns.

**Rules**:
- Use Testing Library principles: query by accessible role or label, not by CSS selector or component internals.
- Test user interactions (`userEvent.click`, `fireEvent.change`) and assert on the resulting DOM/rendered output.
- Do not test styling or visual appearance in component tests — that belongs in visual regression or Storybook.
- Mock API calls (with MSW or similar) — component tests should not make real network requests.

**What does NOT need a component test**: Simple presentational components with no logic (a `<Badge color="red">text</Badge>` with no state or callbacks).

---

## Contract Tests

**What belongs here**: API contracts between frontend and backend, or between microservices.

**When to use**:
- When frontend and backend are developed independently or by separate teams
- When an API is consumed by external clients
- When using `ts-rest`, `tRPC`, or `OpenAPI` — validate that implementations match the contract spec

**Rules**:
- Contract tests are not integration tests — they test the agreed contract shape, not the internal behavior.
- For `ts-rest`: use the contract's type assertions as the source of truth; implementation tests verify adherence.
- For REST APIs: generate a JSON Schema or OpenAPI spec from the implementation and validate responses against it in CI.

---

## Fixture and Factory Discipline

### Rule: factories over raw fixtures
- Use factory functions (FactoryBot for Rails, Laravel's model factories, `factory-ts` / `jest-factory` for Node) — not hardcoded JSON fixture files.
- Factories allow per-test customization without file proliferation.
- Fixtures (static JSON/YAML files) are acceptable for complex input parsing tests (e.g., CSV import, webhook payload parsing) where the exact byte content matters.

### Test Data Rules
- Each test creates only the data it needs — no shared, pre-seeded state that creates test order dependency.
- Use deterministic fake data (`@faker-js/faker` with a fixed seed) when real-looking data is needed.
- Never use production data in tests, even anonymized — generate synthetic data.
- Database sequences and auto-increment IDs must not be relied on for test assertions (IDs will differ per run).

---

## Coverage Guidance

| Layer | Minimum Coverage Target |
|---|---|
| Domain logic / business rules | 90%+ line coverage |
| Auth pathways | 100% (every protected route tested for authn + authz) |
| API route handlers | 80%+ (happy path + primary failure cases) |
| Repository / data access | 70%+ |
| UI components with interactions | 70%+ of interactive components |
| Utility functions | 90%+ |
| E2E flows | 5–10 critical paths (not a % metric) |

Coverage is a floor, not a goal — 100% coverage with tests that don't assert anything meaningful is worse than 70% with high-confidence tests.

---

## Anti-Patterns

- **Testing that a method was called** (tests implementation, not behavior) — assert on the *outcome* instead.
- **Shared mutable test state** — each test must set up and tear down its own state.
- **Overmocking** — if a test mocks 80% of the code under test, it is not testing real behavior. Write an integration test instead.
- **Testing the framework** — do not test that `express.Router` routes a request; test that your handler responds correctly.
- **Test-to-implementation drift** — if you change the test to make it pass rather than the implementation, you have failed. See TDD Delete Rule.

---

## Session Closure — Atomic Instinct (mandatory)

Use `.github/copilot-instructions.md` → Session Intelligence → Atomic Instincts as the source of truth.
Append one instinct bullet to `.github/lessons-learned.md` when the global criteria are met; otherwise output `Lesson: N/A` in the same response.
