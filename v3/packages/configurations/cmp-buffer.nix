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
  plugin = sources.cmp-buffer;
  doc = ''
    # cmp-buffer

    ## 概要
    バッファ内の単語を nvim-cmp の補完候補として提供する。

    ## 主な機能
    - 単語抽出パターンと補完開始文字数の設定。
    - 候補を収集するバッファの選択。

    ## 使い方
    nvim-cmp の `sources` に `{ name = "buffer" }` を追加する。`option.keyword_length`・`option.keyword_pattern` などで候補を調整する。

    ## 要件
    nvim-cmp 用の補完ソース。最低バージョンは README に未記載。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/hrsh7th/cmp-buffer/blob/b74fab3656eea9de20a9b8116afa3cfc4ec09657/README.md)
  '';
  dependPlugins = [
    definitions.nvim-cmp
  ];
}
