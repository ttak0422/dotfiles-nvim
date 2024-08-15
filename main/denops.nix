{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  treesitter = callPackage ./treesitter.nix { };
  snippet = callPackage ./snippet.nix { };
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
        " let g:denops_server_addr = '0.0.0.0:32123'
        let g:denops#deno = '${pkgs.deno}/bin/deno'
        let g:denops#server#deno_args = ['-q', '--no-lock', '-A', '--unstable-kv']
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
  ddc = {
    packages = [
      ddc-vim
      ddc-ui-pum
      # ddc-ui-native
      # denops-popup-preview-vim
      # denops-signature_help
      ddc-matcher_head
      ddc-path
      # ddc-source-vim
      ddc-sorter_rank
      ddc-source-around
      ddc-source-buffer
      ddc-source-buffer
      ddc-source-cmdline
      ddc-source-cmdline-history
      ddc-source-file
      ddc-source-input
      ddc-source-line
      ddc-source-lsp-setup
      ddc-source-nvim-lsp
      ddc-source-vsnip
      ddc-source-vsnip
      ddc-treesitter
      ddc-converter_remove_overlap
      ddc-converter_truncate
      ddc-filter-matcher_head
      ddc-filter_editdistance
      ddc-filter-converter_remove_overlap
      ddc-filter-converter_truncate_abbr
      ddc-filter-matcher_length
      ddc-filter-sorter_head
      ddc-filter-sorter_rank
      ddc-fuzzy
      ddc-matcher_length
      ddc-sorter_itemsize
    ];
    depends = [
      denops
      pum-vim
      treesitter.treesitter
      snippet.vsnip
      {
        package = ddc-previewer-floating;
        postConfig = read ../lua/autogen/ddc-previewer-floating.lua;
      }
    ];
    postConfig = {
      language = "vim";
      code = read ../vim/ddc.vim;
      args.ts_config = ../denops/ddc.ts;
    };
    hooks.events = [ "InsertEnter" ];
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
