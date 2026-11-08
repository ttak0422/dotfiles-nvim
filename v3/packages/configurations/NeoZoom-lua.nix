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
  plugin = sources.NeoZoom-lua;
  config = luaConfig (
    # lua
    ''
      require("neo-zoom").setup({
        winopts = { offset = { width = 180, height = 0.9 }, border = "single" },
        exclude_buftypes = {},
        presets = {
          {
            filetypes = { "dapui_.*", "dap-repl" },
            winopts = { offset = { top = 0.02, left = 0.26, width = 0.74, height = 0.6 } },
          },
        },
        callbacks = {
          function()
            vim.cmd("hi link NeoZoomFloatBg Normal")
            vim.cmd("hi link NeoZoomFloatBorder Normal")
            vim.cmd("set winhl=Normal:NeoZoomFloatBg,FloatBorder:NeoZoomFloatBorder")
          end,
        },
      })
    ''
  );
}
