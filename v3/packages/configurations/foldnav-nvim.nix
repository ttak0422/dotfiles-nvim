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
    # foldnav.nvim

    ## 概要
    折り畳み構造を目印に、カーソルの列を保ちながら縦方向へ移動するプラグイン。

    ## 主な機能
    - 包含する fold の先頭・末尾や前後の fold へ移動。
    - 移動先の fold を任意でハイライト。

    ## 使い方
    `require("foldnav").goto_start()` / `goto_end()` で包含する fold の端へ移動する。`goto_next()` と `goto_prev_start()` は次・前の fold の先頭をたどる。

    ## 要件
    対象バッファに fold が必要。README は Tree-sitter の foldexpr を設定する例を示している。最低バージョンは未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/domharries/foldnav.nvim/blob/489fffcee704db4650119e214f76f0410205dd3f/README.md)
  '';
  plugin = sources.foldnav-nvim;
}
