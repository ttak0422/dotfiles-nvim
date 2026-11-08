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
    # Menu

    ## 概要
    入れ子のメニューをキーボードやマウスで操作する Neovim 用 UI。

    ## 主な機能
    - 項目ごとのコマンド・キー操作とサブメニュー。
    - マウス位置や枠の設定。

    ## 使い方
    `require("menu").open(options, opts)` で開く。メニュー内では `h` / `l` でウィンドウ間を移動、Enter で選択項目を実行、`q` で閉じる。この定義は `:OpenMenu` を用意する。

    ## 要件
    README の導入例では nvzone/volt を併用する。最低 Neovim バージョンは未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/nvzone/menu/blob/7a0a4a2896b715c066cfbe320bdc048091874cc6/README.md)
  '';
  plugin = sources.menu;
  dependPlugins = [
    definitions.volt
  ];
  config = luaConfig (
    # lua
    ''
      local menu = require("menu")
      local items = {
        { hl = "Normal", name = " Toggle NoNeckPain", cmd = "NoNeckPain" },
        {
          hl = "Normal",
          name = " Toggle List",
          cmd = function() vim.o.list = not vim.o.list end,
        },
        { hl = "Normal", name = " Toggle colorize", cmd = "ColorizerToggle" },
        { hl = "Normal", name = " Edit local config", cmd = "ConfigLocalEdit" },
        { hl = "Normal", name = "󰞷 Open scratch buffer", cmd = "RepluaOpen" },
        { name = "separator" },
        { hl = "Normal", name = "󰄉 Timer", cmd = function() vim.cmd.TimerlyToggle() end },
        { hl = "Normal", name = " Show keys", cmd = function() vim.cmd.ShowkeysToggle() end },
        { hl = "Normal", name = " Color Picker", cmd = function() vim.cmd.Huefy() end },
      }
      vim.api.nvim_create_user_command("OpenMenu", function()
        menu.open(items, { border = true })
      end, {})
    ''
  );
}
