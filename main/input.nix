{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  # snippet = callPackage ./snippet.nix { };
  treesitter = callPackage ./treesitter.nix { };
in
with pkgs.vimPlugins;
{
  # cmp = {
  #   packages = [
  #     nvim-cmp
  #     cmp-buffer
  #     cmp-cmdline
  #     cmp-cmdline-history
  #     cmp-nvim-lsp
  #     cmp-path
  #     cmp_luasnip
  #   ];
  #   depends = [ snippet.LuaSnip ];
  #   postConfig =
  #     ''
  #       require("morimo").load("cmp")
  #       dofile('${cmp-buffer}/after/plugin/cmp_buffer.lua')
  #       dofile('${cmp-cmdline}/after/plugin/cmp_cmdline.lua')
  #       dofile('${cmp-cmdline-history}/after/plugin/cmp_cmdline_history.lua')
  #       dofile('${cmp-nvim-lsp}/after/plugin/cmp_nvim_lsp.lua')
  #       dofile('${cmp-path}/after/plugin/cmp_path.lua')
  #       dofile('${cmp_luasnip}/after/plugin/cmp_luasnip.lua')
  #     ''
  #     + read ../lua/autogen/cmp.lua;
  #   hooks.events = [ "LspAttach" ];
  # };
  treesj = {
    package = pkgs.vimPlugins.treesj;
    depends = [ treesitter.treesitter ];
    postConfig = read ../lua/autogen/treesj.lua;
    hooks.modules = [ "treesj" ];
  };
  autopairs = {
    package = nvim-autopairs;
    depends = [ treesitter.treesitter ];
    postConfig = read ../lua/autogen/autopairs.lua;
    hooks.events = [ "InsertEnter" ];
  };
  better-escape = {
    package = better-escape-nvim;
    postConfig = read ../lua/autogen/better-escape.lua;
    hooks.events = [ "InsertEnter" ];
  };
  comment = {
    package = Comment-nvim;
    postConfig = read ../lua/autogen/comment.lua;
    hooks.events = [
      "InsertEnter"
      "CursorMoved"
    ];
  };
  indent-o-matic = {
    package = pkgs.vimPlugins.indent-o-matic;
    postConfig = read ../lua/autogen/indent-o-matic.lua;
    hooks.events = [ "CursorMoved" ];
  };
  tabout = {
    package = tabout-nvim;
    depends = [ treesitter.treesitter ];
    postConfig = read ../lua/autogen/tabout.lua;
    # hook on load vsnip
    # hooks.events = [ "InsertEnter" ];
  };
  undotree = {
    package = pkgs.vimPlugins.undotree;
    preConfig = {
      language = "vim";
      code = read ../vim/undotree.vim;
    };
    hooks.commands = [ "UndotreeToggle" ];
  };
}
