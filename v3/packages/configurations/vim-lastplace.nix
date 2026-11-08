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
  plugin = sources.vim-lastplace;
  config = luaConfig ({
    language = "vim";
    code = # vim
      ''
        let g:lastplace_ignore = "gitcommit,gitrebase,undotree,gitsigns-blame"
        let g:lastplace_ignore_buftype = "help,nofile,quickfix"
      '';
  });
}
