{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  plugin = sources.vim-repeat;
  doc = ''
    # repeat.vim

    ## 概要
    プラグインのマッピング全体を `.` で繰り返せるようにする。

    ## 主な機能
    - 対応プラグインの操作をドットリピートへ登録。

    ## 使い方
    対応プラグインの操作後に `.` を使う。プラグイン側はマッピングの末尾で `repeat#set()` に Plug マッピングとカウントを登録する。

    ## 要件
    README に最低 Vim / Neovim バージョンや必須外部依存の明記なし。対象プラグイン側の repeat.vim 対応が必要。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/tpope/vim-repeat/blob/65846025c15494983dafe5e3b46c8f88ab2e9635/README.markdown)
  '';
}
