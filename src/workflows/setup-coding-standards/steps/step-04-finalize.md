# Step 4: Finalize & Verify

## Verification Checklist

Verify all components are in place:

- [ ] `coding-standards.md` exists at `{planning_artifacts}/coding-standards.md`
- [ ] Document has Universal Rules section populated
- [ ] Document has platform-specific sections matching detected tech stack
- [ ] Document has Security Rules section populated
- [ ] Document has Testing Rules section populated
- [ ] `bmm-dev.customize.yaml` has coding standards critical_action
- [ ] `bmm-qa.customize.yaml` has coding standards critical_action
- [ ] `bmm-quick-flow-solo-dev.customize.yaml` has coding standards critical_action
- [ ] `bmm-architect.customize.yaml` has coding standards critical_action with WRITE access
- [ ] `dev-story/workflow.yaml` has coding_standards in input_file_patterns
- [ ] `code-review/workflow.yaml` has coding_standards as FIRST input_file_pattern

## Summary

Present completion summary to user:

```
Code Quality Standards Setup Complete

What was created:
- coding-standards.md with [X] rules across [Y] sections

What was updated:
- 4 agent customizations (dev, qa, quick-flow, architect)
- 2 workflow configurations (dev-story, code-review)

How it works:
1. Dev/QA/Quick-Flow agents load coding-standards.md before every task (READ)
2. Architect agent loads and can update it when architecture changes (READ+WRITE)
3. Code review workflow checks compliance AND appends new rules for new violation types (READ+WRITE)
4. The document grows smarter over time — violations caught once become rules that prevent recurrence

Next steps:
- Review the generated coding-standards.md and customize any rules
- Run your first code review to populate project-specific rules from findings
- The system is now self-improving — no manual maintenance needed
```

## Workflow Complete
