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
  plugin = sources.qf-nvim;
  config = luaConfig (
    # lua
    ''
      local options = {
        auto_close = true,
        auto_follow = "prev",
        auto_follow_limit = 8,
        follow_slow = true,
        auto_open = true,
        auto_resize = true,
        max_height = 8,
        min_height = 5,
        wide = true,
        number = false,
        relativenumber = false,
        unfocus_close = false,
        focus_open = false,
      }
      require("qf").setup({ l = options, c = options, pretty = true, silent = false })
    ''
  );
}
