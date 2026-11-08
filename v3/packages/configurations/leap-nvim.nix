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
    # leap.nvim

    ## 概要
    画面に見える位置へ、2 文字の検索パターンとラベルで移動・選択するプラグイン。

    ## 主な機能
    - 候補ラベルのプレビューとウィンドウをまたぐ移動。
    - 任意の visit 操作や Tree-sitter 選択用モジュール。

    ## 使い方
    この定義の `s` / `S` で移動を開始し、対象の 2 文字を入力する。複数候補は表示ラベルで選ぶ。行末は「対象文字 + Space」、空行は Space 2 回で指定できる。

    ## 要件
    Neovim 0.10.0 以上の stable または最新 nightly。変更操作のドットリピートには任意の repeat.vim を使う。

    ## 出典
    [固定リビジョンの README](https://codeberg.org/andyg/leap.nvim/src/commit/277e04fad21e3af05a55cc414757b09a704f2a92/README.md)
  '';
  plugin = sources.leap-nvim;
  dependPlugins = [
    definitions.vim-repeat
  ];
  config = luaConfig (
    # lua
    ''
      local leap = require("leap")
      local traversal_keys = require("leap.user").with_traversal_keys
      local clever_f = traversal_keys("f", "F")
      local clever_t = traversal_keys("t", "T")

      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", {
        noremap = true, silent = true, desc = "Leap",
      })
      vim.keymap.set("n", "S", "<Plug>(leap-from-window)", {
        noremap = true, silent = true, desc = "Leap from window",
      })

      for key, spec in pairs({
        f = { opts = clever_f },
        F = { backward = true, opts = clever_f },
        t = { offset = -1, opts = clever_t },
        T = { backward = true, offset = 1, opts = clever_t },
      }) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          leap.leap(vim.tbl_deep_extend("keep", spec, {
            inputlen = 1,
            inclusive = true,
            opts = {
              labels = "",
              safe_labels = vim.fn.mode(1):match("o") and "" or nil,
            },
          }))
        end)
      end
    ''
  );
}
