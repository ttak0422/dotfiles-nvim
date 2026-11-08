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
    # Grey

    ## 概要
    明るい灰色の背景を使う低コントラストのカラースキーム。

    ## 主な機能
    - 色数を抑えた Lua 製の配色を提供する。
    - Telescope 用の `grey` レイアウト拡張を同梱する。

    ## 使い方
    README の Telescope 連携例では `layout_strategy = "grey"` を設定し、`telescope.load_extension("grey")` を呼ぶ。配色の有効化コマンド自体は README に未記載。

    ## 要件
    Neovim 0.7.0 以上とトゥルーカラー対応。`laststatus=3` を推奨するが、その設定には Neovim 0.8 以上を使う。

    ## 出典
    [固定バージョンの README](https://github.com/yorickpeterse/nvim-grey/blob/480dab4cb01226762fac2aef3413064559a54baa/README.md)
  '';

  plugin = sources.nvim-grey;
}
