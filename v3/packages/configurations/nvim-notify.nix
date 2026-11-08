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
  plugin = sources.nvim-notify;
  doc = ''
    # nvim-notify

    ## 概要
    表示方法を調整できる Neovim の通知マネージャー。

    ## 主な機能
    - 通知レベル、描画スタイル、アニメーションの設定。
    - 既存通知の更新と通知履歴の参照。

    ## 使い方
    `require("notify")("message")` で通知する。`vim.notify = require("notify")` とすると他プラグインからの通知にも利用できる。設定は `require("notify").setup()` に渡す。

    ## 要件
    アイコンを表示できるフォントと 24-bit color。`termguicolors` を有効にする。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/rcarriga/nvim-notify/blob/8701bece920b38ea289b457f902e2ad184131a5d/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      local notify = require("notify")
      notify.setup({
        timeout = 2500,
        render = "default",
        top_down = true,
        stages = "static",
        background_colour = "#000000",
      })
      vim.notify = notify
    ''
  );
}
