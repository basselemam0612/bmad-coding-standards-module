# Technology Research Validation Protocol

> This protocol is mandatory before recommending ANY technology, library, framework, or tool in architecture decisions.
> It exists because AI agents can recommend technologies based on outdated training data, abandoned repos, or poorly researched options. This protocol prevents that.

## When to Apply

- Every time you recommend a specific library, framework, or tool
- Every time you choose between alternatives
- Every time you specify a version number
- Does NOT apply to language choices (TypeScript, Kotlin, etc.) — only to libraries/frameworks/tools

## Mandatory Checks (All Must Pass)

### Check 1: Current Date Awareness

- **BEFORE any research:** Verify the current date. Your training data may be months old.
- **During research:** Only trust data from the current year. If the most recent information you can find is older than 12 months, flag it as potentially outdated and verify via web search.
- **Action:** Use web search or Context7 MCP to verify current state — never rely solely on training data for version numbers, features, or project status.

### Check 2: Maintenance Status

| Signal | Healthy | Warning | Reject |
|--------|---------|---------|--------|
| Last commit | < 3 months | 3-12 months | > 12 months |
| Last release | < 6 months | 6-12 months | > 12 months |
| Open issues response | Maintainer responds | Slow but present | No maintainer activity |
| CI/CD status | Passing | Flaky | Failing or absent |

- **Action:** Check the GitHub/GitLab repo directly. Look at the commit history, release page, and recent issues.
- **If Warning:** Document the risk. Explain why you still recommend it despite the warning signals.
- **If Reject:** Do NOT recommend. Find an alternative.

### Check 3: Community Health

| Signal | How to check |
|--------|-------------|
| npm weekly downloads (JS) | npmjs.com package page or `npm info` |
| GitHub stars trend | Is it growing, stable, or declining? |
| Stack Overflow activity | Are people still asking/answering questions? |
| Known migration away | Are blog posts about "migrating FROM" this tool common? |

- **Action:** A library with declining downloads and "how to migrate away" blog posts is dying regardless of star count.

### Check 4: User Feedback & Known Issues

- **Action:** Read the GitHub issues page. Specifically check:
  - Issues labeled `bug` — are critical bugs acknowledged and being fixed?
  - Issues labeled `breaking` or `migration` — are upcoming breaking changes planned?
  - Pinned issues — are there known limitations the maintainer has highlighted?
  - Recent closed issues — is the maintainer actively closing issues or are they piling up?
- **Look for:** Patterns in complaints. If 10 users report the same problem, that's a real issue even if the maintainer hasn't labeled it.

### Check 5: Alternatives Comparison

- **Action:** For every recommended technology, identify at least 2 alternatives. Document:

| Criteria | Recommended | Alternative A | Alternative B |
|----------|------------|---------------|---------------|
| Name + version | | | |
| License | | | |
| Last release | | | |
| npm downloads/week | | | |
| GitHub stars | | | |
| Bundle size (frontend) | | | |
| Key advantage | | | |
| Key disadvantage | | | |
| Why not chosen | N/A | | |

- **Exception:** If the technology is the only option in its category (e.g., Prisma for type-safe Node ORM with migrations), document why no viable alternatives exist.

### Check 6: Compatibility Verification

- **Action:** Verify the recommended technology works with ALL other chosen technologies in the stack:
  - Check the recommended version's compatibility matrix
  - Look for known conflicts in GitHub issues
  - Verify the version you're recommending is compatible with the runtime version you chose (Node version, JDK version, etc.)
- **Common pitfall:** Recommending a library version that doesn't support the chosen framework version (e.g., library v3 doesn't support React 19 yet).

### Check 7: License Compliance

- **Action:** Verify the license is compatible with the project's use case:
  - Commercial project → Must be MIT, Apache 2.0, BSD, ISC, or similar permissive
  - If AGPL, GPL, SSPL → Flag immediately — these have viral copyleft implications
  - If "free for non-commercial" → Reject for commercial projects
  - If custom/proprietary license → Flag for legal review

## Output Format

When recommending a technology in the architecture document, include a brief validation summary:

```
**[Technology Name] v[X.Y.Z]** — [One-line purpose]
- Verified: [date of verification]
- Maintenance: [Healthy/Warning] — Last release [date], last commit [date]
- Downloads: [X/week on npm] or [equivalent metric]
- License: [License name] — [compatible/needs review]
- Alternatives considered: [Alt A (why not), Alt B (why not)]
```

## Degraded Mode (No Web Access)

If web search and Context7 MCP are unavailable in your environment:

1. **State clearly at the top of the architecture document:** "Technology recommendations in this document are based on AI training data and have NOT been verified against current sources. Independent verification is recommended before committing to any technology choice."
2. For each recommendation, mark as: `Verified: NO — training data only (cutoff: [your training cutoff date])`
3. Prioritize technologies you have HIGH confidence in (widely adopted, established projects) over niche or new libraries
4. Flag any recommendation where you have LOW confidence with: "LOW CONFIDENCE — verify independently"
5. **Never state version numbers as fact** without verification — use "latest stable as of [training cutoff]" instead

The protocol checks still apply in degraded mode — apply what you can (license check from training data, alternatives comparison from knowledge) and clearly mark what you could NOT verify.

## When Verification Fails (With Web Access)

If you CAN access the web but cannot verify a specific technology's current state (repo is private, docs are down, package registry timeout):
1. State clearly: "Unable to verify current state of [technology]"
2. Document what you know and its source (training data, cached docs, etc.)
3. Recommend the user verify independently before committing
4. Suggest an alternative that IS verifiable

**Never present unverified recommendations as confirmed facts.**
