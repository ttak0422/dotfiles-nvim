{ pkgs, ... }:
let
  read = builtins.readFile;
in
with pkgs.vimPlugins;
rec {
  denops = {
    # TODO: use shared server
    package = denops-vim;
    preConfig = {
      language = "vim";
      code = ''
        " use latest
        let g:denops_server_addr = '0.0.0.0:32123'
      '';
    };
  };
  gin = {
    package = gin-vim;
    depends = [ denops ];
    postConfig = read ../lua/autogen/gin.lua;
    hooks.commands = [
      "Gin"
      "GinBuffer"
      "GinLog"
      "GinStatus"
      "GinDiff"
      "GinBrowse"
      "GinBranch"
    ];
    useDenops = true;
  };
  skk = {
    package = skkeleton;
    depends = [ denops ];
    postConfig = {
      language = "vim";
      code = read ../vim/skk.vim;
      args = {
        jisyo = "${pkgs.skk-dicts}/share/SKK-JISYO.L";
      };
    };
    hooks.events = [
      "InsertEnter"
      "CmdlineEnter"
    ];
    useDenops = true;
  };
  translate = {
    package = denops-translate-vim;
    depends = [ denops ];
    preConfig = read ../vim/translate.vim;
    hooks.commands = [ "Translate" ];
    useDenops = true;
  };
  ddu = {
    packages = [
      ddu-vim
      ddu-ui-ff
      ddu-ui-filter
      ddu-source-file
      ddu-source-file_rec
      ddu-source-rg
      ddu-source-ghq
      ddu-source-file_external
      ddu-source-mr
      ddu-filter-fzf
      ddu-filter-matcher_substring
      ddu-filter-matcher_hidden
      ddu-filter-sorter_alpha
      ddu-filter-converter_hl_dir
      # ddu-filter-converter_devicon
      ddu-filter-converter_display_word
      ddu-kind-file
      ddu-commands-vim
      ddu-filter-matcher_ignore_files
      ddu-filter-matcher_relative
    ];
    depends = [
      denops
      mr-vim
    ];
    extraPackages = with pkgs; [
      ripgrep
      fd
      fzf
      ghq
    ];
    postConfig = {
      language = "vim";
      code = read ../vim/ddu.vim;
      args.ts_config = ../denops/ddu.ts;
    };
    hooks.commands = [
      "Ddu"
      "DduRg"
      "DduRgLive"
    ];
    useDenops = true;
  };
}
