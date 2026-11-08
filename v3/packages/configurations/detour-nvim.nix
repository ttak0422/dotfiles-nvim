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
  plugin = sources.detour-nvim;
  doc = ''
    # detour.nvim

    ## 概要
    通常の分割ウィンドウに近い操作で、位置とサイズを自動調整するフロートを開く。

    ## 主な機能
    - 画面全体または現在のウィンドウ上にフロートを作成。
    - フロート内の分割や入れ子表示。

    ## 使い方
    `:Detour` で全ウィンドウ上、`:DetourCurrentWindow` で現在のウィンドウ上に開く。Lua では `require("detour").Detour()` を利用する。

    ## 要件
    README に実行時の最低 Neovim バージョンや必須外部依存の明記なし。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/carbon-steel/detour.nvim/blob/204f61e64f87c7c6fd4ef4a387631c9a9efc2573/README.md)
  '';
}
