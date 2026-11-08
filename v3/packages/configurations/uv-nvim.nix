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
  plugin = sources.uv-nvim;
  config = luaConfig (
    # lua
    ''
      require("uv").setup({ keymaps = false })
    ''
  );
  extraPackages = with pkgs; [ uv ];
}
