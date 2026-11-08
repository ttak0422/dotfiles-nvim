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
    # nvim-dap-ui

    ## 概要
    nvim-dap のデバッグ情報を専用ウィンドウにまとめる UI。

    ## 主な機能
    - スコープ・ブレークポイント・スタックなどをレイアウト表示。
    - 要素のフローティング表示と式の評価。

    ## 使い方
    `require("dapui").setup()` で設定し、`open()` / `close()` / `toggle()` でウィンドウを操作する。

    ## 要件
    nvim-dap、nvim-nio。既定アイコンには codicons 対応フォントが推奨される。最低 Neovim バージョンは README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/rcarriga/nvim-dap-ui/blob/cc9dd33aade7f20bae414d0cba163bc60d4d4b43/README.md)
  '';
  plugin = sources.nvim-dap-ui;
  dependPlugins = [
    definitions.nvim-dap
    definitions.nvim-nio
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("dapui").setup({
        icons = {
          expanded = "▾",
          collapsed = "▸",
          current_frame = "▸",
        },
      })
    ''
  );
}
