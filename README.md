# BMad Code Quality Standards (CQS) Module

> **Important Note:** This module is an experiment — something I'm actively testing on my own project. I am not a software engineer; I use AI to build apps. I cannot say this is 100% complete or that it fully solves the problem. It mitigates repeated AI violations significantly in my experience, but it's still a work in progress.
>
> I shared it because maybe it helps someone, or maybe actual developers working on BMAD can take the idea further and make it better. If you think it can be enhanced, or even if you think it's not a good approach at all — I'm genuinely happy to hear either way. Open to all feedback.

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

The goal: violations caught once become rules that help mitigate recurrence. It doesn't eliminate the problem entirely, but significantly reduces repeated violations in practice.

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

### Step 1: One-Time Setup (MANDATORY after install)

After install, simply tell your AI agent:

```
"set up coding standards"
```

The agent finds the CQS workflow automatically and runs it. As part of the setup, it registers itself as a slash command for future use.

This does four things:
1. Scans your project for architecture doc and tech stack
2. Generates `coding-standards.md` with rules (interactive — you review and approve)
3. Updates agent customize.yaml files so dev/QA/architect agents load the standards
4. Updates workflow configs so code-review, retrospective, and create-story use the standards

**Why is this mandatory?** BMAD currently has no post-install hook mechanism. The module installs its files, but agents don't know about the coding standards until the setup workflow configures them. After this one-time setup, everything is automatic.

### Step 2: From Here, Everything is Automatic

After setup, the system works without intervention:
- Architect generates/maintains coding standards as part of architecture work
- Dev/QA agents load standards before every task
- Code review checks compliance and grows the standards
- Retrospective aggregates process learnings
- Create-story loads previous retro for cross-epic learning

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

1. **One-time setup required** — BMAD has no post-install hook mechanism, so the setup workflow must be run manually after installation. The BMAD maintainers could potentially add post-install hooks to make this automatic in the future.

2. **Module folder copying uncertainty** — The BMAD installer may not copy all module subfolders (protocols/, customizations/). If the setup workflow can't find the patch files or protocols, they may need to be manually verified. The setup workflow checks for this and provides guidance.

3. **Customize.yaml patching is manual** — BMAD does not have a native "patch" mechanism for customize.yaml files. The setup workflow instructs the AI agent to read, merge, and write YAML. This works but is more fragile than a native merge system.

4. **Architecture workflow not modified** — The architect's critical_action instructs coding standards generation, but the core architecture WORKFLOW is not changed. Ideally, the architecture workflow would have a native final step for generating coding standards. This would require a change to the core BMM module.

5. **Research protocols require web access for full effectiveness** — Without web search or Context7 MCP, protocols operate in degraded mode where recommendations are marked as unverified. Still valuable for structured thinking, but cannot verify current technology status.

6. **Tested with BMAD v6.2.0** — Compatibility with other versions is untested.

## Suggestions for BMAD Core

If the BMAD maintainers find this module valuable, these core changes would improve integration:

1. **Post-install hooks** — Allow modules to declare a setup workflow that runs automatically after installation
2. **Customize.yaml merge mechanism** — Allow modules to declare patches that get merged into existing agent customize.yaml files during install
3. **Architecture workflow final step** — Add an optional final step to the architecture workflow for generating companion documents (like coding standards)

## Origin

This module was conceived by a non-developer product owner who experienced these problems firsthand while building production software with BMAD and AI agents. The violations and research gaps were real — 147 code review findings in one epic, including technologies chosen based on outdated data. Rather than just fixing the immediate project, this module captures the systemic solution as a reusable workflow.

## Contributing

Feedback, issues, and improvements welcome. Key areas where community input would be valuable:
- Module.yaml format validation against the actual BMAD installer
- Additional tech stack detection patterns
- Additional universal rules from community experience
- Testing in different project types (Python, Rust, Go, mobile-only, etc.)
