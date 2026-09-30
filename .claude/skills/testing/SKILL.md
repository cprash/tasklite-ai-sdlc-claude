# Skill: Testing

Load this skill before writing or running tests. It provides the test structure, Jest conventions, required edge cases, and the verification report template.

---

## When to Use

- When implementation tasks are complete and tests need to be written
- When running the verification step (`/verify`)
- When a new module needs its test file created

---

## Test Frameworks

Read `requirements.md` **Story Type** to determine which frameworks apply.

**Backend (API and Full-Stack stories):**
Framework: **Jest 29** with **ts-jest**  
Config file: `backend/jest.config.ts`  
Test directory: `backend/tests/`  
Coverage threshold: **80 % line coverage** for all `src/docs-sync/` modules

**Frontend (UI and Full-Stack stories):**
Framework: **Vitest** with **React Testing Library** and `@testing-library/user-event`  
Config file: `frontend/vitest.config.ts`  
Test location: co-located with source (`<Component>.test.tsx`) or in `frontend/src/__tests__/`  
Coverage threshold: **80 % line coverage** for all `frontend/src/` components

**E2E (UI stories, when test environment is available):**
Framework: **Playwright**  
Test directory: `frontend/e2e/`

---

## Directory Structure

```
backend/
├── src/docs-sync/          ← source modules
└── tests/
    ├── unit/               ← unit tests (mocked I/O)
    │   ├── doc-extractor.test.ts
    │   ├── markdown-generator.test.ts
    │   ├── drift-detector.test.ts
    │   └── sync-engine.test.ts
    ├── integration/        ← integration tests (real file system, fixture dir)
    │   └── docs-sync.test.ts
    └── fixtures/           ← representative TypeScript files for testing
        ├── with-jsdoc/
        │   └── sample-module.ts
        ├── without-jsdoc/
        │   └── no-docs.ts
        ├── with-openapi/
        │   └── tasks.routes.ts
        └── malformed/
            └── syntax-error.ts

frontend/
├── src/
│   └── components/
│       └── TaskList/
│           ├── TaskList.tsx
│           └── TaskList.test.tsx    ← co-located component tests
└── e2e/
    └── tasks.spec.ts                ← Playwright E2E tests
```

---

## Frontend Component Test Patterns (UI and Full-Stack stories)

### Setup

```typescript
// frontend/vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test-setup.ts'],
    coverage: { provider: 'v8', lines: 80 },
  },
});
```

```typescript
// frontend/src/test-setup.ts
import '@testing-library/jest-dom';
```

### Render and Query Pattern

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { TaskList } from './TaskList';

describe('TaskList', () => {
  it('renders empty state', () => {
    render(<TaskList tasks={[]} />);
    expect(screen.getByText(/no tasks/i)).toBeInTheDocument();
  });

  it('calls onDelete with the correct id', async () => {
    const onDelete = vi.fn();
    render(<TaskList tasks={[{ id: '1', title: 'Test task' }]} onDelete={onDelete} />);
    await userEvent.click(screen.getByRole('button', { name: /delete test task/i }));
    expect(onDelete).toHaveBeenCalledWith('1');
  });
});
```

### Testing Loading and Error States

```typescript
it('shows a loading spinner while fetching', () => {
  render(<TaskList tasks={[]} isLoading />);
  expect(screen.getByRole('progressbar')).toBeInTheDocument();
});

it('shows an error message when the API fails', () => {
  render(<TaskList tasks={[]} error="Failed to load tasks" />);
  expect(screen.getByRole('alert')).toHaveTextContent('Failed to load tasks');
});
```

### Accessibility Assertion Pattern

```typescript
import { axe, toHaveNoViolations } from 'jest-axe';
expect.extend(toHaveNoViolations);

it('has no accessibility violations', async () => {
  const { container } = render(<TaskList tasks={mockTasks} />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

### E2E Test Pattern (Playwright)

```typescript
// frontend/e2e/tasks.spec.ts
import { test, expect } from '@playwright/test';

test('user can create and view a task', async ({ page }) => {
  await page.goto('/tasks');
  await page.getByRole('button', { name: 'New Task' }).click();
  await page.getByLabel('Title').fill('My Task');
  await page.getByRole('button', { name: 'Save' }).click();
  await expect(page.getByText('My Task')).toBeVisible();
});

test('shows error banner when API returns 500', async ({ page }) => {
  await page.route('**/api/tasks', route => route.fulfill({ status: 500 }));
  await page.goto('/tasks');
  await expect(page.getByRole('alert')).toBeVisible();
});
```

---

## Backend Unit Test Patterns

### Mocking File System

```typescript
import { vol } from 'memfs';
jest.mock('fs', () => require('memfs').fs);

beforeEach(() => vol.reset());
```

### Mocking chokidar

```typescript
jest.mock('chokidar', () => ({
  watch: jest.fn().mockReturnValue({
    on: jest.fn().mockReturnThis(),
    close: jest.fn(),
  }),
}));
```

### Mocking ts-morph

```typescript
jest.mock('ts-morph', () => ({
  Project: jest.fn().mockImplementation(() => ({
    addSourceFileAtPath: jest.fn(),
    getSourceFiles: jest.fn().mockReturnValue([]),
  })),
}));
```

### Pure Function Test Pattern

For modules like `MarkdownGenerator` (pure functions):

```typescript
import { generateMarkdown } from '../../src/docs-sync/markdown-generator';

describe('generateMarkdown', () => {
  it('includes the generated timestamp comment', () => {
    const result = generateMarkdown([]);
    expect(result).toMatch(/<!-- generated: \d{4}-\d{2}-\d{2}/);
  });
});
```

---

## Required Edge Cases

Every module must be tested against these scenarios where applicable:

| ID | Scenario | Description |
|----|----------|-------------|
| EC-001 | Invalid input | Malformed TypeScript, empty file, wrong file extension |
| EC-002 | Missing files | Source file deleted mid-run, doc file missing, fixture not found |
| EC-003 | Empty repository | No `.ts` files in watched dirs, `docs/api/` is empty |
| EC-004 | Missing configuration | No `DOCS_SYNC_*` env vars set; verify defaults are used |
| EC-005 | Extraction failure | ts-morph throws on parse; verify error is logged and processing continues |
| EC-006 | Not Found cases | Source file with zero exports; route file with no `@openapi` block |
| EC-007 | Missing required fields | `DocData` with empty `description`; function with no return type annotation |
| EC-008 | Malformed responses | JSDoc block with unclosed `*/`; `@openapi` block with invalid YAML |

---

## Happy Path Test

Every module must have a test that:
1. Provides valid, representative input
2. Calls the function under test
3. Asserts the expected output matches a snapshot or expected value

---

## Running Tests

```bash
# All unit tests
cd backend && npm test -- --testPathPattern=unit

# All integration tests
cd backend && npm test -- --testPathPattern=integration

# Full suite with coverage
cd backend && npm test -- --coverage

# Single file
cd backend && npm test -- doc-extractor.test.ts
```

---

## Verification Report Template

After running tests, produce this report:

```markdown
## Verification Report

**Date:** <YYYY-MM-DD>
**Trigger:** <manual | CI | /verify command>

---

### Commands Executed

\```bash
<exact commands run, in order>
\```

---

### Test Results

| Suite | Tests | Passed | Failed | Skipped |
|-------|-------|--------|--------|---------|
| unit/doc-extractor | N | N | 0 | 0 |
| unit/markdown-generator | N | N | 0 | 0 |
| unit/drift-detector | N | N | 0 | 0 |
| unit/sync-engine | N | N | 0 | 0 |
| integration/docs-sync | N | N | 0 | 0 |
| frontend/TaskList | N | N | 0 | 0 |
| frontend/... | N | N | 0 | 0 |
| e2e/tasks | N | N | 0 | 0 |

*(Omit frontend and E2E rows when Story Type is API or Developer Tooling)*

---

### Coverage

| File | Line % | Branch % | Function % |
|------|--------|---------|-----------|
| src/docs-sync/doc-extractor.ts | N% | N% | N% |
| src/docs-sync/markdown-generator.ts | N% | N% | N% |
| ... | | | |

**Coverage threshold (80 % lines): PASS | FAIL**

---

### Failures

<None | List each failed test with: test name, error message, file:line>

---

### Not Executed

<None | List each required test/check that was not run, with reason>

---

### Known Limitations

<List any scenarios not covered by the current test suite>
```

---

## Operating Rules

- **Never claim tests passed if not executed** — use "Not Executed" with the reason
- Coverage numbers must come from the Jest coverage report, not estimates
- Do not modify source code to make tests pass without informing the human
- Report each failed test with its exact error message
- List any edge cases that could not be tested in "Known Limitations"
