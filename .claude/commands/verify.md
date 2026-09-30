# /verify

Run a comprehensive verification suite covering code, documentation, and security. Produces a verification report.

---

## When to Use

Use `/verify` after code review findings are resolved and before preparing the pull request.

---

## Preconditions

- Code review (`/review`) is complete and human has approved the outcome
- All Critical and agreed-upon Major findings from `/review` are fixed

---

## Steps

### Code Verification

1. **Load skill:** Read `.claude/skills/testing/SKILL.md`
2. **Load agent:** Apply the rules from `.claude/agents/test-engineer.md`
3. Run unit tests:
   ```bash
   cd backend && npm test -- --testPathPattern=unit --coverage
   ```
4. Run integration tests:
   ```bash
   cd backend && npm test -- --testPathPattern=integration
   ```
5. Run TypeScript compiler check:
   ```bash
   cd backend && npx tsc --noEmit
   ```
6. Run ESLint:
   ```bash
   cd backend && npx eslint src/docs-sync/
   cd frontend && npx eslint src/
   ```
7. Run dependency audit:
   ```bash
   cd backend && npm audit --audit-level=high
   ```

### Functional Verification

8. Run the full doc-sync pipeline against the fixture directory:
   ```bash
   cd backend && npm run docs:sync
   ```
9. Verify the output in `docs/api/`:
   - Check each file starts with `<!-- generated:` header
   - Check no secret patterns are present
10. Run drift check:
    ```bash
    cd backend && npm run docs:check
    ```

### Documentation Verification

11. **Load agent:** Apply the rules from `.claude/agents/documentation-reviewer.md`
12. Review all files in `docs/api/` against the documentation review checklist
13. Review `docs/sync-report.md` for completeness

### Security Verification

14. **Load skill:** Read `.claude/skills/security-review/SKILL.md`
15. Run secrets scan:
    ```bash
    bash scripts/scan-secrets.sh
    ```
16. Run all applicable security checks from the skill

---

## Output

A verification report presented to the human. Must include:
- Commands executed (exact commands)
- Test results (pass/fail counts)
- Coverage information
- Any failures with error messages
- Items not executed with reasons
- Known limitations

---

## Rules

- **Never claim verification passed if any required check was not executed**
- Report each unexecuted check explicitly under "Not Executed"
- Failures must include the exact error message and test name
- The human reviews the verification report before proceeding to `/prepare-pr`

---

## After Verification

If any checks fail:
1. Fix the failures agreed with the human
2. Re-run the specific checks that failed
3. Update the verification report

If verification passes:
1. Proceed to `/prepare-pr`
