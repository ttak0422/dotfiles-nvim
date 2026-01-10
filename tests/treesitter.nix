{
  pkgs,
  ...
}:
{
  package = pkgs.neovim-unwrapped;
  extraLuaPackages = _: [ ];
  extraPython3Packages = _: [ ];
  eager = with pkgs.vimPlugins.tests; {
    treesitter = {
      packages = [ nvim-treesitter.withAllGrammars ];
      startupConfig = /* lua */ ''
        require("nvim-treesitter").setup({
          install_dir = "${builtins.elemAt nvim-treesitter.withAllGrammars.dependencies 0}"
        })
      '';
    };
  };
}
