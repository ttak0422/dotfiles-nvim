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
  doc = ''
    # NeoZoom.lua

    ## 概要
    現在のウィンドウをフローティング表示に切り替え、作業対象に集中するためのプラグイン。

    ## 主な機能
    - タブ内のウィンドウ配置を保ったズーム。
    - filetype ごとのウィンドウ設定とコールバック。

    ## 使い方
    `require("neo-zoom").setup(...)` で表示を設定し、`:NeoZoomToggle` または `require("neo-zoom").neo_zoom()` で切り替える。

    ## 要件
    最低バージョン・追加依存は README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/nyngwang/NeoZoom.lua/blob/c97a0197548c1e9b559e4fa41ab3f7782c93e613/README.md)
  '';
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
