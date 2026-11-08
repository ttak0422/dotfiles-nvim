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
  plugin = sources.goto-preview;
  config = luaConfig (
    # lua
    ''
      require("goto-preview").setup({
        height = 20,
        width = 120,
        zindex = 90,
        border = "single",
        default_mappings = false,
        resizing_mappings = false,
      })
    ''
  );
}
