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
  plugin = sources.harpoon;
  doc = ''
    # Harpoon

    ## 概要
    頻繁に使うファイルや独自アクションをリストに登録し、少ない操作で呼び出す。

    ## 主な機能
    - 複数のリストと項目の管理。
    - 登録済みファイルへの移動とクイックメニュー。

    ## 使い方
    `local harpoon = require("harpoon")` の後に `harpoon:setup()` を呼ぶ。`harpoon:list():add()` で追加し、`:select(1)` で選択する。メニューは `harpoon.ui:toggle_quick_menu(harpoon:list())`。

    ## 要件
    Neovim 0.8.0 以降、plenary.nvim。Telescope を使う UI 連携は任意。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/ThePrimeagen/harpoon/blob/87b1a3506211538f460786c23f98ec63ad9af4e5/README.md)
  '';
  dependPlugins = [
    definitions.plenary-nvim
  ];
  config = luaConfig (
    # lua
    ''
      local function display(item)
        local value = item.value or ""
        local repo = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
        local filename = vim.fn.fnamemodify(value, ":t")
        local dir = vim.fn.fnamemodify(value, ":h")
        if dir == "." or dir == "" then
          return string.format("%s  %s", filename, repo)
        end
        return string.format("%s  %s/%s", filename, repo, dir)
      end
      require("harpoon").setup({
        settings = { key = vim.uv.cwd, save_on_toggle = false, sync_on_ui_close = false },
        default = { display = display },
      })
    ''
  );
}
