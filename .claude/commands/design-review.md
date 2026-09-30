# /design-review

Invoke the design-reviewer agent to conduct a structured review of `architecture.md` and produce `design-review.md`.

---

## When to Use

Use `/design-review` after `architecture.md` is approved. This is a mandatory step before implementation planning begins.

---

## Preconditions

- `architecture.md` must exist and have Status: Approved
- `requirements.md` must exist and have Status: Approved

---

## Steps

1. **Load agent:** Apply the rules from `.claude/agents/design-reviewer.md`
2. **Read architecture:** Read `architecture.md`
3. **Read requirements:** Read `requirements.md`
4. **Requirements coverage check:** Verify every FR and NFR is addressed by at least one component
5. **Component review:** Review each component for single responsibility and error handling
6. **Data flow review:** Trace each data flow for security and correctness
7. **Technology review:** Evaluate technology choices against requirements
8. **Open questions review:** Classify each open question as blocking or non-blocking
9. **Classify findings:** Confirmed Issues / Potential Risks / Recommendations / Decisions Requiring Human Approval
10. **Write design-review.md:** Include all findings and decisions
11. **Present findings:** Show confirmed issues and decisions requiring human approval to the human
12. **Discuss findings:** Allow the human to accept, reject, or defer each finding
13. **Update architecture.md:** Apply approved changes from the review
14. **Record decisions:** Write ADRs for decisions made during the review

---

## Output

- `design-review.md` at the project root
- Updated `architecture.md` (if changes approved)
- `docs/decisions/ADR-NNN-*.md` for decisions made during the review

---

## Decisions Requiring Human Approval

Any "Decisions Requiring Human Approval" (HR-XXX) in `design-review.md` must be resolved before implementation of the affected tasks begins. Do not mark affected tasks as "Not Started" — mark them as "Blocked" in `impl-plan.md`.

---

## Notes

- Separate confirmed issues from potential risks from recommendations
- Every confirmed issue must have a recommendation
- Do not block implementation for potential risks that have mitigations
- The review outcome must explicitly state: Approved / Approved with Conditions / Not Approved
