{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
with sources;
{
  plugin = pkgs.vimPlugins.rustaceanvim.overrideAttrs {
    runtimeDeps = with pkgs; [
      rust-analyzer-unwrapped
    ];
  };
  config = luaConfig (
    # lua
    ''
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              files = {
                excludeDirs = { ".direnv", ".git", ".venv", "bin", "node_modules", "target" },
              },
            },
          },
        },
      }
    ''
  );
}
