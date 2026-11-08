{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  plugin = sources.graph_view_toml_parser;
  doc = ''
    # graph_view_toml_parser

    ## 概要
    toml2lua の派生版で、videre.nvim 用の TOML パーサーとして利用する Neovim プラグイン。

    ## 主な機能
    - TOML パーサーを videre.nvim 向けに提供。

    ## 使い方
    videre.nvim から利用するためのパーサー。個別のコマンドや API の使い方は README に未記載。

    ## 要件
    実行時のバージョン要件や依存一覧は README に未記載。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/Owen-Dechow/graph_view_toml_parser/blob/e52ddcbae563c924a19faf998f862ae61d13a777/README.md)
  '';
}
