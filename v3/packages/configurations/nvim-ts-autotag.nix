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
  plugin = sources.nvim-ts-autotag;
  dependPlugins = [
    definitions.nvim-treesitter
  ];
  config = luaConfig (
    # lua
    ''
      require("nvim-ts-autotag").setup({
        filetypes = { "javascript", "typescript", "jsx", "tsx", "vue", "html" },
      })
    ''
  );
}
