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
  doc = ''
    # csvview.nvim

    ## 概要
    CSV / TSV を表形式で読み書きするための Neovim プラグイン。

    ## 主な機能
    - 仮想テキストによる表表示と非同期解析。
    - 区切り文字・ヘッダーの自動検出と固定ヘッダー。
    - フィールド用のテキストオブジェクトと移動操作。

    ## 使い方
    `:CsvViewToggle` で表示を切り替える。`:CsvViewEnable delimiter=, display_mode=border header_lnum=1` のように指定でき、`:CsvViewInfo` で解析情報を確認する。

    ## 要件
    Neovim 0.10 以上。

    ## 出典
    [固定リビジョンの README](https://github.com/hat0uma/csvview.nvim/blob/f190de76d2eca0380ddcb2425cd582d740699b55/README.md)
  '';
  plugin = sources.csvview-nvim;
  config = luaConfig (
    # lua
    ''
      require("csvview").setup({
        keymaps = {
          textobject_field_inner = { "if", mode = { "o", "x" } },
          textobject_field_outer = { "af", mode = { "o", "x" } },
          jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
          jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
          jump_next_row = { "<Enter>", mode = { "n", "v" } },
          jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
        },
        view = { display_mode = "border" },
      })
    ''
  );

  tests.csvview-mappings-and-field-actions = luaCheck {
    name = "csvview-mappings-and-field-actions";
    script = ''
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.bo.filetype = "csv"
      vim.opt.clipboard = {}
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "name,age", "alice,42", "bob,31" })
      vim.cmd("CsvViewEnable delimiter=, header_lnum=1")
      local csvview = require("csvview")
      assert(vim.wait(2000, function() return csvview.is_enabled(buf) end, 10),
        "CsvViewEnable must attach the CSV buffer")
      local function mapping(lhs, mode)
        local result = vim.fn.maparg(lhs, mode, false, true)
        assert(result.buffer == 1 and type(result.callback) == "function",
          "CSV buffer mapping missing: " .. mode .. " " .. lhs)
        return result.callback
      end
      for _, mode in ipairs({ "o", "x" }) do
        mapping("if", mode)
        mapping("af", mode)
      end
      for _, mode in ipairs({ "n", "x" }) do
        for _, lhs in ipairs({ "<Tab>", "<S-Tab>", "<CR>", "<S-CR>" }) do
          mapping(lhs, mode)
        end
      end
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      mapping("<Tab>", "n")()
      assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 2, 4 }),
        "Tab must move to the current field's end")
      mapping("<CR>", "n")()
      assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 3, 2 }),
        "Enter must preserve the column while moving to the next row")
      vim.api.nvim_win_set_cursor(0, { 2, 6 })
      vim.cmd.normal('"ayif')
      assert(vim.fn.getreg("a") == "42", "if must select the current field without its delimiter")
      vim.cmd("CsvViewDisable")
      assert(not csvview.is_enabled(buf), "CsvViewDisable must detach the buffer")
      assert(vim.fn.maparg("<Tab>", "n", false, true).buffer ~= 1,
        "Disabling CSV view must remove its buffer-local mappings")
    '';
  };
}
