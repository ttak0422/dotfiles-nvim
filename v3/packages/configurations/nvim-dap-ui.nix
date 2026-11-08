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
  plugin = sources.nvim-dap-ui;
  dependPlugins = [
    definitions.nvim-dap
    definitions.nvim-nio
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("dapui").setup({
        icons = {
          expanded = "▾",
          collapsed = "▸",
          current_frame = "▸",
        },
      })
    ''
  );
}
