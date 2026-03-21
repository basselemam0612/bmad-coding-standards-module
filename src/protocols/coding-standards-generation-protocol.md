# Coding Standards Generation Protocol

> This protocol is followed by the Architect agent to create the project's coding-standards.md after architecture decisions are complete. It is interactive — the user reviews and approves everything before it's saved.

## When to Follow This Protocol

- After completing the architecture workflow for the first time
- When `{planning_artifacts}/coding-standards.md` does NOT exist
- Do NOT follow this protocol if coding-standards.md already exists — use the quality gate check instead

## Prerequisites

- Architecture document must be complete
- The architect must have access to the architecture decisions (tech stack, naming conventions, patterns, module boundaries, security decisions)

---

## Step 1: Announce and Classify

Read the architecture document completely. Extract every technology decision.

Classify each technology:

**Primary** — Technologies the dev team writes code in daily. These get Deep Search.
Examples: main framework (React, NestJS, Django), ORM (Prisma, SQLAlchemy), UI library (shadcn, MUI), state management, routing.

**Secondary** — Technologies that are configured, not coded in daily. These get Light Search.
Examples: Docker, CI/CD, monitoring tools, reverse proxy, deployment platform.

Present to the user:

```
Architecture analysis complete. Here's what I found:

PRIMARY technologies (Deep Search):
  1. [Technology] v[X.Y] — [purpose from architecture]
  2. [Technology] v[X.Y] — [purpose]
  ...

SECONDARY technologies (Light Search):
  1. [Technology] — [purpose]
  2. [Technology] — [purpose]
  ...

Sections I'll generate:
  - Universal Rules (always)
  - [Platform A] Rules
  - [Platform B] Rules
  - Database Rules
  - Security Rules (always)
  - Testing Rules (always)
  - [other detected sections]

Search mode options:
  - LIGHT: Quick internet research for all technologies (~5 min)
  - DEEP: Multi-agent thorough research for primary, light for secondary (~20+ min)
  - CUSTOM: You tell me which technologies to research deeply

Which mode? Any technologies you want reclassified? Any areas to emphasize?
```

Wait for user choice before proceeding.

---

## Step 2: Research — Light Search

Light Search is a quick, single-pass internet search for each technology.

**For each technology (primary and secondary):**

1. Search for: "[technology] [version] best practices [current year]"
2. Search for: "[technology] common mistakes anti-patterns"
3. Read the top results — official docs preferred, community articles secondary
4. Extract:
   - 3-5 best practices (→ DO rules)
   - 3-5 anti-patterns (→ DON'T + BAD PRACTICE rules)
   - Any version-specific gotchas

**If Light mode was chosen:** Proceed to Step 4 with these results.
**If Deep or Custom mode was chosen:** Continue to Step 3 for the selected technologies.

---

## Step 3: Research — Deep Search (Primary Technologies Only)

Deep Search is a multi-agent, recursive, validated research process. It does NOT trust any single source.

### Phase 1: Parallel Research Launch

For each primary technology, launch parallel research streams:

- **Stream A: Official Documentation**
  - Read official docs, migration guides, changelog for the chosen version
  - Extract recommended patterns and deprecated patterns
  - Note any breaking changes from previous versions

- **Stream B: GitHub Issues & Discussions**
  - Search the technology's GitHub repo for recent issues
  - Filter by: labeled `bug`, high engagement (many reactions/comments), recent (last 6 months)
  - Look for: patterns in complaints — if 10+ users report the same issue, it's real
  - Check pinned issues for known limitations

- **Stream C: Community Intelligence**
  - Search Stack Overflow for common pitfalls with this technology + version
  - Search for "[technology] mistakes to avoid [current year]"
  - Search for "[technology] vs [alternative] [current year]" — learn from comparison articles what the weaknesses are
  - Look at Reddit/Discord/community forums for real user experiences

- **Stream D: Anti-Pattern Deep Dive**
  - Search for "[technology] anti-patterns"
  - Search for "migrating from [bad pattern] to [good pattern] in [technology]"
  - Search for "[technology] code review common findings"
  - These directly become BAD PRACTICE entries

### Phase 2: Validate Findings

For each finding from Phase 1, apply validation rules:

| Finding type | Validation required |
|-------------|-------------------|
| Single user complaint | DO NOT trust. Search for corroboration. If only 1 person says it, might be user error. |
| Multiple users same issue | Likely real. Check if maintainer acknowledged. Check if fixed in newer version. |
| Blog post recommendation | Check the date. Check if the advice is still current. Cross-reference with official docs. |
| Official docs recommendation | Trust but verify version applicability. Docs for v2 might not apply to v3. |
| "This version is broken" claim | Find the specific issue. Check if it was patched. Check the version you're actually recommending. |
| Performance claim | Check the benchmark conditions. "X is slow" often means "X is slow under specific conditions that may not apply." |

### Phase 3: Recursive Deepening

After validation, check if any findings need further research:

- Found a potential critical issue → search specifically for confirmation + resolution
- Found conflicting advice (source A says do X, source B says do Y) → search for which is current consensus
- Found version-specific bug → search if it affects YOUR chosen version specifically
- Found a recommended pattern but no explanation WHY → search for the reasoning

Each deepening search can trigger further searches. Stop when:
- The finding is confirmed or rejected with confidence
- You have at least 2 independent sources agreeing
- Or you've exhausted available sources (note uncertainty)

### Phase 4: Synthesize

For each technology, compile validated findings into:
- Confirmed best practices (→ DO rules)
- Confirmed anti-patterns (→ DON'T rules)
- Specific bad practice descriptions with consequences (→ BAD PRACTICE entries)
- Version-specific warnings (→ notes in WHY field)

Discard:
- Unconfirmed single-source claims
- Outdated advice (applies to old versions)
- Generic advice not specific to this technology

---

## Step 4: Generate Rules from Architecture Decisions

Before adding research findings, extract rules directly from the architecture document:

**For each architecture decision:**
- The choice itself → DO rule (e.g., "Use shadcn Dialog for all modals")
- The rejected alternatives → DON'T rule (e.g., "Don't hand-build modal overlays")
- The reason → WHY field
- Common violation of this decision → BAD PRACTICE

**For naming conventions:** One rule per convention category.

**For structure patterns:** One rule per pattern.

**For module boundaries:** Rules about what modules can and cannot access.

**For enforcement/anti-cheat rules:** Convert to DO/DON'T/BAD PRACTICE format.

**For security decisions:** Convert to SC-xxx rules.

Architecture-derived rules ALWAYS take priority over research-derived rules. If research says "do X" but architecture says "do Y," the architecture wins.

---

## Step 5: Merge All Sources

Combine into the coding standards document using the template:

1. **Universal Rules** — U-001 through U-010 from template (always included) + any architecture-specific universal rules
2. **Platform-specific sections** — One section per detected platform, rules from architecture + research
3. **Database Rules** — If database technology detected
4. **Shared Package Rules** — If monorepo/shared package detected
5. **Infrastructure Rules** — If Docker/CI detected
6. **Security Rules** — Always included, from template + architecture + research
7. **Testing Rules** — Always included, from template + architecture + research
8. **i18n Rules** — If i18n requirements detected
9. **UX Rules** — If UI component library detected

Each rule follows the format:
```
### [ID]: [Title]
- **DO:** [specific action]
- **DON'T:** [specific anti-pattern]
- **BAD PRACTICE:** [the exact mistake devs make, with description of what goes wrong and why]
- **WHY:** [architecture decision reference or industry standard]
- **SOURCE:** [architecture doc section / research source / industry standard]
```

Deduplicate — remove rules that say the same thing differently.
Ensure IDs are unique and sequential within sections.
Remove empty sections.

---

## Step 6: Present Draft to User

```
Coding standards generated:
- [X] Universal rules
- [Y] rules across [Z] platform-specific sections
- [W] Security rules
- [V] Testing rules
- [Total] rules total

Research mode used: [Light/Deep/Custom]
Technologies researched: [list]

Ready to review the full document? [Y/n]
```

Show the complete document.

---

## Step 7: User Review and Iteration

The user reviews the document. They may:
- Approve as-is → proceed to Step 8
- Request changes → apply changes, show updated version, repeat
- Ask for deeper research on specific technology → run Deep Search for that technology, regenerate its section
- Remove rules they disagree with → remove them
- Add rules they know from experience → add them

Iterate until the user is satisfied.

---

## Step 8: Save and Confirm

Save to `{planning_artifacts}/coding-standards.md`.

```
Coding standards saved with [X] rules across [Y] sections.

What happens next:
- Dev/QA agents will load this before every story (READ)
- Code review will check compliance and add new rules for new violations (READ+WRITE)
- You (architect) maintain it when architecture changes (READ+WRITE)
- The document grows smarter over time — self-improving

The first dev story can now begin with full coding standards enforcement.
```
