# Lens 4: Design and simplicity

Question: is this the simplest structure that fits the system?

## Check

- **Fits the system.** Follows existing patterns, or justifies a new one. Dependencies flow in one direction. No circular imports.
- **Concept count.** Count the ideas a reader must hold to follow the change. A refactor that moves code around without reducing that count has not simplified anything.
- **Bolted-on conditionals.** A new `if` in an unrelated flow is a design smell. Repeated conditionals on the same shape point to a missing model or dispatcher.
- **Abstraction earns its place.** Do not generalise before the third use. Delete pass-through wrappers that add indirection and no meaning.
- **Duplication.** A near-copy of an existing helper should reuse the helper.
- **Layering.** Feature-specific logic should not live in a shared module. Orchestration should be separate from business rules.
- **Silent fallbacks.** A default that hides an unclear rule (for example, a missing config file treated as "empty") turns typos into green runs. Prefer failing loudly, with a short explicit allow-list for the cases where empty is intended.
- **Type and data boundaries.** Gratuitous `any`, casts and optional fields hide invariants. Make the boundary explicit.
- **Size.** A file past roughly a thousand lines, or a change past a few hundred, should be split first. Refactoring and new behaviour belong in separate changes.
- **Naming.** Names should be specific. `data`, `result`, `temp`, `helper` explain nothing.
- **Dead code.** List it; do not silently delete what you are unsure about.

## When you flag a structural problem, propose the move

Name a concrete restructuring, for example: replace a chain of conditionals with a typed lookup, collapse duplicate branches, move feature logic to its owner, reuse the canonical helper, delete the wrapper, split the file. A comment that only says "this is complex" leaves the author guessing.
