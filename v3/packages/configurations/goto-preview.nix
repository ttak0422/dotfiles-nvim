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
    # Goto Preview

    ## 概要
    LSP の定義・型定義・実装・宣言・参照先をフローティングウィンドウでプレビューする。

    ## 主な機能
    - プレビューのサイズ・枠・フォーカス動作を設定。
    - プレビューを重ねて開き、まとめて閉じる API。

    ## 使い方
    `require("goto-preview").goto_preview_definition()` などを呼ぶ。`close_all_win()` で閉じる。この定義では既定マッピングを無効にしているため、README の `gpd` などが自動設定されるとは限らない。

    ## 要件
    Neovim 0.10 以上。README の導入例は logger.nvim を依存に指定している。LSP 応答に基づいて動作する。

    ## 出典
    [固定リビジョンの README](https://github.com/rmagatti/goto-preview/blob/d2d6923c9b9e0e43f0b9b566f261a8b1ae016540/README.md)
  '';
  plugin = sources.goto-preview;
  config = luaConfig (
    # lua
    ''
      require("goto-preview").setup({
        height = 20,
        width = 120,
        zindex = 90,
        border = "single",
        default_mappings = false,
        resizing_mappings = false,
      })
    ''
  );
}
