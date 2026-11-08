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
    # term-gf.nvim

    ## 概要
    端末内に表示されたファイル名からファイルへ移動する。

    ## 主な機能
    - 端末上のファイル名に対する `gf` 移動を提供する。

    ## 使い方
    端末内のファイル名へカーソルを置いて `gf` を使う。README に追加設定や詳細なコマンドの記載はない。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/yutkat/term-gf.nvim/blob/be02449c0edbe24d624ae8347561f255056019ca/README.md)
  '';

  plugin = sources.term-gf-nvim;
}
