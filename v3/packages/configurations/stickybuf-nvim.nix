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
    # stickybuf.nvim

    ## 概要
    ウィンドウに特定のバッファや種類を固定する。

    ## 主な機能
    - バッファ番号・buftype・filetype を基準に固定する。
    - 条件外のバッファを近くの利用可能なウィンドウへ振り分ける。

    ## 使い方
    `:PinBuffer`、`:PinBuftype`、`:PinFiletype` で固定し、`:Unpin` で解除する。Lua からは `require("stickybuf").pin()` / `unpin()` を使う。

    ## 要件
    Neovim 0.8 以上。

    ## 出典
    [固定バージョンの README](https://github.com/stevearc/stickybuf.nvim/blob/9e00edfd94baef4a78b4248ae8309a2d4943f118/README.md)
  '';

  plugin = sources.stickybuf-nvim;
  config = luaConfig (
    # lua
    ''
      require("stickybuf").setup()
    ''
  );
}
