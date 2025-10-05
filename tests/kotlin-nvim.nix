{
  pkgs,
  ...
}:
{
  package = pkgs.neovim-unwrapped;
  lazy = with pkgs.vimPlugins.tests; {
    videre = {
      package = kotlin-nvim;
      postConfig = ''
        vim.env.KOTLIN_LSP_DIR = "${pkgs.v2.kotlin-lsp}/libexec/kotlin-lsp"
        require("kotlin").setup({})
      '';
      hooks.fileTypes = [ "kotlin" ];
    };
  };
}
