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
  plugin = sources.nfnl;
  dependPlugins = [
    definitions.conjure
  ];
  extraPackages = with pkgs; [
    sd
    fd
  ];
}
