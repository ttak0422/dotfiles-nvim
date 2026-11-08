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
  plugin = sources.nvim-spectre;
  dependPlugins = [
    definitions.plenary-nvim
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("spectre").setup({
        default = {
          find = { cmd = "rg", options = {} },
          replace = { cmd = "sd" },
        },
        color_devicons = false,
        is_block_ui_break = false,
        live_update = false,
      })
    ''
  );
  extraPackages = with pkgs; [
    ripgrep
    sd
  ];
}
