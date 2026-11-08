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
  plugin = sources.hlchunk-nvim;
  doc = ''
    # hlchunk.nvim

    ## 概要
    カーソル位置のコードブロックやインデントを強調表示する。

    ## 主な機能
    - chunk・indent・line_num・blank の各表示を個別設定。
    - 表示スタイル、優先度、除外 filetype の調整。

    ## 使い方
    `require("hlchunk").setup()` で使用するモジュールを有効化する。有効化済みの chunk は `:DisableHLchunk`・`:EnableHLchunk` で切り替えられる。

    ## 要件
    Neovim 0.10.0 以降。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/shellRaining/hlchunk.nvim/blob/4ddc056e4ca45f1c7dc6aa21935df710b263b1aa/README.md)
  '';
  dependPlugins = [ definitions.sorairo ];
  config = luaConfig (
    # lua
    ''
      require("hlchunk").setup({
        indent = { enable = false },
        line_num = { enable = false },
        blank = { enable = false },
        chunk = {
          enable = true,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "┌",
            left_bottom = "└",
            right_arrow = "─",
          },
          -- Resolve again after Meian changes light/dark appearance.
          style = function()
            return vim.g.terminal_color_8 or "#808080"
          end,
          duration = 200,
          delay = 500,
          use_treesitter = true,
          exclude_filetypes = { ["copilot-chat"] = true },
        },
      })
    ''
  );
}
