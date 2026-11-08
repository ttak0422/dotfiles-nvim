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
    # cmp_luasnip

    ## 概要
    LuaSnip のスニペットを nvim-cmp の補完候補として提供する。

    ## 主な機能
    - スニペットの `show_condition` による候補の絞り込みに対応する。
    - 自動展開スニペットを候補へ含めるかを設定できる。

    ## 使い方
    nvim-cmp の `sources` に `{ name = "luasnip" }` を登録し、`snippet.expand` で `require("luasnip").lsp_expand(args.body)` を呼ぶ。

    ## 要件
    LuaSnip と nvim-cmp が必要。

    ## 出典
    [固定バージョンの README](https://github.com/saadparwaiz1/cmp_luasnip/blob/98d9cb5c2c38532bd9bdb481067b20fea8f32e90/README.md)
  '';

  plugin = sources.cmp_luasnip;
  dependPlugins = [
    definitions.nvim-cmp
    definitions.LuaSnip
  ];
}
