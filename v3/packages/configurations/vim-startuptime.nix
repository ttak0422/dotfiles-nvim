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
    # vim-startuptime

    ## 概要
    Vim / Neovim の起動イベントごとの所要時間を調べるプラグイン。

    ## 主な機能
    - `--startuptime` を付けて起動し、計測結果を取得。
    - イベントの詳細表示と読込元ファイルへの移動。

    ## 使い方
    `:StartupTime` で計測画面を開く。イベント上の `K` で詳細、読込イベント上の `gf` でファイルを split 表示する。`:StartupTime --help` で使い方を確認する。

    ## 要件
    Vim 8.0.1453 以上、または Neovim 0.3.1 以上。Vim では +startuptime / +terminal が必須、+timers は推奨。

    ## 出典
    [固定リビジョンの README](https://github.com/dstein64/vim-startuptime/blob/b2de50f190c8139d70d36d82157dd9c1a8212579/README.md)
  '';
  plugin = sources.vim-startuptime;
  lazy = true;
  onCommands = [ "StartupTime" ];
}
