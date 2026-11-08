{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  emptyPlugin,
  inputs',
}:
with sources;
with definitions;
{
  plugin = vim-lastplace;
  config = luaConfig ({
    language = "vim";
    code = # vim
      ''
        let g:lastplace_ignore = "gitcommit,gitrebase,undotree,gitsigns-blame"
        let g:lastplace_ignore_buftype = "help,nofile,quickfix"
      '';
  });
  doc = "Enabled v2/default lastplace configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
