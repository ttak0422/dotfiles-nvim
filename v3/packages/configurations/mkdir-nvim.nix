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
    # mkdir.nvim

    ## 概要
    ファイル保存時に不足している親ディレクトリーを自動作成する。

    ## 主な機能
    - Linux の `mkdir -p` のように未作成の階層を補う。

    ## 使い方
    追加設定は不要。存在しないディレクトリー配下のファイルを保存すると動作する。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/jghauser/mkdir.nvim/blob/c55d1dee4f099528a1853b28bb28caa802eba217/README.md)
  '';

  plugin = sources.mkdir-nvim;
}
