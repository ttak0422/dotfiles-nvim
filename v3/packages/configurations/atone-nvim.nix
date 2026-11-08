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
    # atone.nvim

    ## 概要
    取り消し履歴をツリーで表示する Neovim 用プラグイン。

    ## 主な機能
    - 履歴ノードと構文ハイライト付き差分を表示する。
    - バッファ切り替えへの追従や履歴ノードのマークに対応する。

    ## 使い方
    `:Atone` で開き、`:Atone toggle` で切り替え、`:Atone close` で閉じる。`require("atone").setup()` でレイアウト、差分表示、キー操作を設定する。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/XXiaoA/atone.nvim/blob/f0f92d6e639d97e1fa653bc69807ed839c390023/README.md)
  '';

  plugin = sources.atone-nvim;
  config = luaConfig (
    # lua
    ''
      require("atone").setup({
        layout = { direction = "left", width = 0.25 },
        diff_cur_node = { enabled = true, split_percent = 0.35 },
        keymaps = {
          tree = {
            quit = { "<C-c>", "q" },
            next_node = "j",
            pre_node = "k",
            undo_to = "<CR>",
            help = { "?", "g?" },
          },
          auto_diff = { quit = { "<C-c>", "q" }, help = { "?", "g?" } },
          help = { quit_help = { "<C-c>", "q" } },
        },
        ui = { border = "single" },
      })
    ''
  );
}
