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
  plugin = pkgs.vimPlugins.markdown-preview-nvim;
}
