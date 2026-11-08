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
    # winresizer.vim

    ## 概要
    専用モードでウィンドウのサイズ・位置・フォーカスを操作する。

    ## 主な機能
    - h・j・k・l で連続してサイズを調整する。
    - 変更の確定・取り消しとモード切り替えに対応する。

    ## 使い方
    `:WinResizerStartResize` で開始する。この定義の開始キーは `<C-w>e`。Enter で確定、q で取り消し、e で Resize・Move・Focus を切り替える。

    ## 要件
    README に最低 Vim バージョンは未記載。MacVim 自体のウィンドウを操作する機能は `g:winresizer_gui_enable = 1` で別途有効にする。

    ## 出典
    [固定バージョンの README](https://github.com/simeji/winresizer/blob/299076f7f79e2e2f7706b2dfacbb3c074ce53257/README.md)
  '';

  plugin = sources.winresizer;
  preConfig = luaConfig ({
    language = "vim";
    code = ''
      let g:winresizer_start_key = '<C-w>e'
    '';
  });
}
