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
    # draw-line.nvim

    ## 概要
    矢印付きの直線・折れ線と長方形をバッファに描くプラグイン。

    ## 主な機能
    - 単線・二重線・太線・破線など 10 種のスタイル。
    - 呼び出しごとの描画スタイル指定と矩形描画。

    ## 使い方
    `require("draw-line").draw("l", "dashed3")` で右へ 1 辺描く。方向は `h/j/k/l`。`box({1, 1}, {3, 7}, "double")` は矩形、`box_visual(style)` は Visual Block の枠を描く。

    ## 要件
    Neovim 0.10 以上、対象の Unicode 文字を 1 セルで表示できるフォント。実行時依存・既定マッピング・setup は不要。

    ## 出典
    [固定リビジョンの README](https://github.com/ttak0422/draw-line.nvim/blob/104b3846e1171966de1dd58543d708417a14ab4e/README.md)
  '';
  plugin = sources.draw-line-nvim;
}
