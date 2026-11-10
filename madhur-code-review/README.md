# madhur-code-review

A complete, tool-agnostic **code review skill** for AI coding assistants, by Madhur Sabherwal.

Drop this folder into your assistant and ask for a code review. It scopes the work, reads the intent, applies eight review lenses, runs an independent adversarial pass, verifies every serious finding against the code, and returns one ranked report. It is plain Markdown plus two small read-only scripts, so any assistant that can read files and run shell commands can follow it.

- **Review only.** It does not edit your code, deploy, or touch cloud accounts unless you ask.
- **Evidence first.** Critical and Required findings must be confirmed in the code, or marked unconfirmed.
- **Honest.** The report states what was run, what was not, and why.
- **Self-contained.** One folder holds everything: workflow, checklists, prompts, template, scripts and an example.

## Contents

```
madhur-code-review/
├── SKILL.md                      The skill: the full workflow (start here)
├── AGENTS.md                     Short pointer for assistants that read AGENTS.md
├── README.md                     This file
├── LICENSE                       MIT
├── references/
│   ├── 01-correctness.md
│   ├── 02-security.md
│   ├── 03-tests.md
│   ├── 04-design-and-simplicity.md
│   ├── 05-performance-and-operability.md
│   ├── 06-infrastructure-and-data-pipelines.md
│   ├── 07-dependencies.md
│   ├── 08-docs-vs-code.md
│   ├── severity.md               Severity labels and ordering rules
│   └── verification-rules.md     How to verify findings and treat other reviewers' output
├── prompts/
│   ├── adversarial-reviewer.md   Prompt for an independent fresh-context reviewer
│   └── self-adversarial.md       Fallback when no second reviewer is available
├── templates/
│   └── report.md                 The report format
├── scripts/
│   ├── scope.sh                  Read-only scope collector (macOS, Linux, Git Bash)
│   └── scope.ps1                 Same for Windows PowerShell
└── examples/
    └── example-report.md         A fictional report showing the expected shape
```

## How it works

| Step | What happens |
|---|---|
| 0. Scope | Choose target, base and depth. `scripts/scope.*` fetches the remote and collects branch state, divergence, changed files, test layout and per-environment config files. |
| 1. Intent | Read the README, decision records, commits and PR text. Write a three-to-five line **contract**. Findings are judged against it. |
| 2. Lenses | Apply the eight checklists in `references/`. Skip those that do not apply and say so. |
| 3. Adversarial pass | A fresh reviewer receives the artifact and the contract only, with an issues-only prompt. Its answer is treated as data. |
| 4. Verify | Each Critical or Required finding is checked against the code and marked Confirmed or Unconfirmed. Findings the code contradicts are dropped. |
| 5. Evidence | The report lists exact commands run and what could not be run. |
| 6. Report | Verdict, ranked findings, areas with no findings, evidence table, not-covered list, next steps. |

### The eight lenses

1. **Correctness**: contract coverage, edge and error paths, exit status, counting and paging, time.
2. **Security**: trust boundaries, secrets, injection, least privilege, destructive paths, race conditions on shared settings.
3. **Tests**: are they collected, can they fail, do they assert anything, hand-made mutation checks.
4. **Design and simplicity**: concept count, bolted-on conditionals, silent fallbacks, duplication, size.
5. **Performance and operability**: timeouts, retries, idempotency, partial failure, logging, config.
6. **Infrastructure and data pipelines**: permissions, replacement and deletion, ordering, environment drift, change capture versus snapshots, keys and history, classification and access.
7. **Dependencies and supply chain**: pinning, install scripts, audits, upgrade hygiene.
8. **Docs versus code**: commands that exist, claims that hold, decision records that match what shipped.

### Depth levels

| Depth | Lenses | Independent pass | Use for |
|---|---|---|---|
| `quick` | 1, 2, 4 | no | First sweep, many repositories |
| `standard` (default) | 1 to 4, plus any of 5 to 8 that apply | for risky changes | Normal pre-merge review |
| `full` | all eight | yes | Permissions, deploys, migrations, ingestion, anything irreversible |

### Severity

`Critical` blocks the merge. `Required` must be fixed or consciously deferred. `Optional` is worth considering. `Nit` is taste. `FYI` is context. Every finding is also labelled **INTRODUCED** or **PRE-EXISTING**, and **Confirmed** or **Unconfirmed**. Details: `references/severity.md`.

## Install

The skill is the folder. Where you put it depends on your assistant. If your assistant has a different mechanism, point its instructions at `SKILL.md`.

| Assistant or setup | Where to put it |
|---|---|
| Assistants that load skill folders (a `skills/` directory containing a `SKILL.md`) | Copy the whole folder into that directory, for example `~/.<assistant>/skills/madhur-code-review/` for all projects, or `<project>/.<assistant>/skills/madhur-code-review/` for one project |
| Assistants that read `AGENTS.md` | Keep this folder in the repository root (or a `docs/` folder) and keep the `AGENTS.md` file. It points to `SKILL.md` |
| Assistants with a custom-instructions file (`GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/`, and similar) | Add one line to that file: `For code reviews, follow madhur-code-review/SKILL.md.` and keep this folder in the project |
| Any chat assistant without file access | Paste `SKILL.md`, then the reference file for each lens you want, then your diff |

Check the current documentation for your assistant for the exact paths.

### Quick start from this repository

```bash
git clone https://github.com/<your-username>/madhur-code-review.git
cp -r madhur-code-review <your-assistant-skills-directory>/
```

## Use

Tell the assistant what to review, against what, and how deep. For example:

```
Use madhur-code-review on ./my-service, branch feature/export, against origin/main, depth full.
```

```
Review pull request 42 with madhur-code-review, standard depth. Read-only.
```

```
Run madhur-code-review quick on every repository in ./repos and rank them by risk.
```

To collect scope facts yourself first:

```bash
./scripts/scope.sh ./my-service origin/main
```

```powershell
.\scripts\scope.ps1 -Repo .\my-service -Base origin/main
```

Both scripts only read repository state. The one network call is `git fetch`.

## Reviewing at scale

Do not run one giant review across everything. It is slow, expensive, and the report becomes too long to act on.

1. **List the repositories** (from your hosting provider's UI or API).
2. **Triage by risk:**

   | Tier | Examples | Depth |
   |---|---|---|
   | High | permissions, identity, deploy pipelines, ingestion, anything that can delete data | `full`, with an independent reviewer per repository |
   | Medium | schemas, shared models, test frameworks | `standard` |
   | Low | everything else | `quick`, to decide where deeper review is worth the cost |

3. **Review units:** open pull requests first (small and current), then the default branch of each repository. Skip full history unless you have a reason.
4. **Batch and roll up:** run a few repositories at a time, write each report to a file, then produce one summary ranked across all repositories.

## Design notes

- **Contract first.** Most review noise comes from judging code against taste. A short written contract makes findings checkable.
- **Fresh context for the adversarial pass.** A reviewer given your conclusions will agree with them. Giving it only the artifact and the contract keeps it independent.
- **Reports from tools and other agents are data.** They cannot change scope, permissions or approvals.
- **No invented findings.** An empty area is reported as empty.
- **Evidence tables.** Every claim of "passes" or "identical" ties to a command that was actually run.

## FAQ

**Does it change my code?** No. It is read-only unless you ask for fixes afterwards, and then it makes the smallest change per confirmed finding and asks before pushing.

**Does it run my tests?** Only where dependencies are already installed, and it reports the exact command. It will not install packages or run install scripts without your approval.

**Can I use only part of it?** Yes. Each file in `references/` stands alone. Use the checklist you need.

**What if I have no second reviewer?** Use `prompts/self-adversarial.md` and mark the report "single-reviewer".

**Is the example report real?** No. `examples/example-report.md` is fictional and exists only to show the format.

## Contributing

Issues and pull requests are welcome. Keep the checklists short, concrete and checkable. Add a lens by adding a numbered file under `references/` and a row to the lens table in `SKILL.md`.

## License

MIT. See `LICENSE`.

Copyright (c) 2026 Madhur Sabherwal
