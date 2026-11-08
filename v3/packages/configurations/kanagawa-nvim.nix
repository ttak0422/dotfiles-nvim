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
  plugin = sources.kanagawa-nvim;
  doc = ''
    # KANAGAWA.nvim

    ## 概要
    葛飾北斎の絵の色彩をもとにした Neovim のカラースキーム。

    ## 主な機能
    - Tree-sitter と多数のプラグインのハイライト対応。
    - テーマ・配色の調整と Lua バイトコードへの任意コンパイル。

    ## 使い方
    `:colorscheme kanagawa` で適用する。変更する場合は先に `require("kanagawa").setup()` を呼ぶ。コンパイルを有効にした場合は設定変更後に `:KanagawaCompile` を実行する。

    ## 要件
    README は最新 Neovim と truecolor 対応端末を要求。undercurl 対応は任意。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/rebelot/kanagawa.nvim/blob/bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3/README.md)
  '';
}
