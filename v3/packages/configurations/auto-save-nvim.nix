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
    # auto-save.nvim

    ## 概要
    編集内容をイベントに応じて自動保存するプラグイン。

    ## 主な機能
    - 保存条件・発火イベント・通知を設定可能。
    - 保存のデバウンスと実行前後のコールバック。

    ## 使い方
    `require("auto-save").setup(...)` で設定する。`:ASToggle` で自動保存を切り替える。README の既定発火イベントは `InsertLeave` と `TextChanged`。

    ## 要件
    Neovim 0.5.0 以上。

    ## 出典
    [固定リビジョンの README](https://github.com/pocco81/auto-save.nvim/blob/979b6c82f60cfa80f4cf437d77446d0ded0addf0/README.md)
  '';
  plugin = sources.auto-save-nvim;
  config = luaConfig (
    # lua
    ''
      local targets = { md = true, markdown = true, norg = true, neorg = true }
      require("auto-save").setup({
        events = { "InsertLeave", "TextChanged" },
        debounce_delay = 500,
        condition = function(buf)
          return vim.fn.getbufvar(buf, "&modifiable") == 1
            and targets[vim.fn.getbufvar(buf, "&filetype")] == true
        end,
      })
    ''
  );
}
