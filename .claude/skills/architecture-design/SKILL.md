# Skill: Architecture Design

Load this skill before designing or reviewing system architecture. It provides the process, component modelling rules, diagram conventions, and the architecture.md template.

---

## When to Use

- When `requirements.md` is approved and `architecture.md` needs to be produced
- When an existing architecture needs to be extended for a new feature
- When an architecture decision needs to be evaluated

---

## Step-by-Step Process

### 1. Read Inputs

- Read `requirements.md` (must be in Approved status)
- Read `docs/technical-profile.md` for existing tech stack
- Note all "Not Identified" items — these become Open Questions in `architecture.md`

### 2. Map Requirements to Capabilities

For each FR, ask: *what system capability satisfies this requirement?*

Build a capability list. Each capability will map to one or more components.

### 3. Define Components

For each component apply the **Single Responsibility Principle:**

```
Component = one noun, one responsibility, defined inputs, defined outputs
```

For each component, define:
- **Name:** A clear noun (e.g., `DocExtractor`, not `Processor`)
- **Responsibility:** One sentence, starting with a verb
- **Inputs:** Typed (e.g., `filePath: string`)
- **Outputs:** Typed (e.g., `DocData[]`)
- **Dependencies:** Other components or external systems it calls
- **Error behaviour:** What it does when something fails

Avoid:
- God components (one component doing everything)
- Anemic components (a component with one trivial method)
- Circular dependencies between components

### 4. Draw ASCII Architecture Diagram

Use boxes for components, arrows for data flow. Label arrows with the data type flowing along them.

```
┌──────────────┐     ChangeEvent     ┌──────────────┐
│  FileWatcher  │ ──────────────────▶ │  SyncEngine  │
└──────────────┘                     └──────┬───────┘
                                            │ filePath
                                     ┌──────▼───────┐
                                     │ DocExtractor  │
                                     └──────────────┘
```

Rules:
- External systems (file system, database, npm packages) are separate boxes
- Data flows left-to-right or top-to-bottom
- Every arrow is labelled with the data type

### 5. Select Technologies

For each technology choice, document:
1. What alternatives were considered
2. Why the chosen option was selected
3. The version (pinned)
4. A reference to an ADR if the decision is hard to reverse

### 6. Address Cross-Cutting Concerns

Read `requirements.md` **Story Type** before filling this section. Document each applicable concern explicitly — write "Not applicable" only when genuinely so.

**All story types:**

| Concern | Document |
|---------|---------|
| Security | How are secrets handled? Input validation? Auth? |
| Scalability | Where are the bottlenecks? What is the growth strategy? |
| Availability | What are the failure modes? How is recovery handled? |
| Observability | What is logged? What metrics are emitted? |
| Maintainability | Module boundaries, dependency rules, upgrade paths |

**UI and Full-Stack stories — also document:**

| Concern | Document |
|---------|---------|
| Accessibility | ARIA strategy, keyboard navigation, minimum WCAG level |
| Responsive layout | Breakpoint strategy (mobile-first / progressive), minimum viewport |
| Component architecture | Folder structure, shared component library, style co-location |
| Client-side state | Local vs global vs server state; library per layer (e.g. React Query + Zustand) |
| Bundle size | Code-splitting points, lazy-loaded routes, target initial bundle size |
| Content Security Policy | CSP header values; whether inline styles/scripts are permitted |
| Browser support | Minimum browser versions; required polyfills |

### 7. List Open Questions

Any value that is "Not Identified" in `requirements.md` becomes an Open Question. For each:
- State the question
- State who should answer it (owner)
- State whether it is blocking (must be resolved before implementation) or non-blocking

### 8. Write architecture.md

Use the template below.

---

## Architecture.md Template

```markdown
# Architecture — <Feature Name>

**Project:** <project>
**Feature:** <feature>
**Status:** Draft | Approved
**Last Updated:** <YYYY-MM-DD>
**Based on:** requirements.md v<N>

---

## 1. System Overview

<Two-paragraph description of what the system does and how it fits into the larger project.>

---

## 2. Architecture Diagram

\```
<ASCII diagram>
\```

---

## 3. Component Responsibilities

### 3.1 <Component Name> (`src/<path>`)

- **Responsibility:** <one sentence>
- **Inputs:** <typed>
- **Outputs:** <typed>
- **Dependencies:** <list>
- **Error behaviour:** <description>

...

---

## 4. Data Flow

### 4.1 <Primary flow name>

\```
<Step-by-step description or diagram>
\```

---

## 5. Technology Choices

| Technology | Version | Rationale |
|-----------|---------|-----------|
| <name> | <ver> | <why> |

---

## 6. External Integrations

| Integration | Status | Notes |
|------------|--------|-------|
| <name> | In scope / Not Identified / Not in scope | <notes> |

---

## 7. Security Considerations

<Explicitly address: secrets, input validation, auth/authz, network exposure>

---

## 8. Deployment Considerations

<How is it deployed? What infrastructure does it require?>

---

## 9. Scalability and Availability Considerations

<Bottlenecks, failure modes, recovery strategies>

---

## 10. Risks and Trade-offs

| Risk | Trade-off |
|------|----------|
| <risk> | <trade-off> |

---

## 11. Open Questions

| ID | Question | Owner | Status |
|----|---------|-------|--------|
| OQ-001 | <question> | <owner or Not Identified> | Not Identified |
```

---

## Architecture Decision Record (ADR) Template

Create an ADR for any significant, hard-to-reverse technology choice. Save to `docs/decisions/ADR-NNN-<title>.md`.

```markdown
# ADR-NNN — <Title>

**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-NNN

## Context

<What problem were we solving? What constraints existed?>

## Decision

<What did we decide?>

## Rationale

<Why this option? What alternatives were rejected and why?>

## Consequences

**Positive:**
- <benefit>

**Negative:**
- <trade-off or cost>

**Risks:**
- <risk>
```
