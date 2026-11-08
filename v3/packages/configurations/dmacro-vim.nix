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
  plugin = sources.dmacro-vim;
  config = luaConfig ({
    code = # vim
      ''
        inoremap <C-q> <Plug>(dmacro-play-macro)
        nnoremap <C-q> <Plug>(dmacro-play-macro)
      '';
    language = "vim";
  });
}
