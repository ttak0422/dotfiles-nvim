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

## Run v3 with your own Neovim

On Apple Silicon macOS, run this from the repository with Nix and Neovim 0.12
installed. Use a regular `nvim` executable rather than the `v3/default` wrapper;
if the wrapper is already on your PATH, replace `nvim` below with the full
path to your own binary.

```sh
(bundle=$(nix build '.#v3/bundle' --no-link --print-out-paths) && NVIM_APPNAME=nvim-v3-default NVIM_V3_INIT="$bundle/init.lua" PATH="$PATH:/usr/bin" nvim -u "$bundle/init.lua")
```

Nix still prepares the pinned configuration, plugins and helper tools. The
command starts your local Neovim, not the flake's editor wrapper. It shares the
`nvim-v3-default` data and state directories with `nix run '.#v3/default'`.
Use a different `NVIM_APPNAME` if you want separate state.
For the most predictable compatibility, match the Neovim version pinned by
the flake.

## v3/default dependency graph

The complete v3 profile and graph are available on `aarch64-darwin` (Apple Silicon
macOS), matching the profile's platform-specific plugins and tools.

```sh
# Generate a self-contained HTML file in the current directory.
nix run '.#v3/graph'

# Choose a new output path (parent directory must already exist).
nix run '.#v3/graph' -- ./my-nvim-graph.html

# Or build the immutable HTML directly, without copying it.
nix build '.#v3/graph' --no-link --print-out-paths
```

The app writes `v3-default-graph.html` by default, prints its path, and refuses to
overwrite an existing file or symlink. Open the HTML in a browser to search,
zoom, or inspect inline plugin documentation. It works offline after building;
Nix may need network access to fetch inputs and build dependencies. The app does
not start Neovim or open a browser.

The graph uses exactly the same pinned package set and configuration as
`v3/default`. It describes configured dependencies and load units, not a live
runtime trace. The HTML includes inline docs, Nix store paths, and declaration
locations; review it before sharing. Graphviz is a build-time dependency only.
