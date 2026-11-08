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
    # Lush

    ## 概要
    Neovim のカラースキーム作成を支援する。

    ## 主な機能
    - 編集しながら配色を確認し、色の操作や構造化を行う。
    - 作成した配色を Lua テーブルや Vimscript などへ書き出せる。

    ## 使い方
    `:LushRunTutorial` で対話式チュートリアルを開始する。作成・拡張・書き出しの手順は README の各ガイドを参照する。

    ## 要件
    開発ツールとしての使用には Neovim 0.7 以上。トゥルーカラー表示には `termguicolors` を有効にする。

    ## 出典
    [固定バージョンの README](https://github.com/rktjmp/lush.nvim/blob/9c60ec2279d62487d942ce095e49006af28eed6e/README.md)
  '';

  plugin = sources.lush-nvim;
  lazy = true;
  # Keep all exported commands available before the first load.
  onCommands = [
    "Lushify"
    "LushRunTutorial"
    "LushImport"
  ];
  onModules = [ "lush" ];
}
