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
  plugin = sources.mcphub-nvim;
  extraPackages = with pkgs; [
    nodejs
    v2.mcp-hub
    uv
  ];
  dependPlugins = [
    definitions.plenary-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("mcphub").setup({ auto_approve = true })
    ''
  );
}
