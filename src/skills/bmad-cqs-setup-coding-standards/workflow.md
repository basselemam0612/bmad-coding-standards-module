---
context_file: ''
---

# Setup Coding Standards Workflow

**Goal:** Create a living coding standards document for this project, configure BMAD agents to enforce it, and establish a self-improving feedback loop.

**Your Role:** You are setting up the Code Quality Standards (CQS) system. You will scan the project, generate coding standards, update agent configurations, and verify everything works.

**Critical:** Communicate in the configured `communication_language`. This is an interactive workflow — present findings and wait for user approval at each step.

## Step 1: Detect Context & Determine Mode

Check if `coding-standards.md` already exists in the planning artifacts folder.
- If YES: Inform the user. Ask: regenerate (overwrites), update (adds missing sections), or skip.
- If NO: Continue.

Check if an architecture document exists (search for `*architecture*.md` in planning artifacts).

### If Architecture Exists (Preferred Mode)
Load it completely. Extract all technology decisions, naming conventions, structure patterns, DRY rules, module boundaries, security decisions. This is the PRIMARY source for coding standards.

Present to user:
- List all technologies found in architecture
- List sections that will be generated
- Ask if user wants Light Search (quick internet research) or Deep Search (multi-agent thorough research)
- Wait for confirmation

### If No Architecture (Fallback Mode)
Scan project files for tech stack indicators (package.json, build.gradle, requirements.txt, Cargo.toml, etc.). Present detected technologies and ask for confirmation.

## Step 2: Research & Generate Standards

Load the coding standards template from `{project-root}/_bmad/cqs/workflows/setup-coding-standards/templates/coding-standards.template.md`.

### Research (based on user's choice)

**Light Search:** For each technology, do a quick internet search for current best practices and common anti-patterns. Single pass.

**Deep Search:** For primary technologies, launch parallel research:
- Official docs + migration guides
- GitHub issues (recent bugs, known limitations)
- Community feedback (Stack Overflow, discussions)
- Anti-pattern deep dive

Validate findings: single user complaint ≠ fact — cross-reference, check if fixed, find official response. Each search can trigger deeper searches until confident.

### Generate Rules

For each technology, generate rules in this format:
```
### [ID]: [Title]
- **DO:** [specific action]
- **DON'T:** [specific anti-pattern]
- **BAD PRACTICE:** [the exact mistake devs make — what it looks like and what goes wrong]
- **WHY:** [architecture decision or industry standard]
- **SOURCE:** [where this rule came from]
```

Sources in priority order:
1. Architecture decisions (highest priority — always wins)
2. Industry best practices (fill gaps)
3. Pre-populated violation patterns (common mistakes for this stack)

Present the complete draft to the user for review. Iterate until approved. Save to planning artifacts.

## Step 3: Update Agent Configurations & Workflows

Load the customization patches from `{project-root}/_bmad/cqs/customizations/`.

### Update Agent Customize.yaml Files

For each patch file, APPEND (never overwrite) the `critical_actions` and `memories` to the corresponding agent's customize.yaml in `{project-root}/_bmad/_config/agents/`:

- **bmm-architect** — Research validation protocol + coding standards generation + quality gate
- **bmm-dev** — Load coding standards + document issues in Dev Notes
- **bmm-qa** — Load coding standards + verify compliance
- **bmm-quick-flow-solo-dev** — Load coding standards + document issues

### Update Workflow Files

**dev-story/workflow.yaml** — Add `coding_standards` to `input_file_patterns`
**code-review/workflow.yaml** — Add `coding_standards` as FIRST input + check Dev Notes instruction
**retrospective/workflow.yaml** — Add `story_dev_notes` input to load story files from epic
**create-story/workflow.yaml** — Add `previous_retrospective` input for cross-epic learning

### Update Checklists

**dev-story/checklist.md** — Add "Coding standards loaded" + "Issue resolution notes documented"
**code-review/checklist.md** — Add "Coding standards checked" + "Dev Notes reviewed" + "New rules added"
**qa-generate-e2e-tests/checklist.md** — Add "Tests verify coding standards compliance"

### Verify Protocol Files

Confirm these exist at `{project-root}/_bmad/cqs/protocols/`:
- `research-validation-protocol.md`
- `coding-standards-generation-protocol.md`

## Step 4: Verify & Complete

Run through verification checklist:
- [ ] coding-standards.md exists and has content
- [ ] All 4 agent customize.yaml files updated
- [ ] All 4 workflow.yaml files updated
- [ ] All 3 checklists updated
- [ ] Protocol files accessible

Present completion summary to user with what was created, updated, and how the system works going forward.
