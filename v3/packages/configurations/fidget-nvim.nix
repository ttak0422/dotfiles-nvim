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
  plugin = sources.fidget-nvim;
  doc = ''
    # Fidget

    ## 概要
    Neovim の通知と LSP の進捗を控えめなウィンドウで表示する。

    ## 主な機能
    - LSP の進捗メッセージとアニメーション表示。
    - 通知 API、履歴表示、通知の消去。

    ## 使い方
    `require("fidget").setup()` で設定し、`require("fidget").notify(message)` で通知する。`:Fidget history` で履歴を確認し、`:Fidget clear` で表示中の通知を消す。

    ## 要件
    Neovim 0.11.3。LSP 進捗の表示には `$/progress` 対応サーバーの設定が必要。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/j-hui/fidget.nvim/blob/9e0201673e08e997e7cf52afca5565c70bd117f3/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("fidget").setup({})
    ''
  );
}
