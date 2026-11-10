# Lens 8: Docs versus code

Question: do the README, decision records and comments describe what the code really does?

## Check

- **Commands work.** Every command in the README exists and runs as written. A documented entry point that is not in the repository is a finding.
- **Examples match behaviour.** Expected output in the docs matches what the code prints.
- **Decision records match the shipped design.** A record that says "no new stack" while the change adds one, or whose values differ from the config, is misleading. Check the record's status (proposed or accepted) against how the code treats it.
- **Open questions shipped as facts.** Placeholder owner names or values that are still marked as open in the decision record but are live in config.
- **Claims versus implementation.** "Updates in place", "idempotent", "one current row per key": confirm the code really does this.
- **Feature lists.** Capabilities ticked in the README that exist only as empty files or stubs.
- **Comments.** A comment that contradicts the code beside it. Comments that only restate the code can be removed.
- **Internal tooling traces.** Folders or text that expose internal or personal tooling names to a wider audience, or files that belong in a private location committed by mistake.
- **Duplication across docs.** The same list in the README, the decision record and the config. They will drift: say which copy is the source of truth.

## Output

Doc errors are usually Required when a reader would follow them to a failure (a command that does not exist) and Optional when they only mislead.
