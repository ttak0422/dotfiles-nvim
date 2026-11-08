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
  plugin = sources.smart-splits-nvim;
  doc = ''
    # smart-splits.nvim

    ## 概要
    上下左右の方向を基準に、ウィンドウの移動・サイズ変更を行う。

    ## 主な機能
    - 分割ウィンドウのリサイズ、移動、バッファ交換。
    - 画面端の挙動設定と任意の外部 multiplexer 連携。

    ## 使い方
    `:SmartResizeLeft` などでサイズを変更し、`:SmartCursorMoveRight` などで移動する。Lua API からキーに割り当てることもできる。

    ## 要件
    Neovim 0.11 以降。multiplexer 連携には別配布の対応バックエンドが必要で、コア単体には含まれない。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/mrjones2014/smart-splits.nvim/blob/fdd0142633ae78b175ff29043953e701215a34dd/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("smart-splits").setup({
        ignored_filetypes = { "nofile", "quickfix", "prompt" },
        ignored_buftypes = { "NvimTree" },
        ignored_events = { "BufEnter", "WinEnter" },
      })
    ''
  );
}
