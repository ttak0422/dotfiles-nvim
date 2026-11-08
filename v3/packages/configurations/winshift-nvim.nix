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
    # WinShift.nvim

    ## 概要
    ウィンドウを任意方向へ動かし、分割レイアウトを組み替えるプラグイン。

    ## 主な機能
    - 移動により新しい列や行を作成。
    - ウィンドウの交換と移動中のハイライト。

    ## 使い方
    `:WinShift` で移動モードに入り、`hjkl` または矢印で移動する。`HJKL` は画面端へ移動し、`q` / Escape / Ctrl-C で終了する。`:WinShift swap` は交換対象を選ぶ。

    ## 要件
    Neovim 0.7.2 以上。

    ## 出典
    [固定リビジョンの README](https://github.com/sindrets/winshift.nvim/blob/37468ed6f385dfb50402368669766504c0e15583/README.md)
  '';
  plugin = sources.winshift-nvim;
  lazy = true;
  onCommands = [ "WinShift" ];
  onModules = [ "winshift" ];
  config = luaConfig (
    # lua
    ''
      require("winshift").setup({})
    ''
  );
}
