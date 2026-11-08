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
    # Timerly

    ## 概要
    休憩や時間管理に使える、Neovim 内の対話型タイマー。

    ## 主な機能
    - モード・実行状態の切り替え。
    - 時間の増減とリセット。

    ## 使い方
    `:TimerlyToggle` で開閉する。README の既定操作は `m` でモード切替、`<leader>` で状態切替、上下キーで増減、Backspace でリセット。この定義は Enter にも状態切替を割り当てる。

    ## 要件
    nvzone/volt。最低 Neovim バージョンは README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/nvzone/timerly/blob/1c78999480af0e4f8201fe6bfa1e5e0b70a59acf/README.md)
  '';
  plugin = sources.timerly;
  lazy = true;
  onCommands = [ "TimerlyToggle" ];
  onModules = [ "timerly" ];
  dependPlugins = [
    definitions.volt
  ];
  config = luaConfig (
    # lua
    ''
      require("timerly").setup({
        position = "top-right",
        mapping = function(buf)
          vim.keymap.set("n", "<CR>", require("timerly.api").togglestatus, { buffer = buf })
        end,
      })
    ''
  );
}
