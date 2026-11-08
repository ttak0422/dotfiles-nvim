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
  plugin = sources.winresizer;
  preConfig = luaConfig ({
    language = "vim";
    code = ''
      let g:winresizer_start_key = '<C-w>e'
    '';
  });
}
