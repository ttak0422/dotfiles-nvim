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
  plugin = sources.switch-vim;
  preConfig = luaConfig ({
    language = "vim";
    code = # vim
      ''
        let g:switch_mapping = '-'
      '';
  });
}
