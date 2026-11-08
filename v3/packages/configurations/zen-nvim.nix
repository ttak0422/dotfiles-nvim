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
    # zen.nvim

    ## 概要
    グレースケールを中心に控えめな差し色を使うカラースキーム。

    ## 主な機能
    - ライト・ダークの配色と Tree-sitter ハイライトを提供する。
    - 配色パレットやテーマ色、各構文のスタイルを変更できる。

    ## 使い方
    `require("zen").setup()` で設定し、`vim.cmd.colorscheme("zen")` で適用する。`variant = "auto"` は `vim.o.background` に追従する。

    ## 要件
    Neovim 0.8 以上とトゥルーカラー対応の端末。

    ## 出典
    [固定バージョンの README](https://github.com/nendix/zen.nvim/blob/e552fc12f847113a05589981d02f69c953d6d3e9/README.md)
  '';

  plugin = sources.zen-nvim;
  config = luaConfig (
    # lua
    ''
      require("zen").setup({})
    ''
  );
}
