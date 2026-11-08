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
  plugin = sources.vim-gf-improved;
  doc = ''
    # vim-gf-improved

    ## 概要
    カーソル下のファイルを開く gf 系操作に、行・列指定と複数行パス検出を加える。

    ## 主な機能
    - file:line:column 形式の移動。
    - 分割・タブ表示と、折り返されたパスの検出。

    ## 使い方
    `gf` でファイル、`gF` で行・列を含めて移動する。例: `path/to/file.txt:42:10` 上で `gF`。`<C-w>F` は分割、`<C-w>gF` は新規タブで開く。

    ## 要件
    README に最低 Vim / Neovim バージョンや必須外部依存の明記なし。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/lambdalisue/vim-gf-improved/blob/893709185d2f55a1f8a0183e0557690ca34e4bdd/README.md)
  '';
}
