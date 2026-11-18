# v3 environments

Both profiles share `shared.nix`, core, and the same plugin definitions.

- `nix run .#v3/default`: terminal/default Neovim, including image.nvim and bg.nvim.
- `nix run .#v3/neovide`: Neovide with the dedicated Neovim wrapper and GUI settings.
- `nix build .#v3/neovide`: the dedicated `bin/nvim` wrapper, suitable for an existing Neovide with `--neovim-bin ./result/bin/nvim`.

The profiles currently retain the existing aarch64-darwin support boundary.
State is separated with `nvim-v3-default` and `nvim-v3-neovide` app names.
Neovide excludes the terminal-graphics image.nvim and terminal-color bg.nvim
from the dependency graph, including Obsidian's optional image dependency.
Image clipboard operations (img-clip.nvim) remain available.

Neovide settings live in `neovide-settings.nix`; shared core has no GUI settings.
The existing `v3/graph` output still describes the default profile.
Inline environment checks are part of each profile's Divine checks; Neovide
check output names have a `neovide-` prefix to avoid collisions.
