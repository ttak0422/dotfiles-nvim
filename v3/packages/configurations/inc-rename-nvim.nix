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
    # inc-rename.nvim

    ## 概要
    LSP の名前変更を、入力中のプレビューとともに実行するプラグイン。

    ## 主な機能
    - 変更対象を即時に視覚表示。
    - 任意で noice.nvim / dressing.nvim / snacks.nvim の入力 UI と連携。

    ## 使い方
    LSP の識別子にカーソルを置き、`:IncRename <new_name>` を入力する。複数ファイルを変更した場合は `:wa` で対象バッファを保存する。外部 UI 連携は別途設定が必要。

    ## 要件
    Neovim 0.8 以上。LSP の名前変更機能を使用する。

    ## 出典
    [固定リビジョンの README](https://github.com/smjonas/inc-rename.nvim/blob/ddff8bd3eccedf043bd73f5bf89cf90d2d6d8105/README.md)
  '';
  plugin = sources.inc-rename-nvim;
  config = luaConfig (
    # lua
    ''
      require("inc_rename").setup({
        preview_empty_name = false,
        save_in_cmdline_history = false,
        show_message = false,
      })
    ''
  );
}
