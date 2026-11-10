# Lens 7: Dependencies and supply chain

Question: what new code and trust does this change bring in?

## Check

- **Is it needed?** Prefer the standard library and what is already in the project.
- **Pinning.** Versions are pinned and the lock file is committed. A pin to a version you cannot confirm exists is a reproducibility risk: try the install in a clean environment before trusting it.
- **Unused packages.** Listed but never imported.
- **Maintenance and licence.** Active upkeep, a licence compatible with the project.
- **Known vulnerabilities.** Run the package manager's own audit on the lock file. Triage by reachability (runtime, build, test, deploy) rather than by headline severity. An audit only matches known advisories; it does not catch a brand-new malicious package or a look-alike name.
- **Install scripts.** Dependencies that run code on install are a risk. Prefer installs with scripts disabled, then approve the minimum needed.
- **Upgrades.** One dependency per change, with the changelog read and the transitive lock-file diff reviewed. Bulk "bump everything" changes hide which package broke the build.
- **Private registries.** Note which packages come from private registries; they need a valid login, and an expired token is a normal reason an install fails.
- **Vendored code.** Copies of third-party libraries inside the repo need a note on origin and version.

## Evidence rule

Do not install anything to complete the review without the user's approval. Say which checks need an install and were therefore not run.
