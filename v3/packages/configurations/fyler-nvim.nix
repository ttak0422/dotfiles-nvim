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
  plugin = sources.fyler-nvim;
  dependPlugins = [
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("fyler").setup({
        close_on_select = true,
        icon_provider = "nvim_web_devicons",
        win = {
          border = "single",
          kind = "replace",
          buf_opts = {},
          win_opts = { number = false, relativenumber = false },
        },
      })
    ''
  );
}
