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
    # Fix Auto Scroll Neovim

    ## 概要
    バッファへ戻ったときの不要な中央寄せスクロールを抑える。

    ## 主な機能
    - バッファ切り替えに伴う画面位置の変化を修正する。

    ## 使い方
    `require("fix-auto-scroll").setup()` で有効にする。README 時点では設定オプションを受け取らない。

    ## 要件
    Neovim 0.7.2 以上。

    ## 出典
    [固定バージョンの README](https://github.com/BranimirE/fix-auto-scroll.nvim/blob/c211a42f4030c9ed03a1456919917cdf1a193bd9/README.md)
  '';

  plugin = sources.fix-auto-scroll-nvim;
  config = luaConfig (
    # lua
    ''
      require("fix-auto-scroll").setup()
    ''
  );
}
