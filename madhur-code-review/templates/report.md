# Code review report

**Verdict:** approve | approve with changes | request changes
**Target:** `<repository> @ <branch>`  |  **Base:** `<branch or commit>`  |  **Depth:** quick | standard | full
**Reviewer mode:** independent pass run | single-reviewer
**Date:** YYYY-MM-DD

## Contract

- <what the change must achieve>
- <what it must not break>

## Critical and Required findings

Order by leverage. Label each: INTRODUCED or PRE-EXISTING, and Confirmed or Unconfirmed.

1. **<Title>** (`Critical` | `Required`, INTRODUCED, Confirmed)
   - Where: `path/to/file:line`
   - What is wrong: <one or two sentences>
   - Failure scenario: <concrete inputs or state and the wrong outcome>
   - Suggested fix: <the smallest change that resolves it>

2. ...

## Optional and Nit

- `Optional` <title>: `file:line`, <one line>
- `Nit` <title>: `file:line`, <one line>

## Areas checked with no findings

- <lens or area>: <what was checked>

## Evidence of execution

| Check | Command | Result |
|---|---|---|
| <tests, collect-only, hash comparison, grep, ...> | `<exact command>` | <pass / fail / output summary> |

## Not covered or not run

- <tests that could not run and why, deploy or synth, live services, skipped lenses, unavailable documents>

## Next steps

1. <ordered, concrete>
