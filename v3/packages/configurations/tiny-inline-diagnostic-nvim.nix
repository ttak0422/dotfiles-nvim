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
  plugin = sources.tiny-inline-diagnostic-nvim;
  config = luaConfig (
    # lua
    ''
      require("tiny-inline-diagnostic").setup({
        preset = "classic",
        transparent_bg = true,
        hi = {
          error = "GitSignsDelete",
          warn = "GitSignsAdd",
          info = "GitSignsChange",
          arrow = "NonText",
          background = "CursorLine",
          mixing_color = "None",
        },
        virt_texts = { priority = 2048 },
        options = {
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
          },
        },
      })
    ''
  );
}
