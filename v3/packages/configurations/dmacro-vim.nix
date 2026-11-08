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
    # dmacro.nvim / dmacro.vim

    ## 概要
    繰り返されたキー操作から動的にマクロを推定する。

    ## 主な機能
    - 同じキー列を 2 回入力すると反復単位を検出する。
    - 直前のキー列を途中まで入力した場合は残りを補完する。

    ## 使い方
    `<Plug>(dmacro-play-macro)` を挿入・ノーマルモードのキーに割り当てる。この設定では `<C-q>` を使用する。

    ## 要件
    Neovim 0.10.0 以上、または Vim の patch 9.1.0597 が必要。

    ## 出典
    [固定バージョンの README](https://github.com/tani/dmacro.vim/blob/25ab1df31d216c4ff7554c262f92b5c0c6b743f0/README.md)
  '';

  plugin = sources.dmacro-vim;
  config = luaConfig ({
    code = # vim
      ''
        inoremap <C-q> <Plug>(dmacro-play-macro)
        nnoremap <C-q> <Plug>(dmacro-play-macro)
      '';
    language = "vim";
  });
}
