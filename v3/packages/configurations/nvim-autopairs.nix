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
    # nvim-autopairs

    ## 概要
    括弧や引用符などの対応する文字列を自動挿入するプラグイン。

    ## 主な機能
    - Enter / Backspace に連動したペア編集。
    - filetype・条件・Tree-sitter に基づく規則と独自ルール。

    ## 使い方
    `require("nvim-autopairs").setup(...)` で設定し、`add_rules(...)` でルールを追加する。この定義は Java の三重引用符を追加し、Tree-sitter 判定を有効化している。nvim-cmp 連携は README にある別設定。

    ## 要件
    Neovim 0.7 以上。README は Tree-sitter 連携用に `check_ts` と `ts_config` の設定例を示す。

    ## 出典
    [固定リビジョンの README](https://github.com/windwp/nvim-autopairs/blob/3172f40c16563db871a58f20d205c710ad782311/README.md)
  '';
  plugin = sources.nvim-autopairs;
  config = luaConfig (
    # lua
    ''
      local autopairs = require("nvim-autopairs")
      local rule = require("nvim-autopairs.rule")
      autopairs.setup({
        map_cr = true,
        check_ts = true,
        ts_config = { go = false },
        disable_filetype = { "TelescopePrompt", "spectre_panel", "norg" },
      })
      autopairs.add_rules({ rule('"""', '"""', "java") })
    ''
  );
}
