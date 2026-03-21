# Step 1: Detect Context & Determine Mode

## Pre-Check

Check if `{planning_artifacts}/coding-standards.md` already exists.
- If YES: Inform the user. Ask: regenerate (overwrites), update (adds missing sections), or skip. If skip, STOP workflow.
- If NO: Continue.

## Determine Mode

Check if an architecture document exists:
- Search: `{planning_artifacts}/*architecture*.md`

### Mode A: Architecture Exists (Preferred)

If architecture doc found:
1. Load it completely
2. Extract:
   - All technology decisions (frameworks, libraries, tools with versions)
   - Naming conventions
   - Structure patterns
   - DRY rules and enforcement rules
   - Module boundaries
   - Security decisions
   - Cross-cutting concerns
3. The architecture doc is the PRIMARY source for coding standards — not file scanning

Present to user:
```
Architecture document found at: [path]

Extracted tech stack from architecture decisions:
- [Technology 1] — [purpose]
- [Technology 2] — [purpose]
- ...

Sections to generate based on architecture:
[1] Universal Rules (always)
[2] [Platform] Rules (from architecture)
[3] ...
[N] Security Rules (always)
[N+1] Testing Rules (always)

Proceed? [Y/n]
```

### Mode B: No Architecture (Fallback — File Scanning)

If no architecture doc found, fall back to tech stack detection by scanning project files:

| Indicator File | Technology | Section |
|----------------|-----------|---------|
| `package.json` with `react` | React | Frontend Rules |
| `package.json` with `vue` | Vue.js | Frontend Rules |
| `package.json` with `angular` | Angular | Frontend Rules |
| `package.json` with `svelte` | Svelte | Frontend Rules |
| `package.json` with `next` | Next.js | Frontend Rules (SSR) |
| `package.json` with `@nestjs/core` | NestJS | Backend Rules |
| `package.json` with `express` | Express | Backend Rules |
| `package.json` with `fastify` | Fastify | Backend Rules |
| `requirements.txt` or `pyproject.toml` | Python | Backend Rules |
| `Cargo.toml` | Rust | Systems Rules |
| `go.mod` | Go | Systems Rules |
| `build.gradle.kts` or `build.gradle` | Kotlin/Android | Mobile Rules |
| `*.xcodeproj` or `Package.swift` | Swift/iOS | Mobile Rules |
| `pubspec.yaml` | Flutter/Dart | Mobile Rules |
| `prisma/schema.prisma` | Prisma | Database Rules |
| `docker-compose.yml` or `Dockerfile` | Docker | Infrastructure Rules |
| `.github/workflows/` | GitHub Actions | Infrastructure Rules |
| `pnpm-workspace.yaml` or `turbo.json` | Monorepo | Shared Package Rules |

Present detected technologies to user for confirmation before proceeding.

## Also Check For

Regardless of mode, also search for existing code review reports:
- `**/*code-review*.md`
- `**/*review-findings*.md`

If found, these will be used in Step 2 to pre-populate violation-based rules.

Wait for user confirmation, then proceed to Step 2.
