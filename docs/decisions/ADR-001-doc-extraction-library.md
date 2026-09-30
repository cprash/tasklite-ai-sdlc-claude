# ADR-001 — TypeScript AST Parsing Library

**Status:** Accepted  
**Date:** 2026-09-30  
**Deciders:** Claude (architect agent) + human review

---

## Context

The Automated Documentation Sync feature requires parsing TypeScript source files to extract:
- Exported function and class signatures
- JSDoc comment blocks with tags (`@param`, `@returns`, `@throws`, `@example`, `@deprecated`)
- Route-level `@openapi` annotation blocks in Express route files

This requires a TypeScript Abstract Syntax Tree (AST) parser that can handle:
- TypeScript-specific syntax (generics, union types, decorators, type aliases)
- JSDoc extraction with tag-level granularity
- Accurate type information (not just string parsing)

Three approaches were considered:
1. **ts-morph** — high-level TypeScript AST API built on top of the TypeScript compiler
2. **@typescript-eslint/parser** — AST parser used by ESLint
3. **Custom regex / string parsing** — pattern-matching on source file text

---

## Decision

Use **ts-morph** version 23.x.

---

## Rationale

### Why ts-morph

- Built directly on the TypeScript compiler API, so it handles all TypeScript syntax correctly by construction
- Provides a high-level, ergonomic API (`project.addSourceFileAtPath()`, `file.getFunctions()`, `func.getJsDocs()`) that reduces boilerplate significantly compared to using the raw TypeScript compiler API
- Handles generics, union types, intersection types, mapped types, and conditional types correctly — these would require complex regex patterns if parsed manually
- Actively maintained; well-documented; used in production by major TypeScript tooling (e.g., ts-poet)
- AST project instance can be created once per run and reused across files, avoiding repeated TypeScript compilation overhead

### Why not @typescript-eslint/parser

- Primarily designed for linting, not for documentation extraction
- Does not provide the same high-level accessor methods as ts-morph
- Type resolution requires additional configuration that ts-morph handles automatically
- Would require more custom code to extract JSDoc tags at the same granularity

### Why not regex / string parsing

- TypeScript syntax is context-dependent — regex cannot reliably parse generic type parameters, nested JSDoc blocks, or multiline function signatures
- Fragile against whitespace variation, comments inside type definitions, and template literal types
- Would require maintaining a custom parser that duplicates work already done by the TypeScript compiler
- High risk of incorrect extraction in edge cases (exactly the scenarios most likely to contain useful documentation)

---

## Consequences

### Positive

- Accurate extraction of all TypeScript type information
- Handles generics, unions, and complex types correctly
- Reduced implementation risk — ts-morph is battle-tested
- Good test story: fixture-based tests are straightforward

### Negative

- `ts-morph` re-exports the TypeScript compiler, so `typescript` and `ts-morph` must be version-compatible. Upgrading TypeScript requires a corresponding `ts-morph` upgrade.
- Adds ~5 MB to `devDependencies` (acceptable for a dev tool)
- First parse of the TypeScript project initialises the TS compiler, which takes ~1–2 seconds on first run; subsequent incremental parses are fast

### Risks

- If `ts-morph` is abandoned or breaks compatibility with a future TypeScript version, we would need to migrate to the raw TypeScript compiler API or another library
- Mitigation: Pin `typescript` and `ts-morph` versions together in `package.json`; include a compatibility note in `CLAUDE.md`

---

## Version Pinning

Pin these two packages to compatible versions in `backend/package.json`:

```json
"devDependencies": {
  "typescript": "5.x",
  "ts-morph": "23.x"
}
```

When upgrading `typescript`, check the [ts-morph compatibility table](https://ts-morph.com/setup/) before upgrading.
