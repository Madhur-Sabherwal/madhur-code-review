# Lens 6: Infrastructure as code and data pipelines

Question: are permissions, deploys, config and data semantics safe?

Use this lens for cloud infrastructure code (CDK, Terraform, CloudFormation), data-lake and warehouse pipelines, replication and ingestion jobs, and access-control tagging.

## Infrastructure as code

- **Permissions.** Wildcard actions or resources, roles that register themselves as administrators, standing admin rights re-applied on every deploy, grants that are never revoked, broad grants combined with narrower filters (a union can bypass the filter).
- **Replacement and deletion.** Which property changes force a resource to be replaced? What is deleted when the stack is deleted or rolled back? Missing retain policies on keys, tags or data that other components use.
- **Create-before-delete ordering.** A replacement that creates first and deletes after can fail on name conflicts. Fixed physical names make replacement fail.
- **Custom resources and embedded code.** Code in a string inside a template has no linting, no types and usually no tests. Check its error handling: swallowed exceptions on delete leave orphans. Check update paths, not only create.
- **Non-deterministic templates.** A value that changes on every build (a timestamp used as a nonce) means the diff is never clean and the custom step runs on every deploy.
- **Ordering between stacks.** Two stacks that touch the same account-wide setting with no declared dependency can run at the same time and lose updates.
- **Environment safety.** A change meant for one environment must not leak to others through shared config. Selecting config by an environment name that is only a default or can be mistyped should fail, not fall back to "nothing".
- **Empty or placeholder resources.** Stacks that deploy a placeholder in environments where they should do nothing.
- **Hard-coded identifiers.** Account ids, host addresses, ARNs in source. Acceptable in environment-scoped config, wrong in shared code.

## Config across environments

- Diff the per-environment files. Identical copies drift; unexpectedly different ones hide mistakes.
- List what exists in the first environment and is missing from later ones. A feature present only in the earliest environment cannot be promoted.
- Check that names referenced across repositories (databases, tables, tags, parameters) match in both places.

## Data pipelines

- **Source versus target parity.** Every table the ingestion brings in has a matching downstream entry, or the omission is deliberate.
- **Keys and history.** Business keys are unique at the declared grain. Composite keys are handled. Slowly-changing history has exactly one current row per key.
- **Change capture versus full snapshots.** Deleting rows that are "absent" is only safe when the load is a complete snapshot. Check that partial or incremental loads cannot trigger mass deletes, and that a guard rejects truncated extracts.
- **Source object types.** Some replication tools cannot capture changes from views. Confirm what the source objects really are.
- **Replication settings that conflict.** For example, a setting valid only for a full-load task applied to a change-capture task.
- **Layer boundaries.** Raw data is append-only and untouched; transformations are reproducible; reprocessing is safe.
- **Classification and access.** Sensitive data carries the right classification. A tag that is only a label enforces nothing, so check whether a grant actually exists. Check for tag-key ownership conflicts between repositories that manage the same tags.
- **Counts and paging.** Row counts that skip headers, pages capped at a fixed size, truncated query results.

## Evidence rule

Structural infrastructure tests only prove the generated template has the expected shape. They do not prove deployment works, that permissions are sufficient, or that replication captures anything. State this in the report and say what was not exercised.
