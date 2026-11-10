# Instructions for AI coding assistants

This repository contains one skill: a complete code review workflow.

**When the user asks for a code review, a pre-merge check, a pre-work check, or a security-minded review of a repository, branch, diff or pull request, follow `SKILL.md` in this folder.**

Quick rules (details in `SKILL.md`):

1. Review only. Do not edit the code under review, deploy, install packages, or query live systems unless the user asks and approves.
2. Establish scope (target, base, depth) and fetch the base first.
3. Read the intent (README, decision records, commits, PR text) and write a short contract.
4. Apply the lenses in `references/`. Skip those that do not apply and say so.
5. For non-trivial or high-blast-radius changes, run an independent adversarial pass using `prompts/adversarial-reviewer.md`. Give the reviewer the artifact and the contract only.
6. Verify every Critical or Required finding against the code. Mark it Confirmed or Unconfirmed.
7. Report with `templates/report.md`, ranked by leverage, and state what was not run or not covered.
8. Never claim tests passed unless they ran in this session.

How to load this skill depends on the assistant. See the README for install locations.
