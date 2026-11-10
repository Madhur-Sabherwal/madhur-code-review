# Lens 2: Security

Question: what can an attacker, or a careless operator, do with this?

## Method: threat model in five minutes

1. **Trust boundaries.** List where untrusted data enters: requests, files, queues, third-party APIs, command-line arguments, environment variables, model output, filenames on shared storage. Trust follows who wrote a value, not which channel delivered it.
2. **Assets.** Credentials, personal data, money movement, admin actions, anything irreversible.
3. **Walk STRIDE** over each boundary: spoofing, tampering, repudiation, information disclosure, denial of service, elevation of privilege.
4. **Abuse cases.** For each feature, ask how it could be misused, and look for the check that stops it.

## Check

- **Secrets.** None in source, config, logs, docs or git history. Tokens that were committed are compromised: rotate first, then clean history.
- **Authentication and authorisation.** Checked on every protected path, per resource (not only "is logged in"). Look for missing ownership checks.
- **Injection.** Queries, shell commands, templates and file paths built from input. Parameterise; never concatenate.
- **Output handling.** Data rendered to HTML, logs or other systems is encoded for that destination.
- **Least privilege.** Permission policies with wildcard actions or wildcard resources, roles that grant themselves more access, standing administrator rights where a one-time grant would do, permissions never revoked on teardown.
- **Destructive operations.** Delete, move or overwrite targets derived from external values: resolve symlinks, require an allowed root, require a minimum depth, and verify ownership before acting.
- **Server-side requests.** A user-influenced URL must be allow-listed, and private and link-local addresses must be blocked.
- **Error messages.** No stack traces, internal paths or identifiers shown to end users.
- **Logging.** No secrets or personal data in logs. Full identity strings (account ids, ARNs) in shared logs are a minor leak.
- **Personal data.** Collected for a stated purpose, classified correctly, retained for a limited time, and deletable.
- **Model and tool output.** If the code calls an AI model, its output is untrusted input: never evaluate it, never place it in a query or shell.
- **Race conditions on shared settings.** Read-modify-write of account-wide or global settings by more than one writer can lose updates.

## Severity hints

A secret in history, a wildcard grant to a standing admin, or an unauthenticated destructive path is Critical. A missing header or a verbose error is usually Optional.
