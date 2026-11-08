{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  plugin = sources.promise-async;
  doc = ''
    # promise-async

    ## 概要
    JavaScript の Promise / async に近い非同期処理を Lua に提供する。

    ## 主な機能
    - Promise の解決・拒否・連鎖と async / await。
    - Neovim や独自イベントループへの対応。

    ## 使い方
    `require("async")` で関数を包み、返された Promise の `:thenCall()` で結果を処理する。async 関数内の `await()` で完了を待てる。

    ## 要件
    Lua 5.1 以降。既定のイベントループは Luv で、互換インターフェースを実装した別ループも利用可能。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/kevinhwang91/promise-async/blob/119e8961014c9bfaf1487bf3c2a393d254f337e2/README.md)
  '';
}
