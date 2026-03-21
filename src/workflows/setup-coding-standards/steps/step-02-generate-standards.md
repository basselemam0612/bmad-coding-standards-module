# Step 2: Generate Coding Standards Document

## Load Template

Load the coding standards template from `{installed_path}/templates/coding-standards.template.md`.

## Populate Template Variables

- `{{project_name}}` → project name from config
- `{{date}}` → current date

## Generate Platform-Specific Sections

For each technology detected in Step 1, create a new section between the Universal Rules and Security Rules. The number of sections is dynamic — create exactly as many as the project needs.

Section naming convention: `## [Technology/Platform] Rules` with rule ID prefix derived from the technology (e.g., `FE-` for frontend, `BE-` for backend, `MB-` for mobile, `DB-` for database, `IF-` for infrastructure, `SP-` for shared package).

## Generate Rules — Three Sources (In Priority Order)

### Source 1: Architecture Decisions (HIGHEST PRIORITY)

If architecture document was found in Step 1, this is the primary source. For each section of the architecture doc:

- **Technology decisions** → Convert each choice into a "use this, not that" rule. The reason the architect chose it becomes the WHY.
- **Naming conventions** → Convert directly into rules (one rule per convention category).
- **Structure patterns** → Convert directory/module patterns into rules.
- **Enforcement rules / anti-cheat rules** → These are already close to DO/DON'T format — adapt into coding standard rules.
- **Module boundaries** → Convert into rules about what modules can and cannot access.
- **Security decisions** → Convert into SC-xxx rules.

Architecture decisions OVERRIDE any generic best practice. If the architecture says "use X for Y" and the generic best practice says "use Z for Y," the architecture wins.

### Source 2: Industry Best Practices (Fill Gaps)

For each detected technology, use your knowledge of that technology's established best practices to fill gaps NOT covered by the architecture doc. Focus on:

- **Framework-specific patterns** that the framework's official docs recommend
- **Common anti-patterns** that developers frequently create with this technology
- **Security patterns** specific to the technology
- **Performance patterns** that prevent common bottlenecks

Keep the rules actionable and specific. "Write clean code" is not a rule. "Use ConfigService injection, never read process.env directly" IS a rule.

Do NOT exhaustively list every possible best practice — focus on the ones most likely to be violated in AI-assisted development. Typically 5-10 rules per platform section is sufficient.

### Source 3: Pre-Populated Violation Patterns (ARCHITECT'S FORESIGHT)

Based on the chosen tech stack, pre-populate rules for violations that commonly occur with these technologies. The architect knows (from experience and architecture decisions) which shortcuts developers take. Examples:

- If a component library is chosen → rule against hand-building standard components
- If a query/caching library is chosen → rule against raw fetch with manual state
- If a shared package exists → rule against redefining types locally
- If config injection is available → rule against direct env access

If existing code review findings were found in Step 1, extract unique violation patterns and convert them into rules as well.

## Merge and Deduplicate

- Architecture decisions take PRIORITY over generic best practices
- Remove any generated rule that contradicts an architecture decision
- Ensure all rule IDs are unique and sequential within sections
- Only include sections that have at least one rule

## Present Draft

Show the complete document to the user for review:

```
Generated coding standards:
- [X] Universal rules
- [Y] platform-specific rules across [Z] sections
- [W] Security rules
- [V] Testing rules
- [Total] rules total

Review the full document now? [Y/n]
```

Show full content. Wait for approval or modification requests. Iterate until user is satisfied.

## Save

Save to `{planning_artifacts}/coding-standards.md`.

Proceed to Step 3.
