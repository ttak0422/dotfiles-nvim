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
    # Showkeys

    ## 概要
    入力したキーを画面上に表示する、Neovim 用の操作紹介ツール。

    ## 主な機能
    - 画面収録などでキー操作を表示。
    - 表示時間や最大キー数を設定。

    ## 使い方
    `:ShowkeysToggle` で表示を切り替える。README の設定例は `timeout` と `maxkeys` を調整する。

    ## 要件
    最低 Neovim バージョン・追加依存は README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/nvzone/showkeys/blob/cb0a50296f11f1e585acffba8c253b9e8afc1f84/README.md)
  '';
  plugin = sources.showkeys;
  dependPlugins = [
    definitions.volt
  ];
}
