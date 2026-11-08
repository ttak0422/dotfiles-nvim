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
    # Neogen

    ## 概要
    Tree-sitter を使ってコードの注釈を生成する。

    ## 主な機能
    - 関数・クラスなどに対応する注釈を複数言語・規約で生成する。
    - スニペットエンジンとの連携で注釈の入力箇所へ移動する。

    ## 使い方
    `:Neogen`、`:Neogen func`、`:Neogen class` または `require("neogen").generate()` を使う。`snippet_engine = "luasnip"` は README にある連携設定で、この定義でも使用する。

    ## 要件
    README 冒頭は Neovim 0.10.0 以上を示す。対象言語の Tree-sitter パーサーが必要。LuaSnip 連携には LuaSnip を使う。

    ## 出典
    [固定バージョンの README](https://github.com/danymat/neogen/blob/23e7e9f883d01289ebd90e98025acc860ea26366/README.md)
  '';

  plugin = sources.neogen;
  dependPlugins = [
    definitions.LuaSnip
  ];
  config = luaConfig (
    # lua
    ''
      require("neogen").setup({ snippet_engine = "luasnip" })
    ''
  );
}
