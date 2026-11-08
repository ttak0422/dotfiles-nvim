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
  plugin = sources.tiny-cmdline-nvim;
  doc = ''
    # tiny-cmdline.nvim

    ## 概要
    Neovim の native ui2 を使い、コマンドラインを中央のフロートに配置する。

    ## 主な機能
    - UIEnter での自動初期化。
    - ウィンドウの幅などを vim.g または setup から調整。

    ## 使い方
    ui2 を明示的に有効化したうえで利用する。`vim.g.tiny_cmdline` を読み込み前に設定するか、`require("tiny-cmdline").setup()` にオプションを渡す。

    ## 要件
    Neovim 0.12 以降と `require("vim._core.ui2").enable({})` による ui2 の有効化。README は `cmdheight=0` を推奨する。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/rachartier/tiny-cmdline.nvim/blob/ac9c6557c66da6308eb523643df8778f3cbe652f/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      local cmdline = require("tiny-cmdline")
      cmdline.setup({
        on_reposition = cmdline.adapters.blink,
        native_types = {},
      })
    ''
  );
}
