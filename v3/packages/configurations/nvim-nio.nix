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
    # nvim-nio

    ## 概要
    Lua coroutine を使い、Neovim の非同期 IO を書くためのライブラリ。

    ## 主な機能
    - タスク・同期制御プリミティブを提供。
    - LSP、ファイル、プロセス、libuv、UI の非同期 API。

    ## 使い方
    `local nio = require("nio")` の後、`nio.run(function() ... end)` でタスクを開始する。非同期関数はタスクの中から呼ぶ。設定オプションはない。

    ## 要件
    最低 Neovim バージョン・必須の追加依存は README 未記載。型補完用の neodev.nvim は推奨に留まる。

    ## 出典
    [固定リビジョンの README](https://github.com/nvim-neotest/nvim-nio/blob/edcc181a875301dd21840189aa2f2f9ad69fc172/README.md)
  '';
  plugin = sources.nvim-nio;
}
