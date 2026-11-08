{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  luaCheck,
  inputs',
}:
with sources;
{
  plugin = sources.nvim-surround;
  doc = ''
    # nvim-surround

    ## 概要
    括弧・引用符・タグなどの囲みを追加・削除・変更する。

    ## 主な機能
    - モーションや選択範囲への囲み操作とドットリピート。
    - 関数呼び出し・HTML タグ・独自の囲みの処理。

    ## 使い方
    `ys{motion}{char}` で追加、`ds{char}` で削除、`cs{target}{replacement}` で変更する。例: `ysiw)` は単語を空白なしの括弧で囲む。

    ## 要件
    Neovim 0.8 以降。Tree-sitter textobject を使う囲みには nvim-treesitter-textobjects を推奨するが、通常操作では必須ではない。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/kylechui/nvim-surround/blob/8b47db616ef658b8fc27e61db2896aa2f40134de/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      vim.g.nvim_surround_no_insert_mappings = true
      vim.g.nvim_surround_no_normal_mappings = true
      vim.g.nvim_surround_no_visual_mappings = true
      require("nvim-surround").setup({})

      local mappings = {
        { "i", "<C-g>s", "insert", "Add a surrounding pair around the cursor (insert mode)" },
        { "i", "<C-g>S", "insert-line", "Add a surrounding pair around the cursor, on new lines (insert mode)" },
        { "n", "ys", "normal", "Add a surrounding pair around a motion (normal mode)" },
        { "n", "yss", "normal-cur", "Add a surrounding pair around the current line (normal mode)" },
        { "n", "yS", "normal-line", "Add a surrounding pair around a motion, on new lines (normal mode)" },
        { "n", "ySS", "normal-cur-line", "Add a surrounding pair around the current line, on new lines (normal mode)" },
        { "x", "Y", "visual", "Add a surrounding pair around a visual selection" },
        { "x", "gY", "visual-line", "Add a surrounding pair around a visual selection, on new lines" },
        { "n", "ds", "delete", "Delete a surrounding pair" },
        { "n", "cs", "change", "Change a surrounding pair" },
        { "n", "cS", "change-line", "Change a surrounding pair, on new lines" },
      }
      for _, mapping in ipairs(mappings) do
        vim.keymap.set(mapping[1], mapping[2], "<Plug>(nvim-surround-" .. mapping[3] .. ")", {
          noremap = true,
          silent = true,
          desc = mapping[4],
        })
      end
    ''
  );
  tests.surround-editing = luaCheck {
    name = "surround-editing";
    script = ''
      local buf = vim.api.nvim_create_buf(true, true)
      vim.api.nvim_set_current_buf(buf)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "alpha beta" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      vim.cmd("normal ysiw)")
      assert(vim.api.nvim_get_current_line() == "(alpha) beta", "ys must add surrounds through the configured mapping")
      vim.cmd("normal cs)]")
      assert(vim.api.nvim_get_current_line() == "[alpha] beta", "cs must replace the surrounding pair")
      vim.cmd("normal ds]")
      assert(vim.api.nvim_get_current_line() == "alpha beta", "ds must remove only the surrounding pair")
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      vim.cmd("normal ysiw(")
      assert(vim.api.nvim_get_current_line() == "( alpha ) beta", "opening delimiters must preserve spaced surrounds")
      local visual = vim.fn.maparg("Y", "x", false, true)
      assert(visual.rhs == "<Plug>(nvim-surround-visual)", "custom visual mapping must not revert to the upstream default")
    '';
  };
}
