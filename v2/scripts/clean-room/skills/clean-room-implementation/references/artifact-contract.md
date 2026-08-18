# Clean-room artifact contract

Only the independently reviewed approved package crosses from the observation
environment to the implementation environment. Paths below are relative to the
case root:

```text
${CLEAN_ROOM_STATE_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/clean-room}/<case-id>/
```

## Boundary record

Store `observation/.clean-room/boundary.md`. Record the target, compatibility
goal, permitted observation methods, prohibited materials, directories,
interfaces in scope, acceptance criteria, non-goals, and designated approver.
This file is observation-only and does not cross the boundary.

## Observation-only artifacts

Store these under `observation/.clean-room/evidence/`. Never copy them into the
implementation environment.

- Experiment commands and raw outputs.
- Packet captures, traces, screenshots, and target-generated files.
- Notes about public documentation and the exact source consulted.
- Rejected hypotheses and exploratory observations.
- Any material whose redistribution or use has not been approved.

## Candidate package

The specifier writes `observation/.clean-room/candidate/` using the
approved-package layout below except for `APPROVAL.md`. The specifier cannot
write `observation/.clean-room/approved/` and cannot approve its own candidate.

## Approved package

Store the reviewed package under `observation/.clean-room/approved/` and its copy
under `implementation/.clean-room/approved/`:

```text
.clean-room/approved/
├── spec.md
├── provenance.md
├── test-vectors.jsonl
├── APPROVAL.md
└── tests/                  # optional executable conformance tests
```

A designated human approver reviews the candidate outside the agent loop, removes
material that must not cross the boundary, and records approval with
`clean-room-workspace.sh approve <case-id> <approver>`. The command copies the
candidate into `observation/.clean-room/approved/`, generates `APPROVAL.md`
recording:

- approver identity or role;
- approval timestamp (UTC);
- SHA-256 of `observation/.clean-room/boundary.md`;
- a sorted SHA-256 manifest of every other file in the package;

verifies those digests, and then copies the complete package to
`implementation/.clean-room/approved/`. The package is not approved when
`APPROVAL.md` is missing or its digests do not match. A previous approval is
never overwritten; create a new case for a new revision.

### `spec.md`

Every normative requirement has a stable identifier such as `CR-INPUT-001`. For
each requirement, record:

- externally observable behavior;
- preconditions and inputs;
- outputs, state changes, and errors;
- whether it is observed, documented, or inferred;
- the evidence identifier supporting it;
- unresolved ambiguity.

Describe behavior in original language. Do not include source code, decompiler
output, copied internal names, or expressive material that is unnecessary for
compatibility.

### `provenance.md`

List the origin of every source used to derive the approved package and the
authorization or permission status supplied by the user or reviewer. Do not make
an independent legal determination. Link each entry to the requirement
identifiers it supports. Record public documentation quotations only when
necessary and keep them clearly attributed; prefer an original behavioral
description.

### `test-vectors.jsonl`

Use one JSON object per line:

```json
{"id":"CR-TV-001","requirements":["CR-INPUT-001"],"input":{},"expected":{},"comparison":"exact"}
```

Keep observed values exact. Mark unstable or environment-dependent fields
explicitly instead of guessing normalized values.

### `tests/`

Executable tests must exercise only the public behavior described by `spec.md`.
They must not expose or read observation-only artifacts at runtime.

## Implementation artifacts

The implementation environment may contain the approved package, independent
source code, build outputs, and `.clean-room/reports/`. It must not contain the
target source, decompiler output, or raw observation evidence.

## Conformance report

Write `implementation/.clean-room/reports/conformance.md` with:

- the implementation revision tested;
- the approved-package digest or revision;
- commands actually run and their outcomes;
- one result per requirement identifier;
- divergences, missing evidence, and blocked checks;
- a final `conformant`, `non-conformant`, or `inconclusive` result.

Never report a check as passing unless a tool result from the current verifier
session supports it. `Conformant` means conformant to the approved specification
package only; it is not an independent claim that the specification fully
represents the target.

## Audit summary

Write `implementation/.clean-room/reports/audit.md` after verification. Include
the approved-package digests, implementation revision, conformance result and
its scope, unresolved items, process caveats, artifact locations, and whether the
package boundary was verified.