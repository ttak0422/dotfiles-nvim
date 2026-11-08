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
  plugin = sources.translate-nvim;
  extraPackages = [ pkgs.curl ];
  config = luaConfig (
    # lua
    ''
      require("translate").setup({
        preset = {
          output = {
            floating = { zindex = 150 },
            split = {
              position = "bottom",
              min_size = 5,
              max_size = 0.5,
              name = "translate://output",
              filetype = "translate",
              append = false,
            },
          },
        },
        default = { output = "split" },
      })
    ''
  );
}
