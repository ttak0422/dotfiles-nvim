{
  pkgs,
  ...
}:
{
  package = pkgs.neovim-unwrapped;

  extraPackages = with pkgs; [
    vscode-langservers-extracted
  ];

  extraConfig = ''
    vim.lsp.enable({"jsonls"})
  '';

  eager = with pkgs.vimPlugins.tests; {
    plenary.package = plenary-nvim;
    videre = {
      package = videre-nvim;
      startupConfig = ''
        require("videre").setup({})
      '';
    };
    none-ls = {
      package = none-ls-nvim;
      startupConfig = ''
        local null_ls = require("null-ls")
        local formatting = null_ls.builtins.formatting
        null_ls.setup({
          sources = {
            formatting.biome,
          },
        })
      '';
      extraPackages = with pkgs; [ biome ];
    };
  };
}
