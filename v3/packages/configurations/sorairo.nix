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
  plugin = sources.sorairo;
  config = ''vim.cmd.colorscheme("sorairo")'';
}
