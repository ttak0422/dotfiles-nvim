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
    # no-neck-pain.nvim

    ## 概要
    編集ウィンドウの左右に余白を作って表示位置を整える。

    ## 主な機能
    - 分割・タブ・端末サイズ変更に追従する。
    - サイドバッファの色や、任意のスクラッチパッドを設定できる。

    ## 使い方
    `:NoNeckPain` で表示を切り替える。`require("no-neck-pain").setup()` で幅やサイドバッファを設定する。この定義は右側バッファを無効にしている。

    ## 要件
    Neovim 0.10 以上。

    ## 出典
    [固定バージョンの README](https://github.com/shortcuts/no-neck-pain.nvim/blob/83ed5249cfdfc5790ab2c05f96038eeca7dd9451/README.md)
  '';

  plugin = sources.no-neck-pain-nvim;
  config = luaConfig (
    # lua
    ''
      require("no-neck-pain").setup({ buffers = { right = { enabled = false } } })
    ''
  );
}
