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
  plugin = sources.lensline-nvim;
  config = luaConfig (
    # lua
    ''
      require("lensline").setup({
        debounce_ms = 1000,
        focused_debounce_ms = 200,
        profiles = {
          {
            name = "default",
            style = { placement = "inline", prefix = "", render = "focused" },
          },
        },
      })
    ''
  );
}
