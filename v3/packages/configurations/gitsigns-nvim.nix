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
  plugin = sources.gitsigns-nvim;
  doc = ''
    # gitsigns.nvim

    ## 概要
    Git の変更状況と履歴を編集中のバッファに表示する。

    ## 主な機能
    - 追加・変更・削除行のサインと hunk 操作。
    - 行単位の blame、差分表示、単語単位の差分強調。

    ## 使い方
    `:Gitsigns preview_hunk` で差分を確認し、`:Gitsigns nav_hunk next` で次の hunk に移動する。`:Gitsigns blame_line` で現在行の履歴を表示する。

    ## 要件
    Neovim 0.11.0 以降と比較的新しい Git。古い Git では一部機能が動作しない場合がある。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/lewis6991/gitsigns.nvim/blob/ef707fb93301a9b856f36eae4c8f56f5b988a794/README.md)
  '';
  dependPlugins = [
    definitions.plenary-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("gitsigns").setup({
        signcolumn = true,
        numhl = true,
        linehl = false,
        word_diff = false,
        current_line_blame_formatter = "<author> <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 1000,
        max_file_length = 40000,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 300,
          use_focus = true,
        },
      })
    ''
  );
}
