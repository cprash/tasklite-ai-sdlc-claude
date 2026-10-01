---
name: evidence-logger
description: Records the test results a human reports into a dated evidence file. It does not run tests — the human runs them against the live app and reports the counts. Used by the Verify agent.
---

# Skill — evidence-logger

**What it does:** records the test results a human reports into a dated
evidence file. It does **not** run tests — the human runs them against
the live app and reports the counts.

**Who uses it:** the Verify agent.

## How it connects
Local filesystem only, through `workspace-writer`. No network, no
credentials.

## Inputs
- `story_id` — `EPMCDMETST-<number>`
- `passed`, `failed`, `skipped` — counts, as reported by the human
- `note` — optional free text (e.g. which tests failed and why)

## Before it runs
- `story_id` must match `EPMCDMETST-<number>`.
- `passed`, `failed`, `skipped` must all be numbers.
- Never invent results — if the human hasn't reported yet, wait (G4).

## Steps
1. Run the checks above.
2. Wait for the human's report: "DONE. X passed, Y failed".
3. Build the filename `run-{{STORY_ID}}-<timestamp>.log`.
4. Write a log with: a header (story id, timestamp, "reported by
   human"), the counts, any note, and an outcome (PASS when failed = 0,
   otherwise FAIL).
5. Save it under `quality.evidence_path` (default `tests/evidence/`) via
   `workspace-writer`.
6. Return the summary.

## What comes back
`{ total, passed, failed, skipped, evidence_file, outcome }`

## When it goes wrong
- Nothing reported yet → "Run the tests locally and tell me the pass/fail
  counts."
- Counts missing or non-numeric → "Report it as: X passed, Y failed."
- `failed` > 0 → record as FAIL (don't block); ask the human whether to
  push on to the PR or fix and re-run first.
