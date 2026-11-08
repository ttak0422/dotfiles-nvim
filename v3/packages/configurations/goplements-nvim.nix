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
    # Goplements.nvim

    ## 概要
    Go の構造体とインターフェースの実装関係を表示する。

    ## 主な機能
    - インターフェースの実装型を定義の横に表示する。
    - 構造体が実装するインターフェースを表示する。

    ## 使い方
    Go ファイルでは自動的に有効になる。`:GoplementEnable`、`:GoplementDisable`、`:GoplementToggle` で制御できる。

    ## 要件
    Neovim 0.9.4 以上と gopls を使う LSP 設定。nvim-treesitter の Go パーサーは任意の高速化用。

    ## 出典
    [固定バージョンの README](https://github.com/maxandron/goplements.nvim/blob/1750ace64d42efcbc1ce36eef848a3cea5f88c79/README.md)
  '';

  plugin = sources.goplements-nvim;
  config = luaConfig (
    # lua
    ''
      require("goplements").setup()
    ''
  );
}
