#!/usr/bin/env bash
# clean-room-workspace.sh — manage isolated clean-room case directories.
#
# A case lives OUTSIDE any Git repository, under
#   ${CLEAN_ROOM_STATE_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/clean-room}/<case-id>/
# so that .clean-room/ never needs a .gitignore entry and the boundary between
# observation and implementation stays outside the implementation's Git tree.
#
# Commands:
#   init CASE                  create the case directory structure and boundary template
#   path CASE                  print the absolute case root path
#   worktree CASE REPO BRANCH [START_POINT]
#                              create implementation/source as a git worktree
#   approve CASE APPROVER      record human approval of the candidate package
#   help                       show usage
#
# `approve` is the only command that writes an approved package, and it is
# intentionally a human-invoked command. Agents must never run it.

set -euo pipefail
: "${HOME:?HOME must be set}"

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

die() {
  printf 'clean-room-workspace: error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: clean-room-workspace.sh <command> [args...]

Commands:
  init CASE                 Create a new clean-room case directory structure
                            and a boundary.md template. Never overwrites
                            existing records.
  path CASE                 Print the absolute case root path.
  worktree CASE REPO BRANCH [START_POINT]
                            Create implementation/source as a git worktree of
                            REPO on a new branch BRANCH. START_POINT defaults
                            to HEAD. Requires an initialized case and an
                            absent-or-empty implementation/source.
  approve CASE APPROVER     Record human approval of the candidate package:
                            copy candidate -> observation/.clean-room/approved,
                            generate APPROVAL.md (approver, UTC timestamp,
                            boundary SHA-256, sorted package manifest), verify
                            the digests, then copy the complete package to
                            implementation/.clean-room/approved. Fails rather
                            than overwriting a previous approval.

Environment:
  CLEAN_ROOM_STATE_HOME      Override the state base directory. Default:
                             ${XDG_STATE_HOME:-$HOME/.local/state}/clean-room
EOF
}

state_root() {
  local root="${CLEAN_ROOM_STATE_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/clean-room}"
  case "$root" in
    /*) ;;
    *) die "clean-room state root must be an absolute path: $root" ;;
  esac
  printf '%s\n' "$root"
}

validate_case_id() {
  local case_id="$1"
  [ -n "$case_id" ] || die "case id is required"
  case "$case_id" in
    . | ..)
      die "invalid case id: '$case_id'"
      ;;
  esac
  if [[ ! "$case_id" =~ ^[A-Za-z0-9._-]+$ ]]; then
    die "invalid case id '$case_id': only ASCII letters, digits, '.', '_', '-' are allowed"
  fi
}

case_root() {
  local case_id="$1"
  validate_case_id "$case_id"
  printf '%s/%s\n' "$(state_root)" "$case_id"
}

require_case() {
  local case_id="$1"
  local root
  root="$(case_root "$case_id")"
  if [ ! -f "$root/observation/.clean-room/boundary.md" ]; then
    die "case '$case_id' is not initialized (missing $root/observation/.clean-room/boundary.md); run 'init $case_id' first"
  fi
  printf '%s\n' "$root"
}

# dir_is_empty DIR: true when DIR is missing or has no entries.
dir_is_empty() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  [ -z "$(ls -A "$dir" 2>/dev/null)" ]
}

# ensure_dir_empty DIR LABEL: create if missing, fail if non-empty.
ensure_dir_empty() {
  local dir="$1" label="$2"
  [ ! -L "$dir" ] || die "$label must not be a symlink: $dir"
  mkdir -p "$dir"
  if ! dir_is_empty "$dir"; then
    die "$label is not empty: $dir — a previous approval exists. Use a new case for a new revision."
  fi
}

# sha256_digest FILE: print the lowercase hex SHA-256 digest of FILE.
# Supports sha256sum (GNU coreutils) and shasum -a 256 (macOS).
sha256_digest() {
  local file="$1" out
  if command -v sha256sum >/dev/null 2>&1; then
    out="$(sha256sum "$file")" || return 1
  elif command -v shasum >/dev/null 2>&1; then
    out="$(shasum -a 256 "$file")" || return 1
  else
    printf 'clean-room-workspace: error: no SHA-256 tool found (need sha256sum or shasum)\n' >&2
    return 1
  fi
  printf '%s\n' "${out%% *}"
}

# generate_manifest DIR: sorted '<hash>  <relative-path>' lines for every file
# in DIR except APPROVAL.md. Paths are relative to DIR and sorted by path.
generate_manifest() {
  local dir="$1" f h
  (
    cd "$dir" || return 1
    find . -type f ! -path ./APPROVAL.md -print | LC_ALL=C sort |
      while IFS= read -r f; do
        h="$(sha256_digest "${f#./}")" || {
          printf 'clean-room-workspace: error: failed to hash %s\n' "${f#./}" >&2
          exit 1
        }
        printf '%s  %s\n' "$h" "${f#./}"
      done
  )
}

# Staging cleanup: remove any leftover staging dirs if the script exits early.
# A successful approve clears the array so moved packages are never deleted.
STAGING_PATHS=()
cleanup_staging() {
  local staging
  for staging in "${STAGING_PATHS[@]}"; do
    [ -d "$staging" ] && rm -rf "$staging"
  done
}
trap cleanup_staging EXIT

# ---------------------------------------------------------------------------
# init CASE
# ---------------------------------------------------------------------------

cmd_init() {
  local case_id="${1:-}"
  validate_case_id "$case_id"
  local root
  root="$(case_root "$case_id")"

  local obs="$root/observation/.clean-room"
  local impl="$root/implementation/.clean-room"

  mkdir -p "$root/observation/target"
  mkdir -p "$obs/evidence" "$obs/candidate" "$obs/approved"
  mkdir -p "$impl/approved" "$impl/reports"

  local boundary="$obs/boundary.md"
  if [ -e "$boundary" ]; then
    printf 'kept existing %s\n' "$boundary"
  else
    cat >"$boundary" <<EOF
# Clean-room boundary

Case: $case_id
Created (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Target and compatibility goal

- Target:
- Compatibility goal:

## Observation

- Observation directory: $root/observation/
- Permitted observation methods:
- Prohibited materials (never put these in the approved package):
  - target source code
  - decompiler output
  - raw observation logs or evidence
  - unapproved third-party material

## Implementation

- Implementation directory: $root/implementation/
- Implementation source: $root/implementation/source/

## Scope

- Public interfaces in scope:
- Acceptance criteria:
- Non-goals:

## Approval

- Designated approver (human, outside the agent loop):
- Approved (UTC):

## Legal note

This workflow is process guidance, not legal advice. Confirm that observing
the target is authorized and review applicable license, contract,
anti-circumvention, patent, trademark, privacy, and jurisdiction-specific
constraints.
EOF
    printf 'created %s\n' "$boundary"
  fi

  printf '\nClean-room case %q initialized.\n' "$case_id"
  printf '  observation:    %s\n' "$root/observation"
  printf '  implementation: %s\n' "$root/implementation"
  printf '\nNext steps:\n'
  printf '  1. Edit %s to record the boundary.\n' "$boundary"
  printf '  2. Place authorized observable material under %s.\n' "$root/observation/target"
  printf '  3. Run: clean-room-workspace.sh worktree %s <repo> <branch>\n' "$case_id"
  printf '  4. After the specifier drafts a candidate, review it and run:\n'
  printf '     clean-room-workspace.sh approve %s <approver>\n' "$case_id"
}

# ---------------------------------------------------------------------------
# path CASE
# ---------------------------------------------------------------------------

cmd_path() {
  local case_id="${1:-}"
  printf '%s\n' "$(case_root "$case_id")"
}

# ---------------------------------------------------------------------------
# worktree CASE REPOSITORY BRANCH [START_POINT]
# ---------------------------------------------------------------------------

cmd_worktree() {
  local case_id="${1:-}" repository="${2:-}" branch="${3:-}" start_point="${4:-}"
  validate_case_id "$case_id"
  [ -n "$repository" ] || die "repository path is required"
  [ -n "$branch" ] || die "branch name is required"
  git -C "$repository" check-ref-format --branch "$branch" >/dev/null 2>&1 ||
    die "invalid branch name: $branch"
  local root
  root="$(require_case "$case_id")"

  local source_dir="$root/implementation/source"
  if [ -e "$source_dir" ] && ! dir_is_empty "$source_dir"; then
    die "implementation/source exists and is not empty: $source_dir (refusing to overwrite)"
  fi

  local commit
  commit="$(git -C "$repository" rev-parse --verify "${start_point:-HEAD}^{commit}")" ||
    die "invalid start point: ${start_point:-HEAD}"
  git -C "$repository" worktree add -b "$branch" "$source_dir" "$commit"
  printf 'worktree added: %s (branch %s)\n' "$source_dir" "$branch"
}

# ---------------------------------------------------------------------------
# approve CASE APPROVER
# ---------------------------------------------------------------------------

verify_approval() {
  local dir="$1" boundary="$2" expected_boundary="$3" approval_file="$4"
  local manifest recorded boundary_recorded actual_boundary

  manifest="$(generate_manifest "$dir")" || die "approval verification failed: could not recompute package manifest"
  recorded="$(grep -E '^[0-9a-f]{64}  ' "$approval_file")" || true
  if [ "$manifest" != "$recorded" ]; then
    die "approval verification failed: recomputed package digests do not match APPROVAL.md"
  fi

  boundary_recorded="$(sed -n 's/^- Boundary SHA-256: //p' "$approval_file")"
  actual_boundary="$(sha256_digest "$boundary")" || die "approval verification failed: could not recompute boundary digest"
  if [ "$boundary_recorded" != "$expected_boundary" ] || [ "$boundary_recorded" != "$actual_boundary" ]; then
    die "approval verification failed: boundary SHA-256 mismatch"
  fi
}

cmd_approve() {
  local case_id="${1:-}" approver="${2:-}"
  validate_case_id "$case_id"
  [ -n "$approver" ] || die "approver is required (usage: approve CASE APPROVER)"
  case "$approver" in
    *$'\n'* | *$'\r'*) die "approver must be a single line" ;;
  esac
  local root
  root="$(require_case "$case_id")"

  local obs="$root/observation/.clean-room"
  local impl="$root/implementation/.clean-room"
  local candidate="$obs/candidate"
  local obs_approved="$obs/approved"
  local impl_approved="$impl/approved"
  local boundary="$obs/boundary.md"

  # Candidate prerequisites
  [ -f "$candidate/spec.md" ] || die "candidate is missing spec.md: $candidate/spec.md"
  [ -f "$candidate/provenance.md" ] || die "candidate is missing provenance.md: $candidate/provenance.md"
  [ -f "$candidate/test-vectors.jsonl" ] || die "candidate is missing test-vectors.jsonl: $candidate/test-vectors.jsonl"
  if [ -e "$candidate/APPROVAL.md" ]; then
    die "candidate contains APPROVAL.md; a candidate cannot approve itself — remove it and re-run approve"
  fi

  # Never overwrite a previous approval: both approved dirs must be empty.
  ensure_dir_empty "$obs_approved" "observation .clean-room/approved"
  ensure_dir_empty "$impl_approved" "implementation .clean-room/approved"

  # Stage and verify both copies before publishing either package.
  local staging
  staging="$(mktemp -d "$root/.approve-staging.XXXXXX")" || die "failed to create staging directory"
  STAGING_PATHS+=("$staging")
  cp -a "$candidate/." "$staging/"

  local now boundary_hash manifest
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  boundary_hash="$(sha256_digest "$boundary")" || die "failed to hash boundary file"
  manifest="$(generate_manifest "$staging")" || die "failed to compute package manifest"

  cat >"$staging/APPROVAL.md" <<EOF
# Clean-room approval record

- Case: $case_id
- Approver: $approver
- Approved (UTC): $now
- Boundary file: observation/.clean-room/boundary.md
- Boundary SHA-256: $boundary_hash

## SHA-256 manifest

Sorted SHA-256 digest of every other file in this package, relative to this
directory. Do not modify this package after approval; create a new case for a
new revision.

$manifest
EOF

  # Verify the recorded digests against the actual files before declaring approval.
  verify_approval "$staging" "$boundary" "$boundary_hash" "$staging/APPROVAL.md"

  # Prepare and verify the implementation copy before publishing either package.
  local impl_staging
  impl_staging="$(mktemp -d "$impl/.impl-staging.XXXXXX")" || die "failed to create implementation staging directory"
  STAGING_PATHS+=("$impl_staging")
  cp -a "$staging/." "$impl_staging/"
  verify_approval "$impl_staging" "$boundary" "$boundary_hash" "$impl_staging/APPROVAL.md"

  # Publish both verified packages. The target directories are known empty.
  rmdir "$obs_approved"
  rmdir "$impl_approved"
  if ! mv "$staging" "$obs_approved"; then
    mkdir -p "$obs_approved" "$impl_approved"
    die "failed to publish the observation package"
  fi
  if ! mv "$impl_staging" "$impl_approved"; then
    # Restore the pre-approval state so the human can safely retry.
    mv "$obs_approved" "$staging" ||
      die "failed to publish the implementation package and could not roll back the observation package"
    mkdir -p "$obs_approved" "$impl_approved"
    die "failed to publish the implementation package; approval was rolled back"
  fi
  STAGING_PATHS=()

  printf '\nApproval recorded.\n'
  printf '  approver:            %s\n' "$approver"
  printf '  approved (UTC):      %s\n' "$now"
  printf '  observation package: %s\n' "$obs_approved"
  printf '  implementation pkg:  %s\n' "$impl_approved"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  local command="${1:-}"
  case "$command" in
    init)
      cmd_init "${2:-}"
      ;;
    path)
      cmd_path "${2:-}"
      ;;
    worktree)
      cmd_worktree "${2:-}" "${3:-}" "${4:-}" "${5:-}"
      ;;
    approve)
      cmd_approve "${2:-}" "${3:-}"
      ;;
    help | -h | --help)
      usage
      ;;
    "")
      usage >&2
      exit 1
      ;;
    *)
      usage >&2
      die "unknown command: $command"
      ;;
  esac
}

main "$@"
