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
    # cmp-cmdline

    ## 概要
    nvim-cmp に Vim コマンドラインの補完候補を提供する。

    ## 主な機能
    - コマンドモードで補完する。
    - `ignore_cmds` で候補取得を除外するコマンドを指定する。

    ## 使い方
    `cmp.setup.cmdline(":", ...)` の `sources` に `{ name = "cmdline" }` を登録する。README の検索補完例で使う `buffer` は別の補完ソース。

    ## 要件
    nvim-cmp が必要。README の `/` 検索補完例には別途 cmp-buffer が必要。

    ## 出典
    [固定バージョンの README](https://github.com/hrsh7th/cmp-cmdline/blob/d126061b624e0af6c3a556428712dd4d4194ec6d/README.md)
  '';

  plugin = sources.cmp-cmdline;
  dependPlugins = [
    definitions.nvim-cmp
  ];
}
