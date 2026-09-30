# Skill: Code Review

Load this skill before performing a code review. It provides the ten-area checklist, severity definitions, and the review output template.

---

## When to Use

- When implementation is complete and a pull request is being prepared
- When a specific file or module needs independent review
- When the `/review` command is invoked

---

## Severity Definitions

| Severity | Definition | Action |
|---------|-----------|--------|
| **Critical** | Security vulnerability, data loss risk, or incorrect behaviour that breaks a requirement | Must be fixed before PR is merged |
| **Major** | Significant bug, missing error handling, or important coverage gap | Should be fixed before PR; human decides |
| **Minor** | Code quality, naming, style, or mild DRY violation | Consider fixing; not a blocker |
| **Info** | Observation, question, or suggestion with no required action | No action required |

---

## Ten-Area Review Checklist

### Area 1: Correctness

- Does each component behave as specified in `requirements.md`?
- Do the acceptance criteria pass?
- Does the implementation match the component description in `architecture.md`?

**How to verify:** Read each FR's acceptance criteria. Trace the code path that satisfies each one.

---

### Area 2: Security

- Are secrets (API keys, tokens, DB URLs, passwords) absent from all generated output, logs, and responses?
- Is all user input validated with Zod before use?
- Are file paths resolved with `path.resolve()` and validated to be within the project root?
- Is Prisma used for all database access (no raw SQL with user input)?
- Are error messages safe to expose (no stack traces in production responses)?

**How to verify:** Search for `process.env`, `req.body`, `req.query`, `req.params` usage. Check each for validation before use.

---

### Area 3: Error Handling

- Are all `async` functions wrapped in try/catch or use `.catch()`?
- Are errors logged with structured JSON (not `console.error(err)`)?
- Do error responses include only safe, user-facing messages?
- Does the watcher continue after a per-file extraction error?
- Does a write failure log the error and continue with other files?

---

### Area 4: Test Coverage

- Are there unit tests for all exported functions?
- Do tests cover the happy path?
- Do tests cover: invalid input, missing files, empty repos, missing config, API failures, not-found cases?
- Are `tests/fixtures/` files representative?

**How to verify:** Run `npm test -- --coverage` and check the coverage report for `src/docs-sync/`.

---

### Area 5: Code Clarity

- Are function names self-describing verbs (`extractJsDoc`, not `process`)?
- Are variable names descriptive (no single-letter names outside loops)?
- Is any comment present because the code is unclear, not because the logic is complex?
- Are magic numbers replaced with named constants?

---

### Area 6: DRY Principle

- Is any block of logic repeated in more than two files?
- Is there a shared utility function that already does what is being duplicated?
- Are type definitions duplicated when they could be shared from `types.ts`?

---

### Area 7: Dependency Safety

- Are new packages added to `devDependencies` (not `dependencies`) if they are dev-only?
- Are versions pinned with exact (`3.1.2`) or compatible (`^3.1.2`) semver?
- Does `npm audit` report zero high/critical vulnerabilities?

---

### Area 8: Performance

- Is there any loop that reads a file on every iteration instead of once?
- Is the debounce on `FileWatcher` events correctly implemented (500 ms default)?
- Is the TypeScript AST project cache used across multiple file extractions in a single run?

---

### Area 9: Maintainability

- Are new modules exported from the `src/docs-sync/index.ts` barrel file?
- Is TypeScript strict mode preserved (no `any`, no implicit returns, no `@ts-ignore`)?
- Are the module boundaries consistent with `architecture.md`?
- Does `import/no-cycle` ESLint rule pass?

---

### Area 10: Observability

- Is every sync operation logged with the required JSON fields?
- Do logs include `durationMs` for every extraction and write operation?
- Do error logs include the file path and error message (not the stack trace in production)?

---

### Area 11: Frontend / UI

**Activate only when `requirements.md` Story Type is UI or Full-Stack and the diff includes `frontend/src/` files.**

#### Accessibility (WCAG 2.1 AA)

- Do all interactive elements have an accessible name (`aria-label`, `aria-labelledby`, or visible label text)?
- Do non-decorative images have descriptive `alt` text? Do decorative images have `alt=""`?
- Are focus styles visible — `outline: none` without a replacement visible ring is a Critical finding?
- Is keyboard navigation order logical (follows DOM order or uses explicit `tabindex` with clear rationale)?
- Are colour contrast ratios ≥ 4.5:1 for body text and ≥ 3:1 for large text (≥18 pt or 14 pt bold)?
- Are ARIA roles, states, and properties valid and semantically appropriate?

**How to verify:** Use axe-core in a browser or run `npx axe-cli <url>`.

#### React Component Patterns

- Are all component props typed with TypeScript interfaces (no `any` or missing types)?
- Are `key` props stable identifiers — never array indices when the list order can change?
- Are `useEffect` dependency arrays complete? Missing deps are a Major finding.
- Is `dangerouslySetInnerHTML` absent, or — if present — is the value sanitised with DOMPurify?
- Are expensive calculations inside renders wrapped in `useMemo`? Stable callbacks in `useCallback`?

#### CSS / Responsive Layout

- Does the component render without horizontal overflow on a 375 px viewport?
- Are widths in relative units (`rem`, `%`, `vw`, `fr`) rather than fixed `px`?
- Are touch targets at least 44 × 44 px on mobile?
- Is CSS scoped (CSS Modules / styled-components / Tailwind utilities) — no global class overrides?

#### Performance

- Are large or infrequently needed components lazy-loaded with `React.lazy` / `Suspense`?
- Do images specify `width` and `height` attributes to prevent Cumulative Layout Shift (CLS)?

---

## Review Output Template

```markdown
## Code Review — <feature name>

**Reviewer:** Claude (code-reviewer agent)
**Date:** <YYYY-MM-DD>
**Scope:** <files reviewed>
**Areas Not Reviewed:** <list with reason, or "None">

---

### Critical Findings

#### CR-001 — <Title>
**File:** `<path>:<line>`
**Finding:** <specific description of the problem>
**Impact:** <what breaks or is at risk if not fixed>
**Recommendation:** <specific, actionable fix>

---

### Major Findings

#### MR-001 — <Title>
...

---

### Minor Findings

#### MN-001 — <Title>
...

---

### Summary

**Areas reviewed:** Correctness, Security, Error Handling, Test Coverage, Code Clarity, DRY, Dependency Safety, Performance, Maintainability, Observability[, Frontend/UI — if applicable]

**Recommendation:** Approve | Request Changes | Further Review Required

**Reason:** <one paragraph summarising the overall assessment>

**Remaining Risks:** <list of anything that could not be fully verified>
```

---

## Operating Rules

- Every finding must include a file path and line number
- Never report a finding without a recommendation
- Separate confirmed findings from suspicious observations
- The human developer decides which findings are fixed before the PR
- Never claim an area was reviewed if it was not
- Run `npm audit` and include the output in the review if dependencies changed
