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
  plugin = sources.vim-sonictemplate;
  preConfig = luaConfig (
    let
      template = pkgs.stdenv.mkDerivation {
        pname = "sonictemplate";
        version = "custom";
        src = ../support/sonic;
        installPhase = ''
          mkdir $out
          cp -r ./* $out
        '';
      };
    in
    # lua
    ''
      vim.g.sonictemplate_vim_template_dir = "${template}"
      vim.g.sonictemplate_key = 0
      vim.g.sonictemplate_intelligent_key = 0
      vim.g.sonictemplate_postfix_key = 0
    ''
  );
}
