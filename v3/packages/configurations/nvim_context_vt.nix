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
  plugin = sources.nvim_context_vt;
  config = luaConfig (
    # lua
    ''
      require("nvim_context_vt").setup({ prefix = "", priority = 10 })
    ''
  );
}
