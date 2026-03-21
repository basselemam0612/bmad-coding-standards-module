# BMad Code Quality Standards (CQS) Module

> **Status: Community Suggestion / RFC** — This module was born from real-world experience building software with BMAD v6 and AI agents. It addresses two gaps discovered during development: (1) AI agents repeatedly violate architecture decisions because rules are buried in large docs, and (2) AI architects can recommend technologies based on outdated or poorly researched data. This is a proposal for community feedback and testing, not a production-ready module.

## The Problems This Solves

### Problem 1: Repeated Violations

AI dev agents read architecture docs but repeatedly violate decisions — hand-building components instead of using chosen libraries, hardcoding values instead of using shared constants, bypassing framework patterns. Code review catches these, but the same violation types recur in every story because there's no feedback loop. Lessons learned in code review don't flow back to the dev agent.

### Problem 2: Poorly Researched Architecture

AI architects can recommend technologies based on outdated training data — abandoned repos, unmaintained libraries, old versions, or tools with known critical issues. These bad decisions get discovered during implementation when it's expensive to change.

## How CQS Addresses These

### Living Coding Standards (Problem 1)

The architect generates a `coding-standards.md` document as a **planning artifact** — right after architecture decisions, not as an afterthought. This document contains concrete DO/DON'T rules derived from the architecture decisions themselves, not vague guidelines.

BMAD agents are then wired to use this document:
- **Dev, QA, Quick-Flow agents** load it before every task (READ)
- **Code Review** checks compliance and **appends new rules** for new violation types (READ+WRITE)
- **Architect** maintains it when architecture changes (READ+WRITE)

The result: violations caught once become rules that prevent recurrence.

### Research Validation Protocol (Problem 2)

A 7-check protocol that the architect must follow before recommending any technology:

1. **Current date awareness** — verify data is current, not from training cutoff
2. **Maintenance status** — last commit, last release, CI status
3. **Community health** — downloads, stars trend, migration signals
4. **User feedback** — GitHub issues, known bugs, maintainer responsiveness
5. **Alternatives comparison** — at least 2 alternatives with trade-offs
6. **Compatibility** — works with all other chosen technologies
7. **License** — compatible with project's use case

Includes a **degraded mode** for environments without web access — recommendations are clearly marked as unverified.

## Installation

```bash
npx bmad-method install --custom-content /path/to/bmad-coding-standards-module/src
```

## Usage

### Preferred Flow (New Projects)
1. Run architecture workflow as normal
2. Architect agent automatically generates `coding-standards.md` as final deliverable (via critical_action)
3. Standards are enforced from the first dev story

### Manual Flow (Existing Projects)
Run: `"set up coding standards"` — the workflow scans for architecture doc, generates standards, and wires up agents.

## Module Structure

```
src/
├── module.yaml                              # Module definition (code: cqs)
├── protocols/
│   └── research-validation-protocol.md      # 7-check tech verification + degraded mode
├── customizations/
│   ├── bmm-architect.customize.patch.yaml   # Research protocol + standards generation
│   ├── bmm-dev.customize.patch.yaml         # Standards enforcement (READ)
│   ├── bmm-qa.customize.patch.yaml          # Standards verification (READ)
│   └── bmm-quick-flow-solo-dev.customize.patch.yaml
└── workflows/
    └── setup-coding-standards/
        ├── workflow.yaml
        ├── templates/
        │   └── coding-standards.template.md # Universal template (any stack)
        └── steps/
            ├── step-01-scan-project.md      # Detect arch doc + tech stack
            ├── step-02-generate-standards.md # Generate from arch + best practices
            ├── step-03-update-agents.md      # Wire up agents + workflows (with rollback safety)
            └── step-04-finalize.md          # Verify everything
```

## Known Limitations

1. **Module format uncertainty** — The module.yaml structure is based on observed patterns from existing BMAD modules (CIS, TEA). The installer may expect additional fields or a different structure. Testing with the actual installer is needed.

2. **Customize.yaml patching is manual** — BMAD does not have a native "patch" mechanism for customize.yaml files. The setup workflow instructs the AI agent to read, merge, and write YAML. This works but is more fragile than a native merge system.

3. **Architecture workflow not modified** — The architect's critical_action instructs coding standards generation, but the core architecture WORKFLOW is not changed. The critical_action fires at agent activation, not at workflow completion. Ideally, the architecture workflow would have a native final step for this. This would require a change to the core BMM architecture workflow.

4. **Research protocol requires web access for full effectiveness** — Without web search or Context7 MCP, the protocol operates in degraded mode where recommendations are marked as unverified. The protocol is still valuable (forces alternatives comparison, license checks, structured thinking) but cannot verify current repo status.

5. **Tested with BMAD v6.0.4** — Compatibility with other versions is untested.

## Origin

This module was conceived by a non-developer product owner who experienced these problems firsthand while building production software with BMAD and AI agents. The violations and research gaps were real — 147 code review findings in one epic, including technologies chosen based on outdated data. Rather than just fixing the immediate project, this module captures the systemic solution as a reusable workflow.

## Contributing

Feedback, issues, and improvements welcome. Key areas where community input would be valuable:
- Module.yaml format validation against the actual BMAD installer
- Additional tech stack detection patterns
- Additional universal rules from community experience
- Testing in different project types (Python, Rust, Go, mobile-only, etc.)
