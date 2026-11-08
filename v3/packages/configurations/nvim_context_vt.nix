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
    # nvim_context_vt

    ## 概要
    関数や文などの末尾に、現在の構造を示す仮想テキストを表示する。

    ## 主な機能
    - filetype・ノード種別・行数に応じて表示を調整。
    - 接頭辞や表示優先度、独自 parser / validator を設定。

    ## 使い方
    `require("nvim_context_vt").setup(...)` で設定する。`:NvimContextVtToggle` で表示を切り替え、`:NvimContextVtDebug` で構造を調べる。

    ## 要件
    Neovim 0.11 以上、対象バッファで有効な Tree-sitter。

    ## 出典
    [固定リビジョンの README](https://github.com/andersevenrud/nvim_context_vt/blob/74c5ec8786426c5458e1a9f6b8b2fd6977ba01ab/README.md)
  '';
  plugin = sources.nvim_context_vt;
  config = luaConfig (
    # lua
    ''
      require("nvim_context_vt").setup({ prefix = "", priority = 10 })
    ''
  );
}
