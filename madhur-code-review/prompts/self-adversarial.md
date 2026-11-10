# Self-adversarial pass (when no second reviewer is available)

Use this only when you cannot start a separate reviewer. It is weaker, because you carry your own earlier reasoning with you. Mark the final report "single-reviewer".

## How to run it

1. Finish your first pass and save the findings aside.
2. Re-read the **contract** and the **code** as if seeing them for the first time. Do not re-read your notes.
3. Ask each question below and write a one-line answer for each.

## Questions

1. Which single assumption, if false, makes this change wrong?
2. What input or state did I not try? (empty, huge, missing, duplicated, out of order, from another environment)
3. What happens when each external call fails or hangs?
4. What does the change do the second time it runs?
5. What can a careless operator do with it? What could a malicious one do?
6. Which test would still pass if the code were wrong?
7. What does the documentation promise that the code does not do?
8. What is different between environments that I assumed was the same?
9. What did I accept because it looked familiar?
10. If a colleague had written this, what would I challenge?

## Output

Add any new item to the findings, then verify it using `references/verification-rules.md`. Record in the report that this was a single-reviewer review.
