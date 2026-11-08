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
    # nvim-window

    ## 概要
    現在のタブ内で文字ヒントを使ってウィンドウを切り替える。

    ## 主な機能
    - 1〜2 文字の入力で対象ウィンドウへ移動する。
    - ヒントを浮動ウィンドウまたはステータス行に表示する。

    ## 使い方
    `require("nvim-window").pick()` を任意のキーに割り当て、表示された文字を入力する。プラグイン自体はキーを割り当てない。

    ## 要件
    Neovim 0.5 以上。1 タブで扱えるウィンドウは最大 52 個。

    ## 出典
    [固定バージョンの README](https://github.com/yorickpeterse/nvim-window/blob/48e44d492d2adaf9aac72a0f4ff21d6caae1b6a2/README.md)
  '';

  plugin = sources.nvim-window;
  config = luaConfig (
    # lua
    ''
      require("nvim-window").setup({})
    ''
  );
}
