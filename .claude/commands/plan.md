# /plan

Invoke the implementation-planner agent to convert the approved architecture into a dependency-ordered implementation plan (`impl-plan.md`).

---

## When to Use

Use `/plan` after `design-review.md` is approved (or approved with conditions, where conditions are resolved).

---

## Preconditions

- `docs/requirements.md` Status: Approved
- `docs/architecture.md` Status: Approved
- `docs/design-review.md` Status: Approved or Approved with Conditions

---

## Steps

1. **Load agent:** Apply the rules from `.claude/agents/implementation-planner.md`
2. **Read inputs:** Read `docs/requirements.md`, `docs/architecture.md`, `docs/design-review.md`
3. **Inventory components:** List every component from `docs/architecture.md`
4. **Check for blockers:** Identify tasks that depend on unresolved HR items from `docs/design-review.md`
5. **Build dependency graph:** Order tasks by dependencies
6. **Identify parallel groups:** Label tasks that can run in parallel
7. **Write task entries:** Fill in all required fields for each task
8. **Mark blocked tasks:** Include the blocking HR reference and required decision
9. **Write docs/impl-plan.md:** Include summary table, parallel groups, and full task details
10. **Present for review:** Show the plan to the human
11. **Wait for approval:** Do not begin implementation until the human approves

---

## Output

`docs/impl-plan.md`

---

## Human Approval

The human must explicitly approve `docs/impl-plan.md` before any implementation begins. Do not start any TASK-NNN before the plan is approved.

---

## Notes

- Every FR and NFR in `docs/requirements.md` must be traceable to at least one task
- Every component in `docs/architecture.md` must appear in the plan
- Blocked tasks must reference the specific HR item blocking them
- Test tasks must be listed separately from implementation tasks
