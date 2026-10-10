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
The terminal suite also checks command arguments, session reuse, and process exits
with local fixture programs and an isolated pterm socket directory.

## Terminal

`:Terminal` opens terminal slot 0 in the current tab, shared with `Ctrl-0`.
On first creation, `:Terminal claude` starts that executable directly inside pterm
instead of the default `$SHELL`. Any executable and arguments can be used.
Use `:1Terminal command args...` through `:9Terminal ...` for another slot;
`Ctrl-0` through `Ctrl-9` continue to toggle the corresponding terminals.

Arguments follow Neovim user-command (`<f-args>`) syntax: escape a space with `\ `,
and a literal backslash with `\\`. Quotes are literal characters, not grouping:
`:Terminal printf %s hello\ world` passes `hello world` as one argument.
Shell substitutions, pipes, redirects, and glob expansion are not evaluated.
Executable and file completion is available before the first invocation.

Command arguments are accepted only for an unused slot. An already allocated slot
or an existing pterm session rejects a new command; open it without arguments to
reuse it, or choose another slot. The first process inherits Neovim's current
working directory. On exit, the terminal retains its output and exit status
(`close_on_exit = false`); it does not start a shell. Reopening that buffer does
not rerun the command. Deleting the completed buffer allows the slot to be
recreated with its original command through the existing Toggleterm behavior.

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
