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
    # vim-bufsurf

    ## 概要
    ウィンドウごとの閲覧履歴に沿ってバッファ間を移動するプラグイン。

    ## 主な機能
    - 開いた順ではなく、実際に表示した順で前後へ移動。
    - 独自マッピング用の Plug を提供。

    ## 使い方
    `:BufSurfBack` / `:BufSurfForward` で履歴を戻る・進む。README は `<Plug>(buf-surf-back)` / `<Plug>(buf-surf-forward)` をキーへ割り当てる例を示す。

    ## 要件
    最低バージョン・追加依存は README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/ton/vim-bufsurf/blob/e6dbc7ad66c7e436e5eb20d304464e378bd7f28c/README.md)
  '';
  plugin = sources.vim-bufsurf;
}
