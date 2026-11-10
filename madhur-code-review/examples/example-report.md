# Example report (illustrative)

> This is a **fictional example** showing the shape of a finished report. The project, files and findings are invented for illustration. They do not describe a real codebase.

# Code review report

**Verdict:** request changes
**Target:** `orders-sync @ feature/nightly-export`  |  **Base:** `origin/main`  |  **Depth:** full
**Reviewer mode:** independent pass run
**Date:** 2026-01-15

## Contract

- The nightly job exports yesterday's orders to object storage as one file per day.
- A failed export must be visible: non-zero exit status and an alert.
- The job must not delete or modify existing order data.

## Critical and Required findings

1. **Failures exit with status 0** (`Critical`, INTRODUCED, Confirmed)
   - Where: `jobs/export.py:88-131`
   - What is wrong: each day's export is wrapped in `except Exception`, the error is logged and appended to `failed`, and `main()` returns `None`. The process exits 0 even when every day fails.
   - Failure scenario: the storage credentials expire. All exports fail, the scheduler sees success, and no alert fires. Data is missing for days.
   - Suggested fix: after the loop, exit non-zero when `failed` is not empty, and add a test that asserts the exit status.

2. **Delete step targets a path built from config** (`Critical`, INTRODUCED, Unconfirmed)
   - Where: `jobs/cleanup.py:20-34`
   - What is wrong: the cleanup removes `base_dir / run_label`. `run_label` comes from an environment variable and is not checked to stay under `base_dir`.
   - Failure scenario: `RUN_LABEL=../..` deletes a parent directory.
   - To confirm: run the function against a temporary directory with a hostile label. Not run in this review (would delete files).
   - Suggested fix: resolve the path, require it to be under an allowed root and at least one level below it, then delete.

3. **Test file is never collected** (`Required`, INTRODUCED, Confirmed)
   - Where: `tests/export_checks.py`
   - What is wrong: the runner looks for `test_*.py`. The collect-only run reports "no tests collected".
   - Suggested fix: rename to `test_export_checks.py`.

4. **Retry loop has no limit** (`Required`, PRE-EXISTING, Confirmed)
   - Where: `lib/client.py:41`
   - What is wrong: `while True` polling with a two-second sleep and no deadline.
   - Suggested fix: add a maximum wait and raise a clear error.

## Optional and Nit

- `Optional` A new client is created on every poll: `lib/client.py:38`.
- `Nit` Two log lines print the same banner: `jobs/export.py:12`.

## Areas checked with no findings

- Dependencies: pinned, lock file committed, no new packages.
- Secrets: none found in source or the branch history.

## Evidence of execution

| Check | Command | Result |
|---|---|---|
| Test collection | `python -m pytest --collect-only -q` | 0 tests collected |
| Entry point exists | `ls run_export.py` | not found |
| Config copies identical | `git hash-object config/dev.json config/test.json` | same hash |

## Not covered or not run

- Cleanup behaviour with a hostile label (would delete files).
- A live export (needs credentials).

## Next steps

1. Fix findings 1 and 2, then add tests for both.
2. Rename the test file and re-run collection.
3. Re-review with focus on the cleanup path.
