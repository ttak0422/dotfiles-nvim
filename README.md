<h1 align="center">
    dotfiles-nvim
</h1>
<div align="center">
  <img alt="nix" src="https://img.shields.io/badge/nix-5277C3.svg?&style=for-the-badge&logo=NixOS&logoColor=white">
  <img alt="tag" src="https://img.shields.io/github/v/tag/ttak0422/dotfiles-nvim?style=for-the-badge&label=latest%20tag&color=orange">
  <img alt="license" src="https://img.shields.io/github/license/ttak0422/dotfiles-nvim?style=for-the-badge">
  <p>dotfiles v5</p>
</div>

![image](./assets/v1.0.png)

## Platform support

The full `bundler-nvim-v2` package targets Apple Silicon macOS (`aarch64-darwin`):
meian and the packaged Kotlin LSP depend on macOS. Linux (`x86_64-linux`,
`aarch64-linux`) exposes development tools and portable checks, not the full package.
Intel macOS (`x86_64-darwin`) is no longer supported.

## CI checks

On pushes to main and pull requests, Linux and Apple Silicon macOS run
`nix flake check`: workflow lint and the seven isolated Mimori/Komado suites
(packaging, client, adapter, priority, labels, presentation snapshots, hover).
Tests use the pinned Komado plugin and synthetic data, without a user daemon.
macOS additionally builds `nix build .#bundler-nvim-v2 --no-link`.
PR runs read caches without uploading or requiring the Cachix write secret.
These checks do not claim full Linux editor support or exercise every LSP.
The HUD check uses real hud.nvim floats, Gitsigns with a local Git fixture, and
Sorairo highlights to cover layout, focus changes, updates, resizing, and caching.
The terminal suite also checks command arguments, session reuse, and process exits
with local fixture programs and an isolated pterm socket directory.
The code-action suite uses a synthetic LSP transport with real Telescope and delta
to check previews, resolution, workspace edits, and command execution. It also
covers tiny-code-action's buffer auto-preview regression separately. These checks
do not reproduce every language server's responses or establish that an unrecorded
interactive code-action error is fixed.

## Window HUD

The borderless HUD replaces Incline. Every row is right aligned at the top right
of its source window. Active windows show four rows; inactive windows keep two:

| Row | Content | Visibility |
| --- | --- | --- |
| 1 | Modified indicator, filename, directory | All windows |
| 2 | Line/byte column, Git branch (with `*` for changes) | All windows |
| 3 | Error and warning counts | Active window |
| 4 | Added, changed, removed counts from Gitsigns | Active window |

Empty diagnostic/diff rows remain blank. Colors, icons, Git-relative paths,
Maven source-prefix removal, and path shortening below 100 columns follow the
previous UI. Width pressure drops the directory before the indicator/filename,
and the branch before the ruler; the last surviving item clips by display cells.
Resizing restores the full content. The HUD uses WinBar/WinBarNC, Title,
DiagnosticError/Warn, and the existing terminal Git palette, including after a
colorscheme change. There is no legacy statusline/winbar content or box outline.

hud.nvim overlays buffer text in a rectangular float. Its default cursor/Visual
avoidance hides the active HUD while editing the covered rows or selecting text;
panes too short for the required rows hide it too. Existing special buffer and
filetype exclusions remain, and preview/floating windows are excluded.

Run `nix build .#checks.aarch64-darwin.hud --no-link` for the isolated regression.
This does not activate the full dotfiles configuration.

## Terminal sessions in Telescope

Open `:Telescope pterm` (or the existing `<leader>ft` mapping). Select a search
result and press Enter to reconnect as before. Only when there is **no selected
result**, the prompt creates a session with `name [command args...]`:

| Prompt, with no selected result | Result |
| --- | --- |
| `review` | Create `review` with the default `$SHELL` |
| `review claude` | Create `review` and directly execute `claude` |
| `review claude --resume` | Pass `--resume` to the executable |
| `review claude "a prompt with spaces"` | Pass one argument containing spaces |

Leading/trailing spaces are ignored; multiple spaces separate words. Arguments
use the already installed Telescope live-grep-args parser with auto-quoting off:
single/double quotes group spaces, and quoted empty arguments are supported.
The resulting argv goes directly to pterm; shell variables, substitutions,
pipes, redirects, and globs are not evaluated. Quote executable paths containing
spaces too. `:Telescope pterm sessions` has the same behavior; `pterm grep` is unchanged.

A selected search result always wins, even if the prompt contains spaces or is
also another session's exact name. Enter connects to the selected session and
never passes the prompt as a command to it. With no selection, an exact existing
full name still reconnects (including legacy names containing spaces). Otherwise,
if the first name already exists and a command was supplied, an error keeps the
picker open; choose that session without a command or use a new name. Missing
executables also keep the picker open. An empty/whitespace-only prompt with no
selection closes without creating anything; with a selection, it reconnects.

New processes inherit the current working directory. On exit, the existing pterm
plugin removes its terminal buffer and reports the exit status; it does not start
a replacement shell. The pinned pterm backend may lose output from immediately
exiting commands (observed with `printf`, even with exit status 0). This change
leaves that backend limitation unchanged and is intended for interactive programs.

## Directory Structure

```
.
├── flake.nix         # Nix flake configuration
├── apps.nix          # Application definitions
├── overlays.nix      # Nix overlays
├── assets/           # Documentation images
├── tests/            # Test configuration directory
└── v2/               # Main configuration directory
    ├── default.nix   # Nix configuration entry point
    ├── fnl/          # Fennel source files
    ├── lua/autogen/  # Compiled Lua files
    ├── lua/          # Lua source files
    ├── npins/        # Nix package management for v2
    ├── tmpl/         # Template files
    └── vim/          # Vim script configurations
```
