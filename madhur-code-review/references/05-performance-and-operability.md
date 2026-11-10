# Lens 5: Performance and operability

Question: what happens at scale, under failure, and at 3 a.m.?

## Performance

- Queries in loops (N+1), full scans where a filter would do, missing pagination, results loaded entirely into memory.
- Work repeated on every iteration that could be done once: creating clients, sessions or connections inside a polling loop, resolving credentials every few seconds.
- Synchronous work that blocks a request path.
- Unbounded growth: caches, queues, logs, retry storms.

## Reliability

- **Timeouts.** Every wait and every network call has a deadline. A `while True` loop that polls a remote job with no deadline will hang forever.
- **Retries.** Retries have limits and back-off, and only repeat operations that are safe to repeat. Throttling and transient errors are handled; permanent errors are not retried.
- **Idempotency.** Running the same step twice should not double the effect.
- **Partial failure.** One bad item should not abort a whole batch silently, and a batch with failures should not report success.
- **Concurrency.** Two writers to one shared resource, read-modify-write races, and operations that run at the same time with no ordering between them.
- **Rollback and teardown.** Deleting or rolling back should not remove things other components still rely on. Check retention and deletion policies.

## Observability

- Failures are logged with enough context to act on (what, which item, which identifier), and without secrets.
- Logs are written to a place that is retained, and the location does not depend on the working directory.
- Logging set up at import time, or configured twice, silently stops working under some runners.
- Metrics and alerts exist for the things that would wake someone up.
- A run summary states counts of passed, failed and skipped items, and the process exit status reflects them.

## Operability

- Configuration comes from the environment or a config file, not edited in code. Switches that can only change by editing source are dead options.
- Hard-coded environment values (account, host, bucket, profile) should be per-environment config.
- The commands in the README actually exist and work as written.
