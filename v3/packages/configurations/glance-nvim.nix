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
  plugin = sources.glance-nvim;
  dependPlugins = [
    definitions.trouble-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("glance").setup({
        border = { enable = true, top_char = "━", bottom_char = "━" },
        folds = { fold_closed = "▸", fold_open = "▾", folded = true },
        use_trouble_qf = true,
      })
    ''
  );
}
