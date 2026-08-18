#!/usr/bin/env bash
# install-opencode.sh — symlink the clean-room skill and agents into the
# OpenCode configuration so `opencode` can load them.
#
# Installs exactly these namespaced links (and nothing else):
#   ${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/clean-room-implementation
#   ${XDG_CONFIG_HOME:-$HOME/.config}/opencode/agents/clean-room-{orchestrator,specifier,implementer,verifier}.md
#
# - Replaces an existing symlink at the same path.
# - Fails rather than overwriting a non-symlink file or directory.
# - Never deletes unrelated configuration.
# - Uses absolute symlink targets, so the links stay valid no matter how the
#   script or the OpenCode config is invoked.

set -euo pipefail
: "${HOME:?HOME must be set}"

# Resolve this script's real directory, handling invocation through a symlink.
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  case "$SOURCE" in
    /*) ;;
    *) SOURCE="$DIR/$SOURCE" ;;
  esac
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# The assets (skills/, agents/) normally live next to this script. The flake app
# injects the current dotfiles checkout via CLEAN_ROOM_SOURCE_DIR so installed
# links do not point at an unrooted, garbage-collectable Nix store path.
BASE_DIR="${CLEAN_ROOM_SOURCE_DIR:-$SCRIPT_DIR}"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
SKILLS_DIR="$CONFIG_DIR/skills"
AGENTS_DIR="$CONFIG_DIR/agents"

SOURCE_SKILL="$BASE_DIR/skills/clean-room-implementation"
SKILL_LINK="$SKILLS_DIR/clean-room-implementation"

AGENT_SOURCES=(
  "$BASE_DIR/agents/opencode/clean-room-orchestrator.md"
  "$BASE_DIR/agents/opencode/clean-room-specifier.md"
  "$BASE_DIR/agents/opencode/clean-room-implementer.md"
  "$BASE_DIR/agents/opencode/clean-room-verifier.md"
)

install_link() {
  local source="$1" link="$2"
  if [ ! -e "$source" ]; then
    printf 'install-opencode: error: source does not exist: %s\n' "$source" >&2
    exit 1
  fi
  if [ -L "$link" ]; then
    rm -f "$link" # replace our own (or any) symlink, broken or not
  elif [ -e "$link" ]; then
    printf 'install-opencode: error: %s exists and is not a symlink; refusing to overwrite\n' "$link" >&2
    exit 1
  fi
  ln -s "$source" "$link"
  printf 'linked %s -> %s\n' "$link" "$source"
}

mkdir -p "$SKILLS_DIR" "$AGENTS_DIR"

install_link "$SOURCE_SKILL" "$SKILL_LINK"
for agent in "${AGENT_SOURCES[@]}"; do
  install_link "$agent" "$AGENTS_DIR/$(basename "$agent")"
done

printf '\nInstalled the clean-room skill and four agents into %s.\n' "$CONFIG_DIR"
printf 'Restart OpenCode (or reload its config) so the new skill and agents are picked up.\n'
