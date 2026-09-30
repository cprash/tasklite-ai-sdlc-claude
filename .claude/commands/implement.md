# /implement

Work through `impl-plan.md` in dependency order, implementing one task at a time.

---

## When to Use

Use `/implement` after `impl-plan.md` is approved. Optionally pass a task ID: `/implement TASK-004`.

---

## Preconditions

- `impl-plan.md` must exist and have been approved by the human
- No unresolved Critical issues in `design-review.md`
- Blocked tasks must not be started until their blocking HR item is resolved

---

## Steps

### Before Starting a Task

1. Read `impl-plan.md` and identify the next task(s) with Status: Not Started and no unmet dependencies
2. Verify no blocking items (HR-XXX) apply to this task
3. Read the source files listed in the task's "Files Affected"
4. Read the relevant skill if the task involves a specific concern (documentation-sync, testing, security)

### During Implementation

5. Implement one logical task at a time — do not start the next task before completing the current one
6. Make small, reviewable changes
7. Create or update tests alongside the implementation (not after)
8. Follow all coding conventions from `CLAUDE.md`
9. Run the formatter and linter after each file edit:
   ```bash
   cd backend && npx eslint src/docs-sync/<file>.ts --fix
   ```
10. Run the TypeScript compiler check:
    ```bash
    cd backend && npx tsc --noEmit
    ```

### When Ambiguity Arises

11. If the implementation reveals an ambiguity or conflict with `architecture.md` or `requirements.md`:
    - Stop implementation
    - Describe the ambiguity clearly
    - Present options to the human
    - Wait for a decision before proceeding

### After Each Task

12. Run the relevant tests for the completed module
13. Update the task Status to "In Progress" or "Complete" in `impl-plan.md`
14. Stage the changed files and show the diff to the human for review
15. **Wait for human approval before committing**

---

## Human Approval Required

- Human must review the diff after each task before it is committed
- Claude must never run `git commit` without explicit human approval
- Significant architectural changes discovered during implementation require human review before proceeding

---

## Notes

- Do not implement features not listed in `impl-plan.md`
- Do not introduce new dependencies without updating `impl-plan.md` and getting human approval
- Do not skip tests — if a test cannot be written, document why in the task entry
- If `impl-plan.md` is out of date, update it before proceeding
