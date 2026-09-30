# /review

Invoke the code-reviewer agent to perform a structured peer review of the implementation.

---

## When to Use

Use `/review` when implementation is complete and before creating a pull request. Can also be used mid-implementation to review a specific file or module.

---

## Preconditions

- Implementation tasks in `impl-plan.md` must be marked "Complete" (or "In Progress" for partial review)
- All tests must have been run and results available

---

## Steps

1. **Load skill:** Read `.claude/skills/code-review/SKILL.md`
2. **Load agent:** Apply the rules from `.claude/agents/code-reviewer.md`
3. **Identify scope:** Run `git diff main` to see all changed files
4. **Read reference docs:** Read `requirements.md`, `architecture.md`, `design-review.md`
5. **Apply ten-area checklist:** Review each changed file against all ten areas
6. **Classify findings:** Critical / Major / Minor / Info with file:line references
7. **Check test coverage:** Verify coverage meets 80 % threshold for `src/docs-sync/`
8. **Run dependency audit:** Run `npm audit` in `backend/` and include results
9. **Write review output:** Use the code review output template from the skill
10. **Present findings:** Show all findings to the human
11. **Wait for human decision:** The human decides which findings are fixed before the PR

---

## Output

A structured code review report presented to the human in the conversation. Not a file — the human decides what to record.

---

## Human Decision Required

The human decides:
- Which Critical findings must be fixed before the PR
- Which Major findings are fixed vs accepted with documented risk
- Which Minor findings are fixed vs deferred

---

## After Review

If findings require fixes:
1. Apply the fixes agreed with the human
2. Re-run tests
3. Re-run `/review` on the fixed files (abbreviated — only re-check changed items)
4. Proceed to `/verify` once the human approves the review outcome

---

## Notes

- The reviewer must not have been the same agent that implemented the code
- Every finding must reference a specific file and line
- Never claim an area was reviewed if it was not — list unreviewed areas
