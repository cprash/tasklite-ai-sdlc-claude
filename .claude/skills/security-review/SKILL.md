# Skill: Security Review

Load this skill before performing a security review. It provides the checklist, evidence-gathering commands, and the security review output template.

---

## When to Use

- When the `/verify` command is run
- When a PR is being prepared and a security sign-off is required
- When a new dependency is added
- When code handles user input, file paths, or external data

---

## Security Review Checklist

### 1. Secrets and Credentials

**What to check:**
- No API keys, tokens, passwords, database connection strings with credentials in:
  - Source code (`.ts`, `.tsx`)
  - Generated documentation (`docs/api/*.md`)
  - Log output
  - Test fixtures
  - `.env.example` (should contain only placeholder values)

**Evidence command:**
```bash
bash scripts/scan-secrets.sh
```

**Patterns to search manually if scan-secrets.sh is not yet available:**
```bash
grep -rn "password\s*=" --include="*.ts" backend/src/
grep -rn "api_key\s*=" --include="*.ts" backend/src/
grep -rn "AKIA[0-9A-Z]" --include="*.ts" backend/src/
```

---

### 2. Input Validation

**What to check:**
- All Express route handlers validate `req.body`, `req.query`, and `req.params` with Zod before use
- File paths provided via environment variables or API inputs are resolved with `path.resolve()` and verified to be within the project root
- No direct use of user input in file system operations without sanitisation

**Evidence command:**
```bash
grep -rn "req\.body\|req\.query\|req\.params" backend/src/ --include="*.ts"
# Verify each result is preceded by Zod validation
```

---

### 3. Authentication and Authorisation

**What to check (current scope):**
- The doc-sync CLI is a developer tool — no auth required in the current scope
- The Express API (`backend/src/routes/`) uses no authentication in the current scope — mark as "Not Identified" if auth is planned but not implemented

**Note:** If auth is added in future, check:
- JWT is validated on every protected route
- Auth middleware is applied before route handlers
- No auth bypass via unchecked headers

---

### 4. Dependency Vulnerabilities

**Evidence command:**
```bash
cd backend && npm audit --audit-level=high
cd frontend && npm audit --audit-level=high
```

**What to check:**
- Zero High or Critical vulnerabilities in both `backend` and `frontend`
- Any Moderate vulnerabilities have a noted mitigation or accepted risk

---

### 5. SQL Injection via Prisma

**What to check:**
- No `$queryRaw` or `$executeRaw` calls with string interpolation
- All database queries use Prisma's typed query builder

**Evidence command:**
```bash
grep -rn "\$queryRaw\|\$executeRaw" backend/src/ --include="*.ts"
```

---

### 6. Path Traversal

**What to check:**
- File paths from environment variables or user input are normalised with `path.resolve()`
- Resolved paths are validated to be within the project root before any file operation
- No `..` sequences can escape the watched directories

**Pattern to verify:**
```typescript
// Good
const resolvedPath = path.resolve(basePath, inputPath);
if (!resolvedPath.startsWith(path.resolve(projectRoot))) {
  throw new Error('Path outside project root');
}
```

---

### 7. Generated Documentation Security

**What to check:**
- `SyncWriter` runs secret-detection patterns before writing any file
- Generated `docs/api/*.md` files are scanned by `scripts/scan-secrets.sh` in CI
- No environment variable **values** appear in generated docs (names are OK)

---

### 8. CORS Configuration (Frontend / API)

**What to check:**
- Express CORS middleware restricts allowed origins in production
- `Access-Control-Allow-Origin: *` is not set in production

**Evidence command:**
```bash
grep -rn "cors\|CORS\|origin" backend/src/ --include="*.ts"
```

---

### 8a. Frontend Security (apply when Story Type is UI or Full-Stack)

**What to check:**

**XSS prevention:**
- `dangerouslySetInnerHTML` is absent in all `.tsx` files, or every instance is sanitised with DOMPurify before use
- User-controlled data is never injected into `href`, `src`, or `style` attributes via string concatenation

**Evidence command:**
```bash
grep -rn "dangerouslySetInnerHTML" frontend/src/ --include="*.tsx"
grep -rn "javascript:" frontend/src/ --include="*.tsx"
```

**Content Security Policy:**
- The Vite dev server and production build configure a `Content-Security-Policy` response header
- `unsafe-inline` and `unsafe-eval` script sources are absent in production CSP
- Inline `<script>` tags and `eval()` calls in `.tsx` / `.ts` files are absent

**Evidence command:**
```bash
grep -rn "unsafe-inline\|unsafe-eval" frontend/ --include="*.ts" --include="*.tsx" --include="*.html"
grep -rn "eval(" frontend/src/ --include="*.ts" --include="*.tsx"
```

**Third-party scripts:**
- Any third-party script loaded in `index.html` has a Subresource Integrity (SRI) `integrity` attribute
- No CDN scripts are loaded without an explicit `integrity` and `crossorigin` attribute

**Client-side input validation:**
- Client-side validation is present on all user-input forms (prevents obvious user errors)
- Note: client-side validation must NOT be the only validation — server-side validation in the API is required

---

### 9. Error Message Safety

**What to check:**
- API error responses do not expose stack traces in production
- Error responses contain only user-safe messages
- The global error handler in `backend/src/middleware/errorHandler.ts` filters stack traces

---

### 10. Environment Variable Handling

**What to check:**
- `.env` is listed in `.gitignore`
- `.env.example` contains only placeholder values (no real secrets)
- `process.env` access is centralised (not scattered across modules)
- Default values are safe (not open, not privileged)

---

## Security Review Output Template

```markdown
## Security Review — <feature name>

**Reviewer:** Claude (security-review skill)
**Date:** <YYYY-MM-DD>
**Scope:** <files and areas reviewed>

---

### 1. Secrets Scan

**Command:** `bash scripts/scan-secrets.sh`
**Result:** PASS | FAIL | Not Executed
**Details:** <findings or "No secrets detected">

### 2. Input Validation

**Result:** PASS | FAIL | Partial
**Details:** <findings>

### 3. Authentication / Authorisation

**Result:** N/A (current scope) | PASS | FAIL
**Details:** <findings or "Not in scope">

### 4. Dependency Vulnerabilities

**Command:** `npm audit --audit-level=high`
**Result:** PASS | FAIL | Not Executed
**Findings:** <list High/Critical CVEs or "None">

### 5. SQL Injection (Prisma)

**Result:** PASS | Not Applicable
**Details:** <findings>

### 6. Path Traversal

**Result:** PASS | FAIL
**Details:** <findings>

### 7. Generated Documentation

**Result:** PASS | FAIL
**Details:** <findings>

### 8. CORS

**Result:** PASS | Not Applicable
**Details:** <findings>

### 8a. Frontend Security (UI / Full-Stack stories only)

**Result:** PASS | FAIL | Not Applicable
**XSS / dangerouslySetInnerHTML:** <findings>
**Content Security Policy:** <findings>
**Third-party scripts:** <findings>
**Client-side validation:** <findings>

### 9. Error Message Safety

**Result:** PASS | FAIL
**Details:** <findings>

### 10. Environment Variables

**Result:** PASS | FAIL
**Details:** <findings>

---

### Summary

**Overall Result:** PASS | FAIL | PASS WITH CONDITIONS

**Conditions / Remaining Risks:**
<list>

**Not Reviewed:**
<list areas not covered with reason>
```

---

## Operating Rules

- Run every applicable check and report the result honestly
- **Never claim a check passed if it was not executed** — report "Not Executed"
- Do not log or output matched secret values — report only file:line locations
- Security findings must reference a specific file and line
- Dependency vulnerabilities must reference the CVE identifier
