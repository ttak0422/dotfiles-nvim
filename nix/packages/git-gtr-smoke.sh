# Run with the packaged git-gtr and git on PATH. Never touches a real repository.
set -eu
export HOME="$TMPDIR/git-gtr-home"
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL=/dev/null
unset GTR_WORKTREES_DIR GTR_WORKTREES_PREFIX GTR_DIR
mkdir -p "$HOME" "$TMPDIR/git-gtr-smoke"
cd "$TMPDIR/git-gtr-smoke"
git init -q -b main 'repo space'
cd 'repo space'
git -c user.name=Test -c user.email=test@example.invalid commit --allow-empty -qm initial
git gtr version
git gtr new feature --from-current --no-fetch --no-copy --no-hooks --yes
test -f '../repo space-worktrees/feature/.git'
git gtr list --porcelain | grep -F "$(cd '../repo space-worktrees/feature' && pwd)"
# Respect an existing configured location; do not overwrite it with a suffix.
git config gtr.worktrees.dir "$TMPDIR/git-gtr-smoke/custom worktrees"
git gtr new custom --from-current --no-fetch --no-copy --no-hooks --yes
test -f '../custom worktrees/custom/.git'
