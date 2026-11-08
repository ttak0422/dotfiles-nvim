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
    # plenary.nvim

    ## 概要
    Neovim プラグイン向けの共通 Lua ユーティリティー集。

    ## 主な機能
    - 非同期処理、プロセス実行、パス・ディレクトリー操作を提供する。
    - 簡易な Busted 形式のテスト実行を提供する。

    ## 使い方
    `require("plenary.async")`、`require("plenary.job")`、`require("plenary.path")` など必要なモジュールを読み込む。テスト用には `:PlenaryBustedDirectory` や `<Plug>PlenaryTestFile` を提供する。

    ## 要件
    Neovim の関数に依存し、Neovim 外では使えない。README は近年の版を対象とし、具体的な最低版は未記載。積極的な保守終了とアーカイブ予定の告知がある。

    ## 出典
    [固定バージョンの README](https://github.com/nvim-lua/plenary.nvim/blob/74b06c6c75e4eeb3108ec01852001636d85a932b/README.md)
  '';

  plugin = sources.plenary-nvim;
}
