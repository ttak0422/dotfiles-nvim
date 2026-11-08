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
    # TreeSJ

    ## 概要
    配列やオブジェクトなどのコードを複数行・単一行へ変換する。

    ## 主な機能
    - Tree-sitter で対象ブロックと埋め込み言語を認識する。
    - 再帰的な整形、カーソル位置の追従、ドットリピートに対応する。

    ## 使い方
    `:TSJToggle` で切り替え、`:TSJSplit` で分割、`:TSJJoin` で結合する。Lua では `require("treesj").toggle()` / `split()` / `join()` を使う。この定義は既定キーを無効にしている。

    ## 要件
    Neovim 0.9 以上。構文解析には対象言語の Tree-sitter パーサーを使い、導入手段としての nvim-treesitter は任意。

    ## 出典
    [固定バージョンの README](https://github.com/Wansmer/treesj/blob/9f349ba62c524f065d6f43254d731ddf8319b9bf/README.md)
  '';

  plugin = sources.treesj;
  config = luaConfig (
    # lua
    ''
      require("treesj").setup({ use_default_keymaps = false })
    ''
  );
}
