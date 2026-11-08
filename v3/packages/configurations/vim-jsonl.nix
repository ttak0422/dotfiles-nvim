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
    # vim-jsonl

    ## 概要
    Vim 向けの JSON Lines 構文ファイル。

    ## 主な機能
    - JSONL の構文表示を提供する。

    ## 使い方
    JSONL の編集に用いる。README に操作コマンドや設定 API の説明は記載されていない。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/kyoh86/vim-jsonl/blob/647ade2455a0340be8b8807675f1c43242ffc838/README.md)
  '';

  plugin = sources.vim-jsonl;
  tests.jsonl-filetype-syntax = luaCheck {
    name = "jsonl-filetype-syntax";
    script = ''
      vim.cmd.edit(vim.fn.fnameescape(vim.fn.tempname() .. ".jsonl"))
      assert(vim.bo.filetype == "jsonl", "JSONL filetype detection failed")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { '{"value": 1}', '{"value": 2}' })
      vim.cmd.syntax("enable")
      assert(vim.bo.syntax == "jsonl", "JSONL syntax was not selected")
      for row = 1, 2 do
        local group = vim.fn.synIDattr(vim.fn.synID(row, 11, 1), "name")
        assert(group == "jsonNumber", ("JSONL row %d number has syntax %s"):format(row, group))
        for column = 1, #vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] do
          local name = vim.fn.synIDattr(vim.fn.synID(row, column, 1), "name")
          assert(not name:find("Error"), ("valid JSONL flagged at %d:%d as %s"):format(row, column, name))
        end
      end
    '';
  };
}
