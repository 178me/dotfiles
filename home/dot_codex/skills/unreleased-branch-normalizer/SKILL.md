---
name: unreleased-branch-normalizer
description: Normalize a never-released development branch against the last released baseline by collapsing unpublished schema, API, configuration, and data migrations into one coherent release while removing compatibility code that only serves intermediate development states. Use when a long-running branch accumulated version bumps, migration chains, adapters, or abandoned designs before its first release.
---

# Unreleased Branch Normalizer

Treat the last actually released state—not the current development branch history—as the compatibility boundary. Make the final diff look like one intentionally designed release from that boundary.

## Establish the real compatibility boundary

Before changing code, identify:

- the last released baseline branch, tag, or commit;
- the current unpublished branch and their merge base;
- which persisted versions or public interfaces have reached real users;
- the intended final behavior that must survive normalization.

Do not infer release status from version numbers or branch names alone. If the released baseline is ambiguous and choosing incorrectly could discard a required upgrade path, ask the user.

Classify states into three groups:

1. Released states: must remain supported.
2. Final target state: must work for upgrades and fresh installs.
3. Unpublished intermediate states: do not require compatibility unless the user explicitly asks to preserve developer/test data.

## Inventory versioned and transitional behavior

Inspect the baseline-to-target diff and search for more than database versions. Include:

- database schemas, migrations, triggers, indexes, and seed data;
- persisted preferences, caches, files, serialized messages, and configuration formats;
- API/protocol versions, RPC shapes, identifiers, routes, and compatibility adapters;
- feature flags, temporary fallbacks, duplicate implementations, deprecated aliases, and dead branches;
- tests and fixtures that encode unpublished intermediate states.

Separate genuine baseline compatibility from scaffolding created only while the unpublished design was evolving.

## Normalize the implementation

Apply these rules:

- Preserve every upgrade path that was already released.
- By default, represent the new release as one version step after the released baseline. For example, if the released database is version 3, the unpublished final schema normally becomes version 4, not version 7.
- Collapse unpublished migration chains into one direct migration from the released schema to the final schema.
- Make fresh installation create the final schema directly.
- Remove migrations, adapters, fields, aliases, and fallbacks whose only purpose is to support unpublished intermediate states.
- Preserve stable external identifiers and contracts even if internal representations are simplified.
- Keep final functionality and proven performance/correctness improvements, but do not preserve an intermediate architecture merely because it already exists.
- Prefer one clear implementation over parallel old/new paths when only the released boundary requires compatibility.

Do not blindly renumber a version controlled by an external standard, server contract, or independent release train. Explain such exceptions.

## Verify the two real product paths

At minimum, verify:

1. A fresh install creates and uses the final state.
2. An installation at the last released state upgrades directly without losing required data or behavior.

When older released states are supported by the baseline, retain and test those pre-existing paths as well. Do not add upgrade tests for unpublished intermediate versions unless explicitly required.

Check final invariants rather than only version numbers: schema shape, indexes, data transformation, API behavior, identifier stability, restart behavior, and removal of obsolete artifacts.

## Keep code normalization separate from Git history

Rewriting code and migrations does not authorize rebasing, squashing, force-pushing, or deleting branches. Preserve Git history unless the user explicitly requests history cleanup. If requested, normalize and verify the code first, then propose or perform the history rewrite as a separate operation.

## Report the result

Summarize:

- released baseline and final target;
- compatibility paths retained;
- unpublished versions or transitional paths removed;
- migrations and implementations collapsed;
- fresh-install and upgrade verification performed;
- unresolved external compatibility constraints or risks.
