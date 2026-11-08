{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  doc = ''
    # graph_view_yaml_parser

    ## 概要
    videre.nvim で使う Neovim 用 YAML パーサー。

    ## 主な機能
    - YAML の解析を videre.nvim に提供する。

    ## 使い方
    videre.nvim と組み合わせて利用する。README に単独のコマンドや API の利用例は記載されていない。

    ## 要件
    README は videre.nvim 向けと明記している。最低バージョンや追加依存の詳細は未記載。

    ## 出典
    [固定バージョンの README](https://github.com/Owen-Dechow/graph_view_yaml_parser/blob/ecc5ba0a0b8c3a6eb3e7fa5a2caeeee2263729c3/README.md)
  '';

  plugin = sources.graph_view_yaml_parser;
}
