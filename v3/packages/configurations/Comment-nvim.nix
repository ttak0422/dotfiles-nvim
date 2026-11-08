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
    # Comment.nvim

    ## 概要
    行・ブロックのコメントを切り替える Neovim プラグイン。

    ## 主な機能
    - モーション、テキストオブジェクト、回数指定に対応。
    - コメント操作のドットリピートと前後フックを提供。

    ## 使い方
    `require("Comment").setup()` で既定マッピングを作成する。`gcc` は現在行、`gbc` はブロックコメントを切り替え、Visual モードの `gc` / `gb` は選択範囲を操作する。

    ## 要件
    最低 Neovim バージョンは README 未記載。nvim-treesitter は必須ではなく、パーサー管理用に推奨されている。

    ## 出典
    [固定リビジョンの README](https://github.com/numToStr/Comment.nvim/blob/e30b7f2008e52442154b66f7c519bfd2f1e32acb/README.md)
  '';
  plugin = sources.Comment-nvim;
  config = luaConfig (
    # lua
    ''
      require("Comment").setup({})
    ''
  );

  tests.comment-line-roundtrip = luaCheck {
    name = "comment-line-roundtrip";
    script = ''
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.bo.filetype = "lua"
      vim.bo.commentstring = "-- %s"
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "local value = 1", "return value" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      assert(vim.fn.maparg("gcc", "n") ~= "", "Comment line mapping is missing")
      vim.cmd.normal("gcc")
      assert(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "-- local value = 1",
        "gcc must add a Lua line comment")
      vim.cmd.normal("gcc")
      assert(vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false),
        { "local value = 1", "return value" }), "gcc must restore the original text")
    '';
  };
}
