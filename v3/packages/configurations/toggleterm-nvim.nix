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
  plugin = sources.toggleterm-nvim;
  doc = ''
    # toggleterm.nvim

    ## 概要
    複数のターミナルを編集セッション内に保持し、開閉する。

    ## 主な機能
    - 水平・垂直・タブ・フロートの表示形式。
    - 番号付きターミナルや独自 Terminal オブジェクトの操作。

    ## 使い方
    `require("toggleterm").setup()` 後、`:ToggleTerm` で開閉する。`:2ToggleTerm` は 2 番目を対象にし、`:ToggleTermToggleAll` は既存ターミナルをまとめて切り替える。

    ## 要件
    Neovim 0.7 以降。異なる方向の複数ターミナルを同時表示する構成は上流では未対応。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/akinsho/toggleterm.nvim/blob/9a88eae817ef395952e08650b3283726786fb5fb/README.md)
  '';
  dependPlugins = [
    definitions.term-gf-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return vim.o.lines * 0.5
          end
          return vim.o.columns * 0.5
        end,
        direction = "float",
        float_opts = {
          border = "single",
          width = function()
            return math.floor(vim.o.columns * 0.95)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.95)
          end,
          title_pos = "center",
        },
        shade_terminals = false,
        auto_scroll = false,
        start_in_insert = true,
        winbar = { enabled = false },
      })
    ''
  );
}
