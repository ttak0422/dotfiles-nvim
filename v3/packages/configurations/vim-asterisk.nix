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
    # vim-asterisk

    ## 概要
    Vim の `*` 検索操作を拡張する。

    ## 主な機能
    - カーソルを動かさない検索とビジュアル選択テキストの検索に対応する。
    - smartcase を考慮し、一致位置間でカーソル位置を保つ設定を提供する。

    ## 使い方
    `<Plug>(asterisk-*)`、`<Plug>(asterisk-#)` などを任意のキーへ割り当てる。移動しない検索には `<Plug>(asterisk-z*)` を使う。位置維持は `g:asterisk#keeppos = 1` で有効にする。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/haya14busa/vim-asterisk/blob/77e97061d6691637a034258cc415d98670698459/README.md)
  '';

  plugin = sources.vim-asterisk;
}
