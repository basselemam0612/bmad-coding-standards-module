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
    description: "Most recent completed retrospective. Contains process improvements, lessons learned, and action items from the previous epic. Use these insights to create better-scoped stories with clearer acceptance criteria and to avoid repeating past mistakes."
    pattern: "{implementation_artifacts}/*retro*.md"
    load_strategy: "SELECTIVE_LOAD"
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

## Copy Research Validation Protocol

Copy `{installed_path}/../protocols/research-validation-protocol.md` to `{project-root}/_bmad/cqs/protocols/research-validation-protocol.md`.

This makes the protocol available at the path referenced in the architect's critical_action.

## Present Summary

```
Updated Agents:
  bmm-architect    — Research validation protocol + coding standards generation (READ+WRITE)
  bmm-dev          — Coding standards enforcement (READ) + issue documentation in story Dev Notes
  bmm-qa           — Coding standards verification (READ)
  bmm-quick-flow   — Coding standards enforcement (READ) + issue documentation in spec notes

Updated Workflows:
  dev-story        — Loads coding-standards.md before implementation
  code-review      — Loads coding-standards.md + checks Dev Notes + appends new rules
  retrospective    — Loads story Dev Notes as primary retro data
  create-story     — Loads previous retrospective for cross-epic learning

Installed Protocols:
  research-validation-protocol.md — Architect tech research checklist

All changes are ADDITIVE — no existing customizations were overwritten.
```

Proceed to Step 4.
