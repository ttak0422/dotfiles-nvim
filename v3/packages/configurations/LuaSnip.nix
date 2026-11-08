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
    # LuaSnip

    ## 概要
    Lua で定義できる Neovim 用スニペットエンジン。

    ## 主な機能
    - タブストップ、選択肢、動的なスニペットを扱う。
    - LSP・VS Code・SnipMate 形式のスニペットを読み込む。

    ## 使い方
    `require("luasnip").add_snippets(filetype, snippets)` で登録し、`expand()` や `jump(1)` / `jump(-1)` で展開・移動する。VS Code 形式は `require("luasnip.loaders.from_vscode").lazy_load()` で読み込める。

    ## 要件
    Neovim 0.9 以上。LSP スニペットの変換には `jsregexp` が必要。nvim-cmp との連携には別途 `cmp_luasnip` を使う。

    ## 出典
    [固定バージョンの README](https://github.com/L3MON4D3/LuaSnip/blob/0abc8f390b278c3b4aabc4c004ac8a088b65cf24/README.md)
  '';

  plugin = sources.LuaSnip;
  config = luaConfig (
    # lua
    ''
      require("luasnip").setup({})
    ''
  );
}
