# Clean-room agent workflow

A clean-room workflow for compatibility / black-box implementation work, driven
by separate OpenCode sessions through GPT on OpenCode Go
(`opencode-go/gpt-5.6-luna`). Observation stays in one directory, implementation
in another, and only a human-reviewed, hash-verified approved package crosses the
boundary.

This lives under `v2/scripts/clean-room/` and is unrelated to the Neovim plugin
configuration. Do not wire it into the plugin setup.

```
v2/scripts/clean-room/
├── README.md                          # this file
├── clean-room-workspace.sh            # case lifecycle: init / path / worktree / approve
├── install-opencode.sh                # symlink the skill + agents into OpenCode config
├── agents/opencode/
│   ├── clean-room-orchestrator.md
│   ├── clean-room-specifier.md
│   ├── clean-room-implementer.md
│   └── clean-room-verifier.md
└── skills/clean-room-implementation/
    ├── SKILL.md
    └── references/artifact-contract.md
```

## Why state lives outside Git

All case state lives in the user state directory, never inside a repository:

```text
${CLEAN_ROOM_STATE_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/clean-room}/<case-id>/
```

`implementation/source/` is a git worktree (or independent repo), while
`implementation/.clean-room/` sits beside it — outside the Git tree. That means
the boundary directory needs no `.gitignore` entry and can never be committed,
and the observation material can never be pulled into the implementation repo by
an accidental `git add .`.

## Case layout

```text
<case-id>/
├── observation/
│   ├── target/                  # authorized observable target/material
│   └── .clean-room/
│       ├── boundary.md          # observation-only; does not cross the boundary
│       ├── evidence/            # raw observations (observation-only)
│       ├── candidate/           # specifier's draft package (no APPROVAL.md)
│       └── approved/            # human-approved package + APPROVAL.md
└── implementation/
    ├── source/                  # git worktree or independent repo
    └── .clean-room/
        ├── approved/            # copy of the approved package
        └── reports/             # conformance.md + audit.md from the verifier
```

OpenCode runs at `observation/` for the specifier and at `implementation/` for
the implementer and verifier.

## Workspace commands

The script is portable bash (`set -euo pipefail`) and never overwrites existing
records.

```sh
# Create a case. Creates the directory tree and a boundary.md template only if
# absent. Prints absolute paths and next steps.
clean-room-workspace.sh init <case-id>

# Print the absolute case root path.
clean-room-workspace.sh path <case-id>

# Create implementation/source as a git worktree of REPOSITORY on a new branch.
# Requires an initialized case and an absent-or-empty implementation/source.
# START_POINT defaults to HEAD.
clean-room-workspace.sh worktree <case-id> <repository> <branch> [start-point]

# Human approval step (mandatory, outside the agent loop). Copies
# observation/.clean-room/candidate/ to observation/.clean-room/approved/,
# generates APPROVAL.md (approver, UTC timestamp, boundary SHA-256, sorted
# SHA-256 manifest of every other approved file), verifies the digests, then
# copies the complete package to implementation/.clean-room/approved/.
# Refuses to overwrite a previous approval; use a new case for a new revision.
clean-room-workspace.sh approve <case-id> <approver>
```

`approve` supports either `sha256sum` or macOS `shasum -a 256`. On any failure it
does not claim approval. Case IDs allow only ASCII letters, digits, `.`, `_`,
`-` (empty, `.`, and `..` are rejected). `CLEAN_ROOM_STATE_HOME` and
`XDG_STATE_HOME`, when set, must be absolute paths.

## Installation

Install the skill and the four agents into the OpenCode config:

```sh
# via the flake (recommended)
nix run .#install-clean-room-opencode

# directly
./v2/scripts/clean-room/install-opencode.sh
```

This symlinks exactly these namespaced paths into
`${XDG_CONFIG_HOME:-$HOME/.config}/opencode/`:

- `skills/clean-room-implementation` → `v2/scripts/clean-room/skills/clean-room-implementation`
- `agents/clean-room-orchestrator.md`
- `agents/clean-room-specifier.md`
- `agents/clean-room-implementer.md`
- `agents/clean-room-verifier.md`

Existing symlinks at those paths are replaced; a non-symlink file or directory
with the same name causes the installer to fail rather than overwrite. Unrelated
config is never touched. Absolute symlink targets are used so the links stay
valid regardless of how they are invoked.

When run through the flake app, the installer's asset root is the current
dotfiles checkout (`$PWD/v2/scripts/clean-room`). This keeps installed symlinks
stable across Nix garbage collection, so run the command from this repository's
root. The direct script locates its assets relative to its own path.

**Restart OpenCode** (or reload its config) after installing so the new skill
and agents are picked up.

Two flake apps are provided in `apps.nix`:

```sh
nix run .#clean-room-workspace -- init <case-id>
nix run .#install-clean-room-opencode
```

## OpenCode model profile

All four agents pin `model: opencode-go/gpt-5.6-luna` and differ only in the
effort variant and permissions:

| Role | Agent | Mode | Variant |
| ---- | ----- | ---- | ------- |
| Coordination | `clean-room-orchestrator` | primary | `high` |
| Specification | `clean-room-specifier` | all | `max` |
| Implementation | `clean-room-implementer` | all | `medium` |
| Verification | `clean-room-verifier` | all | `max` |

Variants (`none`/`low`/`medium`/`high`/`xhigh`/`max`) are provider-specific
reasoning-effort presets; confirm with `opencode models opencode-go --verbose`.

## Running the phases

Every `opencode run` must use `--interactive` — noninteractive runs auto-reject
`ask` permissions and silently break the workflow.

```sh
# 1. Specification (at observation/)
opencode run --interactive --dir "$CASE/observation" \
  --agent clean-room-specifier '<specification prompt>'

# 2. Human approval outside the agent loop (not an agent step)
clean-room-workspace.sh approve "$CASE" '<your name or role>'

# 3. Implementation (at implementation/, fresh session)
opencode run --interactive --dir "$CASE/implementation" \
  --agent clean-room-implementer '<implementation prompt>'

# 4. Verification (at implementation/, fresh session)
opencode run --interactive --dir "$CASE/implementation" \
  --agent clean-room-verifier '<verification prompt>'
```

The orchestrator coordinates these sessions; it never runs the phases itself and
never uses Task subagents for phase work.

## Permission model

| | edit | bash | task | external dir | web |
| --- | --- | --- | --- | --- | --- |
| orchestrator | deny | ask | deny | ask | deny |
| specifier | `evidence/**`, `candidate/**` | ask | deny | deny | ask |
| implementer | `source/**` only | ask | deny | deny | deny |
| verifier | `reports/**` only | ask | deny | deny | deny |

These are process controls, not a security sandbox. For enforceable isolation,
run phases under separate OS users, containers, or machines.

## Caveats

- A `conformant` verification result covers the approved specification package
  only; it does not prove the specification is complete relative to the target.
- The specifier labels every requirement `observed`, `documented`, or
  `inferred`; unknowns stay unresolved rather than guessed.
- Approval is a human act. Agents cannot create `APPROVAL.md` or write
  `.clean-room/approved/`.
- Each revision needs a new case; an existing approval is never overwritten.
- OpenCode installation links to this checkout. Moving or deleting the checkout
  requires running the installer again from its new location.

## Legal disclaimer

This workflow is process guidance, not legal advice. Before observing a target,
confirm the work is authorized and review applicable license, contract,
anti-circumvention, patent, trademark, privacy, and jurisdiction-specific
constraints.
