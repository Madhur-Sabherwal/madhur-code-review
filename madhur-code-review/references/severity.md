# Severity labels

Every finding carries one label so the author knows what is required.

| Label | Meaning | Examples |
|---|---|---|
| **Critical** | Blocks merge. Security hole, data loss, broken core function, or a guarantee the change claims but does not deliver. | Standing admin with wildcard resources. A test run that reports green when every check fails. A delete that can remove data it should not. |
| **Required** (no prefix) | Must be fixed or consciously deferred with a reason. | A hang with no timeout. A missing environment entry. A doc command that does not exist. |
| **Optional** | Worth considering, not required. | A cleaner structure. A weak but harmless test assertion. |
| **Nit** | Style or taste. May be ignored. | Naming, ordering, formatting. |
| **FYI** | Context for later. No action. | A related design note. |

## Rules

- Lead with what matters. A few high-conviction findings beat a long list. If there is one structural problem and ten nits, the structural problem is the review.
- Order by leverage: correctness and security, then structural regressions and missed simplifications, then the rest.
- Do not soften a real defect. "Might be a minor concern" is wrong for something that will fail in production.
- Quantify when you can: "adds one session lookup every two seconds per table" beats "could be slow".
- Label each finding **INTRODUCED** (this change causes it) or **PRE-EXISTING** (already on the base). Pre-existing issues do not block the change but are still worth reporting.
- Label each Critical or Required finding **Confirmed** or **Unconfirmed**. See `verification-rules.md`.
