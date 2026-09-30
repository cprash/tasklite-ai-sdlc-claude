# Skill: Requirements Analysis

Load this skill before performing any requirements analysis task. It provides the step-by-step process, quality rules, and output template.

---

## When to Use

- When a user story or feature brief is available and a `requirements.md` needs to be produced
- When `requirements.md` needs to be reviewed or updated
- When a human asks about ambiguities or scope for a new feature

---

## Step-by-Step Process

### 1. Read Source Material

- Read `docs/user-story.md` (or the provided user story)
- Note: stated facts, implied assumptions, and missing information
- Do NOT yet write any requirement

### 1.5. Classify Story Type

Before asking questions, identify the story type. Record it in `requirements.md` as a **Story Type** field.

| Type | Criteria |
|------|----------|
| **API** | Server-side logic, REST/GraphQL endpoints, database, auth, background jobs |
| **UI** | React components, user-facing layouts, browser state, routing, accessibility |
| **Full-Stack** | Both API and UI layers are touched |
| **Developer Tooling** | CLI, build scripts, CI/CD pipelines, code generation |

This field is read by the architect, code-reviewer, and test-engineer to select the correct checklists.

### 2. Identify Ambiguities

Formulate a numbered list of clarification questions. Apply the categories that match the story type identified in Step 1.5.

**API question categories:**

| Category | Examples |
|----------|---------|
| Scope | What endpoints are in scope vs out of scope? |
| Data | What request/response shapes are expected? What are the field constraints? |
| State | What is the initial server state? What transitions are valid? |
| Error handling | What HTTP status codes should be returned for each failure mode? |
| Performance | What request volume and latency targets apply? |
| Security | Who can call this endpoint? What data must be protected or masked? |
| Integration | What external services are called? Are credentials available? |

**UI question categories:**

| Category | Examples |
|----------|---------|
| Scope | Which screens / views are in scope? Which are future iterations? |
| Users | Which user roles see this UI? What permissions gate access? |
| Accessibility | What WCAG level is required? Are screen reader and keyboard flows in scope? |
| Responsive | What are the minimum and maximum viewport sizes? Mobile-first or desktop-first? |
| Interaction states | What do loading, empty, error, and success states look like? |
| Navigation | How does the user get to and from this view? Deep-link support required? |
| State management | Is state local (component), global (Zustand/Context), or server (React Query)? |
| Internationalisation | Are multiple locales or text directions required? |
| Browser support | What minimum browser versions are in scope? |

**Developer Tooling question categories:**

| Category | Examples |
|----------|---------|
| Scope | Which operating systems must be supported? |
| Output | What format does the tool produce? Who consumes it? |
| Failure modes | What exit codes should be returned? What is logged on failure? |
| CI/CD | Does this tool run in CI? What environment is assumed? |

Present questions to the human. **Wait for answers before writing requirements.**

### 3. Classify Requirements

After receiving answers, separate requirements into two lists:

**Functional (FR-XXX):** What the system must *do*
- Actions, behaviours, and outputs
- Each FR must be independently testable

For **UI and Full-Stack stories**, additionally use prefixed IDs:
- `UI-FR-XXX` — frontend-only requirement
- `API-FR-XXX` — backend-only requirement
- `FULL-FR-XXX` — spans both layers

**Non-Functional (NFR-XXX):** How the system must *perform*
- Performance, security, reliability, maintainability, observability
- Each NFR must have a measurable acceptance criterion

For **UI stories**, the following NFRs are mandatory unless explicitly waived:
- **Accessibility:** WCAG 2.1 AA
- **Responsive layout:** functional at minimum agreed viewport (default 375 px wide)
- **Core Web Vitals:** LCP < 2.5 s, CLS < 0.1, INP < 200 ms

### 4. Write Acceptance Criteria

For each major requirement, write 1–5 acceptance criteria. Each criterion must be:
- **Observable:** A test or a human reviewer can verify it
- **Unambiguous:** Two developers would agree on pass/fail
- **Scoped:** It tests the requirement, not the entire system

### 5. Record Not Identified Items

Any value you do not have, mark as **"Not Identified"** in a table with a reason column. Never invent:
- API endpoints or URLs
- Environment variable values
- Owner names or team names
- SLA numbers not given in the user story
- Capacity or scale numbers not stated

### 6. Record Assumptions

Any statement you treated as true without explicit confirmation goes in the Assumptions table. Mark confirmed assumptions with `[Confirmed by human: <date>]`.

### 7. Identify Dependencies and Risks

For each external dependency, record:
- What it is
- Whether it is existing or new
- Its current status (available / pending / not identified)

For each risk, estimate likelihood (Low/Medium/High) and impact (Low/Medium/High) and state a mitigation.

---

## Quality Rules

- **Never invent** a requirement not supported by the user story or human answers
- **Confirmed vs proposed:** Use "must" for confirmed requirements; "should" for proposed ones
- **Scope boundary:** If something is out of scope, say so explicitly — do not leave it ambiguous
- **No acceptance criteria, no requirement** — every FR must have at least one AC
- **No NFR without a metric** — "the system should be fast" is not an NFR; "P99 latency < 200 ms" is

---

## requirements.md Template

```markdown
# Requirements — <Feature Name>

**Project:** <project>
**Feature:** <feature>
**Story Type:** API | UI | Full-Stack | Developer Tooling
**Status:** Draft | Approved
**Last Updated:** <YYYY-MM-DD>
**Source:** <docs/user-story.md or other>

---

## 1. Functional Requirements

### FR-001 — <Title>

<One-paragraph description. Use "must" for confirmed requirements.>

**Acceptance Criteria:**
- AC-001-1: <Observable, measurable criterion>
- AC-001-2: <...>

---

### FR-002 — <Title>
...

---

## 2. Non-Functional Requirements

### NFR-001 — <Title>

<Description with measurable target.>

**Acceptance Criteria:**
- AC-NFR-001-1: <...>

---

## 3. Assumptions

| ID | Assumption |
|----|-----------|
| ASM-001 | <Stated assumption> |

---

## 4. Not Identified

| ID | Item | Reason |
|----|------|--------|
| NI-001 | <What is unknown> | <Why it is unknown> |

---

## 5. Dependencies

| ID | Dependency | Type | Status |
|----|-----------|------|--------|
| DEP-001 | <Name> | Runtime / Infrastructure / Service | Existing / Required |

---

## 6. Potential Risks

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|-----------|
| RISK-001 | <Description> | Low/Medium/High | Low/Medium/High | <Mitigation> |
```
