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
    # nvim-treesitter-textobjects

    ## 概要
    Tree-sitter の構文に沿ってテキストの選択・移動・交換を行う。

    ## 主な機能
    - 関数・クラスなどのクエリーに対応する範囲を選択する。
    - 次・前の構文要素への移動や引数の交換を行う。

    ## 使い方
    `require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")` などをキーに割り当てる。`setup()` の `select.lookahead` と `move.set_jumps` で先読みとジャンプリストを設定する。

    ## 要件
    README は最新安定版または nightly の Neovim を推奨する。Tree-sitter の構文解析を使用する。最低バージョン番号は README に未記載。

    ## 出典
    [固定バージョンの README](https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/5c7b0263797dfd1bd6202f2b219f3b53a80b2187/README.md)
  '';

  plugin = sources.nvim-treesitter-textobjects;
  dependPlugins = [
    definitions.nvim-treesitter
  ];
  config = luaConfig ''
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })
  '';
}
