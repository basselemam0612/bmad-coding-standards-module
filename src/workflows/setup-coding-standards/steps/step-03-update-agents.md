# Step 3: Update Agent Customizations & Workflows

## Load Patches

Load all customization patches from `{installed_path}/../customizations/`:
- `bmm-architect.customize.patch.yaml`
- `bmm-dev.customize.patch.yaml`
- `bmm-qa.customize.patch.yaml`
- `bmm-quick-flow-solo-dev.customize.patch.yaml`

## Safety: Record Pre-Update State

Before making any changes, read and store the current content of ALL files that will be modified. If any update fails, restore all files to their pre-update state. This prevents partial updates that leave the system in an inconsistent state.

## Apply Agent Customization Patches

For each patch file, apply to the corresponding `{project-root}/_bmad/_config/agents/` customize.yaml:

### Process for each agent:

1. Read the current customize.yaml content
2. Read the corresponding patch file
3. **APPEND** patch values to existing values (never overwrite):
   - `critical_actions`: append patch items to existing array
   - `memories`: append patch items to existing array
4. Write the updated file
5. Confirm success

### Agents to update:

**bmm-architect.customize.yaml** — Gets:
- Research validation protocol critical_action
- Coding standards generation critical_action
- Read+Write access memories

**bmm-dev.customize.yaml** — Gets:
- Coding standards loading critical_action
- Issue documentation critical_action (document unexpected issues in story Dev Notes)
- Read-only access memory
- Issue documentation memory (flag reusable patterns for code review)

**bmm-qa.customize.yaml** — Gets:
- Coding standards loading critical_action
- Read-only access memory

**bmm-quick-flow-solo-dev.customize.yaml** — Gets:
- Coding standards loading critical_action
- Issue documentation critical_action (document unexpected issues in spec notes)
- Read-only access memory

## Apply Workflow Updates

### dev-story workflow

Edit `{project-root}/_bmad/bmm/workflows/4-implementation/dev-story/workflow.yaml`:

If `planning_artifacts` variable not present, add:
```yaml
planning_artifacts: "{config_source}:planning_artifacts"
```

If `input_file_patterns` section not present, create it. Add `coding_standards` entry:
```yaml
input_file_patterns:
  coding_standards:
    description: "Project coding standards — MUST be loaded and followed during all implementation work"
    whole: "{planning_artifacts}/*coding-standards*.md"
    load_strategy: "FULL_LOAD"
```

If `input_file_patterns` already exists, append the `coding_standards` entry.

### code-review workflow

Edit `{project-root}/_bmad/bmm/workflows/4-implementation/code-review/workflow.yaml`:

Add `coding_standards` as the FIRST entry in `input_file_patterns`:
```yaml
  coding_standards:
    description: "Project coding standards — MUST be loaded and checked against during review. When a NEW violation pattern is found that is NOT covered by an existing rule, draft a new rule in the correct section following the DO/DON'T/WHY/SOURCE format, assign the next available ID, and add a Changelog entry. ALSO: Check the story file's Dev Notes section — if the dev documented workarounds or technology limitations, (1) verify the resolution was the correct approach, (2) check if the pattern should become a new coding standard rule."
    whole: "{planning_artifacts}/*coding-standards*.md"
    load_strategy: "FULL_LOAD"
```

### retrospective workflow

Edit `{project-root}/_bmad/bmm/workflows/4-implementation/retrospective/workflow.yaml`:

Add `story_dev_notes` as the FIRST entry in `input_file_patterns`:
```yaml
  story_dev_notes:
    description: "All completed story files from this epic. Read each story's Dev Notes section to aggregate implementation issues, technology limitations, workarounds, and process observations. These are primary data for the retrospective — concrete evidence of what went well and what went wrong during implementation."
    whole: "{implementation_artifacts}/{{epic_num}}-*.md"
    load_strategy: "SELECTIVE_LOAD"
```

### create-story workflow

Edit `{project-root}/_bmad/bmm/workflows/4-implementation/create-story/workflow.yaml`:

Add `previous_retrospective` as the FIRST entry in `input_file_patterns`:
```yaml
  previous_retrospective:
    description: "Load ONLY the most recent completed retrospective (highest epic number). Each retro already contains cumulative learnings from all previous retros, so only the latest is needed. Use its process improvements and action items to create better-scoped stories and avoid repeating past mistakes."
    pattern: "{implementation_artifacts}/*retro*.md"
    load_strategy: "SELECTIVE_LOAD"
```

## Patch Workflow Instructions (Critical Enforcement)

These patches ensure the workflow instructions.xml files explicitly enforce coding standards at runtime.
Without these, the workflow.yaml input_file_patterns load the file but the instructions never reference it.

### dev-story instructions.xml

Edit `{project-root}/_bmad/bmm/workflows/4-implementation/dev-story/instructions.xml`:

**In Step 2** (goal: "Load project context"):
1. Change the step goal to: `"Load project context, coding standards, and story information"`
2. Add `<invoke-protocol name="discover_inputs" />` as the FIRST action in the step (this loads coding_standards from workflow.yaml input_file_patterns)
3. Add after the invoke-protocol, BEFORE the existing project_context action:
```xml
    <critical>coding-standards.md is MANDATORY — you MUST follow every rule during implementation</critical>
    <check if="coding_standards content was loaded by discover_inputs">
      <action>Internalize ALL rules from coding-standards.md — every DO/DON'T directive applies to your implementation</action>
      <action>Pay special attention to rules sourced from "Code Review" — these are patterns previous dev agents violated</action>
    </check>
    <check if="coding_standards content was NOT found by discover_inputs">
      <output>⚠️ **WARNING:** coding-standards.md not found. Run /setup-coding-standards or ask the architect to generate it.</output>
      <ask>Proceed without coding standards? (y/n)</ask>
      <action if="user says no">HALT</action>
    </check>
```

**In Step 5** (goal: "Implement task"):
Find the REFACTOR PHASE section and replace `"Ensure code follows architecture patterns and coding standards from Dev Notes"` with:
```xml
    <action>Ensure code follows architecture patterns from Dev Notes</action>
    <critical>Cross-check implementation against EVERY applicable rule in coding-standards.md — violations found by code review become permanent rules, so repeating them is unacceptable</critical>
    <action>Verify: correct components (FE rules), proper validation (BE rules), security patterns (SC rules), testing patterns (TS rules), and all universal rules (U rules)</action>
```

### code-review instructions.xml

Edit `{project-root}/_bmad/bmm/workflows/4-implementation/code-review/instructions.xml`:

**Add a NEW step between the current "Present findings" step and the "Update story status" step.**
Renumber the old final step accordingly. The new step:
```xml
  <step n="5" goal="Update coding-standards.md with new violation patterns">
    <critical>This step closes the feedback loop — violations you find HERE prevent the dev agent from repeating them in FUTURE stories</critical>

    <action>Review all findings from Steps 3-4 and identify violation patterns NOT already covered by an existing rule in coding-standards.md</action>
    <action>Check the story file's Dev Notes section — if the dev documented workarounds or technology limitations:
      1. Verify the resolution was the correct approach
      2. Determine if the pattern should become a new coding standard rule
    </action>

    <check if="new violation patterns found that are NOT covered by existing rules">
      <action>For EACH new pattern, draft a new rule in the correct section of coding-standards.md:
        - Assign next available ID in that section (e.g., if last is FE-012, new is FE-013)
        - Follow the DO/DON'T/WHY/SOURCE format exactly
        - Set SOURCE to "Code Review — Story {{story_key}} ({{date}})"
      </action>
      <action>Add a Changelog entry at the bottom of coding-standards.md:
        "{{date}} — Added [rule IDs] from {{story_key}} code review"
      </action>
      <action>Save coding-standards.md</action>
      <output>📝 **Coding Standards Updated:** Added {{new_rule_count}} new rules to coding-standards.md
        {{list of new rule IDs and one-line descriptions}}
      </output>
    </check>

    <check if="no new violation patterns found">
      <output>✅ All violations already covered by existing coding standards rules</output>
    </check>
  </step>
```

## Update Workflow Checklists

### dev-story checklist

Edit `{project-root}/_bmad/bmm/workflows/4-implementation/dev-story/checklist.md`:

Add to Context & Requirements Validation section:
```
- [ ] **Coding Standards Loaded:** coding-standards.md was loaded and all rules were followed during implementation
```

Add to Documentation & Tracking section:
```
- [ ] **Issue Resolution Notes:** Any unexpected issues encountered are documented in Dev Notes with: Issue summary, Root cause, Resolution (and what failed if applicable)
```

### code-review checklist

Edit `{project-root}/_bmad/bmm/workflows/4-implementation/code-review/checklist.md`:

Add after "Architecture/standards docs loaded":
```
- [ ] Coding standards (coding-standards.md) loaded and checked against implementation
- [ ] Dev Notes section reviewed — workaround resolutions verified as correct approach
- [ ] New violation patterns not in coding-standards.md identified and added as new rules
```

### qa-generate-e2e-tests checklist

Edit `{project-root}/_bmad/bmm/workflows/qa-generate-e2e-tests/checklist.md`:

Add to Test Quality section:
```
- [ ] Tests verify coding standards compliance where applicable (correct components, brand colors, permission gating)
```

## Verify Protocol Files

Verify that the following protocol files exist at their expected locations (they should have been copied during module installation):

- `{project-root}/_bmad/cqs/protocols/research-validation-protocol.md`
- `{project-root}/_bmad/cqs/protocols/coding-standards-generation-protocol.md`

If they do NOT exist (the BMAD installer may not copy all module subfolders), copy them manually:
- Source: `{project-root}/_bmad/cqs/workflows/setup-coding-standards/../../protocols/` (the module's protocols folder)
- Destination: `{project-root}/_bmad/cqs/protocols/`

These files are referenced by the architect's critical_actions and must be accessible at `{project-root}/_bmad/cqs/protocols/`.

## Present Summary

```
Updated Agents:
  bmm-architect    — Research validation protocol + coding standards generation (READ+WRITE)
  bmm-dev          — Coding standards enforcement (READ) + issue documentation in story Dev Notes
  bmm-qa           — Coding standards verification (READ)
  bmm-quick-flow   — Coding standards enforcement (READ) + issue documentation in spec notes

Updated Workflows:
  dev-story        — Loads coding-standards.md before implementation + enforces rules during refactor phase
  code-review      — Loads coding-standards.md + checks Dev Notes + appends new rules + explicit write-back step
  retrospective    — Loads story Dev Notes as primary retro data
  create-story     — Loads previous retrospective for cross-epic learning

Patched Instructions:
  dev-story/instructions.xml    — Added discover_inputs protocol + coding standards enforcement in Steps 2 & 5
  code-review/instructions.xml  — Added new Step 5 for writing violations back to coding-standards.md

Installed Protocols:
  research-validation-protocol.md — Architect tech research checklist

All changes are ADDITIVE — no existing customizations were overwritten.
```

Proceed to Step 4.
