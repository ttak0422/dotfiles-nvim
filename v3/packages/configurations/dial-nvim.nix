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
    # dial.nvim

    ## 概要
    数値や日付などの増減操作を拡張する。

    ## 主な機能
    - 整数、日付、真偽値などの定数、セマンティックバージョンを増減する。
    - ノーマル・ビジュアルモード、回数指定、ドットリピートに対応する。

    ## 使い方
    `require("dial.map").manipulate("increment", "normal")` または `"decrement"` を使う。`require("dial.config").augends:register_group()` で対象を定義する。上流は既定のキーマッピングを追加しない。

    ## 要件
    Neovim 0.11.0 以上。

    ## 出典
    [固定バージョンの README](https://github.com/monaqa/dial.nvim/blob/f2634758455cfa52a8acea6f142dcd6271a1bf57/README.md)
  '';

  plugin = sources.dial-nvim;
  config = luaConfig (
    # lua
    ''
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
        },
      })
    ''
  );
  tests.dial-default-augends = luaCheck {
    name = "dial-default-augends";
    script = ''
      local api = vim.api
      vim.cmd.enew()
      local function increment(before, after, column)
        api.nvim_buf_set_lines(0, 0, -1, false, { before })
        api.nvim_win_set_cursor(0, { 1, column or 0 })
        require("dial.map").manipulate("increment", "normal", "default", 1)
        assert(api.nvim_get_current_line() == after,
          ("dial: %s became %s, expected %s"):format(before, api.nvim_get_current_line(), after))
      end
      increment("true", "false")
      increment("2024/02/28", "2024/02/29", 9)
      increment("2024-12-31", "2025-01-01", 9)
      increment("0x0f", "0x10")
    '';
  };
}
