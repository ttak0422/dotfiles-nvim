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
    # capture.vim

    ## 概要
    Ex コマンドの出力をバッファに表示する。

    ## 主な機能
    - メッセージ、マッピング、読み込み済みスクリプトを検索可能なバッファに取り込む。
    - 外部コマンドの出力も取り込む。

    ## 使い方
    `:Capture mes`、`:Capture scriptnames`、`:Capture map | map! | lmap` を実行する。外部コマンドには `:Capture !ls` を使える。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/tyru/capture.vim/blob/857ee11cfe1193948d3d45dcb8d511fded8533fb/README.md)
  '';

  plugin = sources.capture-vim;
}
