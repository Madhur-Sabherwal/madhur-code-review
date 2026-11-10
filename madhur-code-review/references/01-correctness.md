# Lens 1: Correctness

Question: does the code do what the contract says, on every path?

## Check

- **Matches the contract.** Walk the contract line by line and find the code that fulfils each line. A line with no code is a finding.
- **Boundaries.** Empty input, a single item, the maximum size, zero, negative numbers, off-by-one at range ends, very long strings, Unicode.
- **Null and missing.** Missing keys, null fields, absent files, unset environment variables. Does the code fail loudly or silently continue?
- **Error paths.** What happens when a call fails, times out or returns partial data? Is the error swallowed, logged and ignored, or turned into a wrong result?
- **State and ordering.** Shared state, caches, race conditions, retries that repeat a side effect, operations that must be idempotent but are not.
- **Exit status and signals.** Does a script exit non-zero when it fails? A program that catches every exception and exits 0 reports success when everything failed.
- **Counting and pagination.** Row counts that assume a header row, lists capped at a page size, truncated results treated as complete.
- **Time.** Time zones, daylight saving, clock skew, inclusive versus exclusive ranges, "current" flags that may be zero or many.
- **Types and conversions.** Implicit casts, integer overflow, floating-point comparison, string versus number keys.
- **Dead and misleading code.** Branches that can never run, switches that can only be changed by editing code, names that say one thing and do another.

## Ask of each function

1. What are its inputs, and which of them come from outside the trust boundary?
2. What does it return or change when each step fails?
3. Which assumption, if wrong, makes it quietly return a wrong answer?

## Typical findings

- A validation that cannot fail (it logs a failure and carries on).
- A check that tests a weaker condition than the one described in the docs.
- Loops that wait forever with no deadline.
- A helper that exists, is documented, and is never called.
