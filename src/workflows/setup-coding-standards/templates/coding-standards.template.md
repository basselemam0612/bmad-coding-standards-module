# Coding Standards — {{project_name}}

> **Living document** — Code review agents append new rules when violations are found that aren't covered here.
> This document complements the Architecture Decision Document. Architecture defines WHAT to build and WHY. This document defines HOW to build it correctly.

## How This Document Works

### Permissions

| Role | Access | Responsibility |
|------|--------|----------------|
| Dev Agent | **Read** | Follow all rules during implementation |
| QA Agent | **Read** | Verify compliance in tests and test reviews |
| Quick-Flow Dev Agent | **Read** | Follow all rules during quick implementations |
| Architect Agent | **Read + Write** | Update rules when architecture decisions change |
| Code Review (workflow) | **Read + Write** | Check compliance AND append new rules when new violation patterns are found |

### Rule Format

Each rule has:
- **ID**: Category prefix + number (e.g., FE-003). IDs are permanent — never renumbered.
- **DO**: What to do — specific, actionable.
- **DON'T**: What to avoid — specific, actionable.
- **BAD PRACTICE**: The exact mistake developers commonly make with this technology — describe the specific anti-pattern, what it looks like in code, and what goes wrong when you do it. This is the most valuable field — it tells dev agents exactly what NOT to fall into.
- **WHY**: Links to architecture decision, PRD requirement, or industry standard.
- **SOURCE**: Architecture decision / code review finding / research (for traceability).

### Adding New Rules

When the Code Review agent finds a violation pattern NOT covered by an existing rule:
1. Create a new rule in the correct section with the next available ID
2. Follow the DO/DON'T/BAD PRACTICE/WHY/SOURCE format exactly
3. Add an entry to the Changelog at the bottom

---

## 1. Universal Rules (All Platforms & Languages)

These apply to every file in every platform — regardless of language or framework.

### U-001: Use Shared Constants, Never Hardcode

- **DO:** Import enums, status values, permission strings, and config defaults from the shared package or constants file.
- **DON'T:** Write string literals in application code when those values exist as constants.
- **BAD PRACTICE:** Writing `if (status === "ACTIVE")` or `role === "admin"` directly in code when `Status.ACTIVE` and `Role.ADMIN` constants exist in the shared package. This drifts immediately — someone renames the constant but misses the hardcoded strings. The code compiles, tests pass, production breaks.
- **WHY:** A single source of truth prevents drift between platforms and components.
- **SOURCE:** Industry standard (DRY principle)

### U-002: No Magic Numbers

- **DO:** Define all thresholds, timeouts, limits, intervals, and numeric config as named constants or config values. Use descriptive names.
- **DON'T:** Write bare numbers in logic. Every number should have a name that explains its purpose.
- **BAD PRACTICE:** Writing `if (elapsed > 86400000)` or `priority: 50` or `setTimeout(fn, 1800000)`. Nobody reading the code knows what 86400000 means (it's 24 hours in milliseconds). When the business rule changes from 24 hours to 12 hours, you have to grep for a magic number across the entire codebase.
- **WHY:** Magic numbers are unreadable, undiscoverable, and impossible to change globally.
- **SOURCE:** Industry standard (Clean Code)

### U-003: Module Boundary Respect

- **DO:** Module A calls Module B's service/API to access Module B's data.
- **DON'T:** Module A directly queries Module B's database tables, internal state, or private APIs.
- **BAD PRACTICE:** The health monitoring module directly running `SELECT * FROM devices WHERE ...` instead of calling `deviceService.findById()`. When the device table schema changes, the health module breaks silently because nobody knew it was coupled to that table.
- **WHY:** Modules must be independently deployable and replaceable. Direct cross-module access creates invisible coupling.
- **SOURCE:** Industry standard (Modular architecture)

### U-004: Config Injection, Never Direct Environment Access

- **DO:** Use the framework's config injection system for all environment-specific values.
- **DON'T:** Read environment variables directly in application code. Config reading happens in ONE place (the config module), everything else receives it via injection.
- **BAD PRACTICE:** Writing `const secret = process.env.JWT_SECRET` in a service file. This bypasses config validation, makes the service untestable without setting env vars, and scatters config knowledge across the codebase. When you need to change a config value, you have to grep the entire codebase.
- **WHY:** Direct env access scatters config knowledge, makes testing impossible without env manipulation, and bypasses validation.
- **SOURCE:** Industry standard (12-factor app)

### U-005: Audit Every State Change

- **DO:** Log to the audit service for every create, update, delete, and authentication event. Include: actor, action, entity, old value, new value, timestamp.
- **DON'T:** Skip audit logging for "minor" state changes. DON'T fire-and-forget audit writes without error handling.
- **BAD PRACTICE:** Adding `try { auditService.log(...) } catch(e) { /* ignore */ }` around audit calls — silently swallowing audit failures means you lose compliance records and never know they're missing. Equally bad: skipping audit on "simple" operations like login/logout, which are the most important events for security investigation.
- **WHY:** Audit trail is a compliance and operational requirement, not optional instrumentation.
- **SOURCE:** Industry standard (SOC 2, GDPR)

### U-006: No Silent Failures

- **DO:** Every caught error must be logged with context AND either re-thrown as a typed exception or handled with explicit recovery logic.
- **DON'T:** Use empty catch blocks. DON'T log and continue as if nothing happened.
- **BAD PRACTICE:** Writing `catch (error) { console.log(error) }` and continuing execution as if nothing happened. The error gets logged to stdout where nobody reads it, the function returns undefined or empty data, the calling code treats it as success, and corrupted state propagates silently through the system.
- **WHY:** Silent failures corrupt data and make debugging impossible.
- **SOURCE:** Industry standard (Defensive programming)

### U-007: Impact Analysis Before Every Edit

- **DO:** Before editing any function, class, or type: find all references. Find references to THOSE references (cascade). Update ALL affected code in the same change.
- **DON'T:** Edit a shared type, interface, or function signature without checking what depends on it.
- **BAD PRACTICE:** Renaming a field in a shared interface and only updating the file you're working in. The 5 other files importing that interface compile fine (TypeScript shows errors but the dev ignores or misses them) and break at runtime. Always use Find Referencing Symbols before editing shared code.
- **WHY:** Untraced changes break consumers silently.
- **SOURCE:** Industry standard (Refactoring safety)

### U-008: No Placeholder or Stub Implementations

- **DO:** Implement the full feature or throw a NotImplemented exception with a descriptive message.
- **DON'T:** Return empty arrays, fake success responses, or leave "TODO: implement later" comments.
- **BAD PRACTICE:** Creating `DataTable.tsx`, `FilterBar.tsx`, `ExportButton.tsx` as empty files that `export default function DataTable() { return null }` — the architecture says "shared components exist," but they're empty shells. Every feature then builds its own table, filter, and export from scratch because the "shared" versions do nothing.
- **WHY:** Placeholders are invisible broken features that pass tests and ship to production as silent failures.
- **SOURCE:** Industry standard (Complete implementation)

### U-009: Import From Shared Package, Never Redefine

- **DO:** If a type, interface, enum, constant, or utility exists in the shared package, import it.
- **DON'T:** Copy-paste type definitions. DON'T redefine shared types locally in feature modules.
- **BAD PRACTICE:** Defining `interface PaginatedResponse { data: any[]; total: number; page: number }` in 4 different hook files when `@shared/types` already exports the same interface. When the shared type adds a `pageSize` field, the 4 local copies don't get it, and API responses start failing because the shape doesn't match.
- **WHY:** Duplicate definitions drift immediately and cause runtime bugs that compile cleanly.
- **SOURCE:** Industry standard (DRY principle)

### U-010: Date Handling

- **DO:** Use a consistent date format (ISO 8601 UTC recommended) for all date storage and API transport. When filtering by date-only values, handle timezone boundaries explicitly.
- **DON'T:** Use locale-specific date formats for storage. DON'T assume date-only strings include the full day.
- **BAD PRACTICE:** Using `new Date("2026-03-21")` as a filter end date — this creates midnight UTC, which EXCLUDES every entry from March 21st. The user filters "show me March 21" and gets zero results for that day. Always set date-only end filters to `23:59:59.999Z`.
- **WHY:** Off-by-one day bugs are subtle and affect every report and filter.
- **SOURCE:** Industry standard (Date handling)

---

<!-- PLATFORM-SPECIFIC SECTIONS -->
<!-- The setup workflow generates sections below based on detected tech stack. -->
<!-- Number and type of sections vary per project. Only relevant sections are created. -->
<!-- If you are reading this template directly: the workflow will replace this area. -->

---

## Security Rules

> Always populated — security rules apply to every project.

### SC-001: Input Validation at System Boundaries

- **DO:** Validate all user input, API parameters, and external data at the point of entry.
- **DON'T:** Trust any data from outside the system boundary. DON'T validate only on the client — server validation is mandatory.
- **BAD PRACTICE:** Accepting any string for an enum-typed parameter like `GET /alerts/:alertType` without validation — an attacker sends `/alerts/../../etc/passwd` or `/alerts/DROP TABLE` and your code tries to process it. Always use ParseEnumPipe, @IsEnum, or equivalent.
- **WHY:** OWASP Top 10 — injection, XSS, and data integrity all start with unvalidated input.
- **SOURCE:** Industry standard (OWASP)

### SC-002: Authentication Endpoints Must Have Rate Limiting

- **DO:** Apply rate limiting to all authentication, activation, and credential-accepting endpoints.
- **DON'T:** Leave any endpoint that accepts secrets or credentials without rate limiting.
- **BAD PRACTICE:** Deploying a login endpoint or activation code endpoint without rate limiting. An 8-character hex code has 4.3 billion combinations — without rate limiting, an attacker can brute-force it in hours. "We'll add rate limiting later" means you ship a brute-forceable endpoint to production.
- **WHY:** Brute-force protection is a minimum security standard.
- **SOURCE:** Industry standard (OWASP)

### SC-003: Secrets Never in Code

- **DO:** Store secrets in environment variables, secret managers, or encrypted config. Access via config injection.
- **DON'T:** Hardcode API keys, passwords, tokens, or connection strings in source code.
- **BAD PRACTICE:** Writing `const API_KEY = "sk-live-abc123..."` in a config file that gets committed to git. Even if you delete it later, it's in git history forever. Also bad: putting real credentials in `.env.example` files — those get committed and copied.
- **WHY:** Secrets in code end up in git history permanently.
- **SOURCE:** Industry standard (12-factor app)

---

## Testing Rules

> Always populated — testing standards apply to every project.

### TS-001: Shared Test Helpers, Never Copy-Paste

- **DO:** Create shared test factories, helpers, and utilities. Import and reuse across test suites.
- **DON'T:** Copy-paste test setup code across test files.
- **BAD PRACTICE:** Copy-pasting a `createActiveDevice()` helper into 5 different test files. When the device creation API changes, you update 2 files, miss 3, and get flaky tests that fail inconsistently depending on which test file runs.
- **WHY:** Duplicated test setup diverges and breaks independently.
- **SOURCE:** Industry standard (DRY in tests)

### TS-002: Clean Up Test Data

- **DO:** Add cleanup hooks that remove test data created during the test suite.
- **DON'T:** Let test data accumulate across test runs.
- **BAD PRACTICE:** Creating test devices, users, and transactions in `beforeAll` but never cleaning them up in `afterAll`. After 50 test runs, the database has 500 stale test records. Tests start failing because "unique constraint violated" on data from a previous run.
- **WHY:** Test isolation — tests must not depend on or be affected by other tests' data.
- **SOURCE:** Industry standard (Test isolation)

### TS-003: Meaningful Assertions Only

- **DO:** Every test must assert real behavior with real data. Use actual results, not hardcoded expected values that match hardcoded inputs.
- **DON'T:** Write tests that compare hardcoded to hardcoded. DON'T mock what should be tested for real.
- **BAD PRACTICE:** Writing `expect(mockDb.save).toHaveBeenCalled()` instead of actually checking the database. The mock says "yes I was called" but the real database throws a constraint error. Also bad: `passWithNoTests: true` in test config — this masks entire packages with zero tests and reports "all tests pass."
- **WHY:** Tests that always pass are worse than no tests — they create false confidence.
- **SOURCE:** Industry standard (Testing best practices)

### TS-004: Delete Dead Test Code

- **DO:** Remove unused test helpers, broken test files, and stale test utilities.
- **DON'T:** Keep dead test code that references removed features.
- **BAD PRACTICE:** Keeping test files that test an old authentication flow (email/password) after migrating to token auth. AI dev agents read these files and think the old pattern is current — they implement the deprecated auth flow because the test code says it's how things work.
- **WHY:** Dead test code confuses developers and AI agents into thinking deprecated patterns are current.
- **SOURCE:** Industry standard (Code hygiene)

---

## Changelog

| Date | Rule ID | Action | Source |
|------|---------|--------|--------|
| {{date}} | All | Initial creation via CQS setup workflow | Project setup |
