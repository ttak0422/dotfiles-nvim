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
    # vim-qfreplace

    ## 概要
    固定リビジョンには README が存在しない。以下は同梱の `doc/qfreplace.txt` に基づく、quickfix の内容を編集して元ファイルへ反映する機能の要約。

    ## 主な機能
    - quickfix の各行を編集用バッファに展開。
    - 編集用バッファの保存で元ファイルへ置換を適用。

    ## 使い方
    同梱ヘルプによれば、`:Qfreplace [cmd]` で編集バッファを開く。既定は split。内容を変更して保存すると元ファイルへ反映される。

    ## 要件
    README がないため README 由来の要件は取得できない。同梱ヘルプにも最低バージョン・追加依存の指定はない。

    ## 出典
    README なし。[代替出典: 固定リビジョンの同梱ヘルプ](https://github.com/thinca/vim-qfreplace/blob/707a895f9f86eeed106f64da0bd9fa07b3cd9cee/doc/qfreplace.txt)
  '';
  plugin = sources.vim-qfreplace;
}
