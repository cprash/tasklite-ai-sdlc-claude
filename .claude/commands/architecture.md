# /architecture

Invoke the architect agent to design the system architecture and produce `architecture.md`.

---

## When to Use

Use `/architecture` after `requirements.md` is approved. Do not run this command if `requirements.md` is still in Draft status.

---

## Preconditions

- `requirements.md` must exist and have Status: Approved
- `docs/technical-profile.md` must exist (for existing stack context)

---

## Steps

1. **Load skill:** Read `.claude/skills/architecture-design/SKILL.md`
2. **Load agent:** Apply the rules from `.claude/agents/architect.md`
3. **Read requirements:** Read `requirements.md`
4. **Read tech profile:** Read `docs/technical-profile.md`
5. **Read existing architecture:** Read `architecture.md` if it exists (for revision context)
6. **Map capabilities:** Map each FR to system capabilities
7. **Define components:** Define each component with name, responsibility, inputs, outputs
8. **Draw diagram:** Produce ASCII architecture diagram
9. **Select technologies:** Choose and justify each technology choice
10. **Address cross-cutting concerns:** Security, scalability, availability, observability, maintainability
11. **List open questions:** Identify items that are "Not Identified"
12. **Draft ADRs:** Create `docs/decisions/ADR-NNN-*.md` for significant choices
13. **Write architecture.md:** Use the template from the skill
14. **Present for review:** Show the draft to the human
15. **Wait for approval:** Do not proceed to `/design-review` until the human approves

---

## Output

- `architecture.md` at the project root
- `docs/decisions/ADR-NNN-*.md` for each significant technology decision

---

## Human Approval

The human must explicitly approve `architecture.md` before the design review begins. Approval is recorded by the human committing the file to Git.

---

## Notes

- Reference FR numbers from `requirements.md` when justifying component design
- Never assume external integration credentials — mark as "Not Identified"
- If a technology choice is hard to reverse, write an ADR for it
