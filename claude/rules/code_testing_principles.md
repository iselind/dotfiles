---
name: code_testing_principles
description: Three test tiers (e2e for behavior, integration for external system interaction, unit for surgical targeting) organized by purpose, not LOC coverage
metadata:
  type: feedback
---

**Principle:** Code is tested through three complementary tiers, each serving a distinct purpose. Testing is organized around *what you're testing* (behavior vs. integration), not around achieving 100% line coverage.

**Test Tiers:**

**E2E Tests** — Behavior-focused
- **What:** Tests system behavior from the user's perspective
- **External Dependencies:** Mocked away (Mimir, databases, other services) to keep tests focused and fast
- **Purpose:** Verify that the system does what it should
- **Example:** "When I call this API endpoint with X, does it return Y?"

**Integration Tests** — External System Interaction
- **What:** Tests how the codebase's components interact with real external systems
- **External Dependencies:** Real instances (actual database, actual Mimir, actual external services)
- **Purpose:** Verify that your code talks correctly to the systems it depends on
- **Example:** "Does my database query actually work against a real Postgres instance?"
- **Note:** Not testing whether Postgres works; testing whether your code works with Postgres

**Unit Tests** — Surgical & Targeted
- **What:** Tests very specific situations
- **Scope:** Individual functions or small logical units
- **Use cases:**
  - Documentation/example tests (showing how to use a function)
  - Edge cases that are hard or impossible to reach through behavioral tests
- **Not a tier for comprehensive coverage** — use sparingly and intentionally

**Coverage Philosophy:**
- Coverage goal is not "100% of lines" but "all meaningful behaviors and integration points"
- e2e tests cover happy paths and main behaviors
- Integration tests cover the external system interaction points
- Unit tests fill in hard-to-reach edge cases and serve as examples

**Why:** This structure ensures behaviors are validated, integrations are verified, and edge cases are documented without chasing meaningless LOC coverage metrics. Each tier answers a different question.

**How to apply:**
- When adding a test, ask: "Am I testing behavior (e2e), testing interaction with an external system (integration), or targeting a specific edge case/documenting usage (unit)?"
- E2E tests should be the primary focus; integration tests verify the mocked dependencies actually work; unit tests fill surgical gaps
- See [[change_support_evidence]] for how testing fits into broader change support requirements.
