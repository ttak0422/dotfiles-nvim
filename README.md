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

