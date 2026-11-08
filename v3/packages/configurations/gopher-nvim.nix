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
  plugin = sources.gopher-nvim;
  config = luaConfig (
    # lua
    ''
      require("gopher").setup()
    ''
  );
  extraPackages = with pkgs; [
    go
    gomodifytags
    gotests
    iferr
    impl
  ];
  doc = "Go development commands and helper tools.";
}
