# Lens 3: Tests

Question: would the tests fail if the code were wrong?

## Check

- **Do the tests actually run?** Confirm the runner collects them. A file named `tc01_*.py` is not collected by a runner that looks for `test_*.py`. Run the runner's collect-only mode and read the count. "No tests collected" is a finding even when the exit status looks fine.
- **Do failures fail?** A script that records failures in a list but exits 0 will pass in CI when everything is broken.
- **Do they test behaviour?** Assert on outcomes, not on which internal functions were called.
- **Mutation by hand.** Pick one condition the change adds, invert it (drop a negation, swap AND for OR), run the suite, then restore the file from a copy. If the suite stays green, name the missing test case. Do this only on a scratch copy, never on the branch under review.
- **Edge and error cases.** Boundaries, empty input, failure of a dependency.
- **Bug fixes.** Is there a test that failed before the fix and passes after?
- **Weak assertions.** `does not throw`, `is defined`, counts of resources, snapshot files nobody reads. These pass for wrong code.
- **Over-mocking.** Mocks that replace the very thing being tested. Prefer real code, then fakes, then stubs, then mocks.
- **Isolation and determinism.** Tests that depend on order, the clock, the network or a developer's machine.
- **Suppression.** New skip markers, disabled tests, lowered thresholds, new lint or type suppressions added to reach green.
- **Coverage of the risky part.** The riskiest logic (permissions, data semantics, deletion) should have the most direct tests. If it only appears inside embedded strings or generated code, say it is untested.

## Evidence rule

Run existing tests only where dependencies are already installed. Report the exact command and result. Never report a test as passing that was not run.
