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
    # volt

    ## 概要
    Neovim 内で対話型 UI を作るためのプラグイン。

    ## 主な機能
    - Menu、Minty、Typr などの UI 基盤として利用される。

    ## 使い方
    固定リビジョンの README は利用例の紹介のみで、コマンド・API の使い方は未記載。利用側プラグインの手順を参照する。

    ## 要件
    README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/nvzone/volt/blob/4351c5cd790a0d39491c4d5c75dd62d7db3d3414/README.md)
  '';
  plugin = sources.volt;
}
