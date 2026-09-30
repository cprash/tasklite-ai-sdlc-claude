# /requirements

Invoke the requirements-analyst agent to analyse the user story and produce `requirements.md`.

---

## When to Use

Use `/requirements` when starting a new feature or when the user story has been updated and `requirements.md` needs to be regenerated or revised.

---

## Steps

1. **Load skill:** Read `.claude/skills/requirements-analysis/SKILL.md`
2. **Load agent:** Apply the rules from `.claude/agents/requirements-analyst.md`
3. **Read source:** Read `docs/user-story.md`
4. **Read existing:** Read `docs/requirements.md` if it exists (for revision context)
5. **Identify ambiguities:** Formulate clarification questions
6. **Present questions:** Show questions to the human and wait for answers
7. **Draft requirements:** Write the full `docs/requirements.md` using the template from the skill
8. **Present for review:** Show the draft to the human
9. **Wait for approval:** Do not proceed to `/architecture` until the human approves

---

## Output

`docs/requirements.md`

---

## Human Approval

The human must explicitly approve `docs/requirements.md` before it is treated as the source of truth for architecture and implementation. Approval is recorded by the human committing the file to Git.

---

## Notes

- If `docs/user-story.md` does not exist, ask the human to provide the user story
- If the human provides clarification answers that reveal new requirements, update the draft before presenting for approval
- Mark all unavailable values as "Not Identified" — never invent them
