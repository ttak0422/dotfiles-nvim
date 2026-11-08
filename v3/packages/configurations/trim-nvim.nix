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
    # trim.nvim

    ## 概要
    行末の空白やバッファ前後の空行を削除するプラグイン。

    ## 主な機能
    - 保存時の自動処理と filetype ごとの除外。
    - 範囲指定による行末空白の削除。

    ## 使い方
    `:Trim` で現在バッファを整形し、`:TrimToggle` で保存時処理を切り替える。範囲付き `:Trim` は対象行の行末空白のみを処理する。この定義は markdown / neorg / norg を除外する。

    ## 要件
    Neovim 0.7.0 以上。

    ## 出典
    [固定リビジョンの README](https://github.com/cappyzawa/trim.nvim/blob/765360a6f6ac732f4c78c5c694f4b892a55b53ec/README.md)
  '';
  plugin = sources.trim-nvim;
  config = luaConfig (
    # lua
    ''
      require("trim").setup({ ft_blocklist = { "markdown", "neorg", "norg" } })
    ''
  );

  tests.trim-write-and-exclusions = luaCheck {
    name = "trim-write-and-exclusions";
    script = ''
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      local original = { "", "alpha  ", "beta\t", "" }
      local function before_write(filetype)
        vim.bo.filetype = filetype
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, original)
        -- Trigger only trim's actual write hook, without writing a file or running formatters.
        vim.api.nvim_exec_autocmds("BufWritePre", { group = "TrimNvim", buffer = buf })
        return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      end
      assert(vim.deep_equal(before_write("text"), { "alpha", "beta" }),
        "Write hook must remove trailing whitespace and leading/trailing empty lines")
      for _, filetype in ipairs({ "markdown", "neorg", "norg" }) do
        assert(vim.deep_equal(before_write(filetype), original),
          "Write hook must preserve whitespace for excluded filetype: " .. filetype)
      end
    '';
  };
}
