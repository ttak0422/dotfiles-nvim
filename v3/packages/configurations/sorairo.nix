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
    # sorairo

    ## 概要
    プロジェクターを使ったライブコーディング向けのカラースキーム。

    ## 主な機能
    - 明るい背景と暗い背景に対応。
    - 代表的なハイライトを scratch buffer で確認。

    ## 使い方
    `termguicolors` を有効にして `:colorscheme sorairo` を実行する。暗い表示は先に `background=dark` を設定する。`:SorairoPreview` で見本を開ける。

    ## 要件
    README の使用例は `termguicolors` を有効にする。最低バージョンは未記載。実験段階で破壊的変更があり得ると記載されている。

    ## 出典
    [固定リビジョンの README](https://github.com/ttak0422/sorairo/blob/674fce68dee030ad0645ca766c12a242e817b077/README.md)
  '';
  plugin = sources.sorairo;
  config = ''vim.cmd.colorscheme("sorairo")'';
}
