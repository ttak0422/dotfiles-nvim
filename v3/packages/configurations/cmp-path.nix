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
  plugin = sources.cmp-path;
  doc = ''
    # cmp-path

    ## 概要
    ファイルシステムのパスを nvim-cmp で補完する。

    ## 主な機能
    - 相対パスの基準ディレクトリとパス別名の設定。
    - ディレクトリ末尾のスラッシュ表示・挿入の調整。

    ## 使い方
    nvim-cmp の `sources` に `{ name = "path" }` を追加する。`option.pathMappings` や `option.get_cwd` でパス解決を調整する。

    ## 要件
    nvim-cmp 用の補完ソース。最低バージョンは README に未記載。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/hrsh7th/cmp-path/blob/c642487086dbd9a93160e1679a1327be111cbc25/README.md)
  '';
  dependPlugins = [
    definitions.nvim-cmp
  ];
}
