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
  plugin = sources.tiny-inline-diagnostic-nvim;
  doc = ''
    # tiny-inline-diagnostic.nvim

    ## 概要
    診断メッセージを、スタイルやアイコンを調整できるインライン表示にする。

    ## 主な機能
    - 複数行表示と重要度・カーソル位置に応じた表示制御。
    - 表示の切り替え、設定のリセット、フロート表示との連携。

    ## 使い方
    `require("tiny-inline-diagnostic").setup()` で設定し、重複を避けるため組み込みの `virtual_text` を無効にする。`:TinyInlineDiag toggle` で表示を切り替える。

    ## 要件
    Neovim 0.10 以降。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/rachartier/tiny-inline-diagnostic.nvim/blob/46ae9b3c8f3039e96ff4497d190ad0aee091f30d/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("tiny-inline-diagnostic").setup({
        preset = "classic",
        transparent_bg = true,
        hi = {
          error = "GitSignsDelete",
          warn = "GitSignsAdd",
          info = "GitSignsChange",
          arrow = "NonText",
          background = "CursorLine",
          mixing_color = "None",
        },
        virt_texts = { priority = 2048 },
        options = {
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
          },
        },
      })
    ''
  );
}
