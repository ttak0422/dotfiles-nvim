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
    # snacks.nvim

    ## 概要
    Neovim の小さな便利機能をまとめたプラグイン集。

    ## 主な機能
    - 大きなファイルの扱いを調整する bigfile を提供する。
    - picker、通知、端末、画像表示などを個別の機能として提供する。

    ## 使い方
    `require("snacks").setup()` で機能ごとにオプションを渡すか `enabled = true` を指定する。この定義で設定するのは bigfile。`:checkhealth snacks` で導入状態を確認する。

    ## 要件
    Neovim 0.9.4 以上。mini.icons、nvim-web-devicons、Nerd Font はアイコン表示用の任意要件。

    ## 出典
    [固定バージョンの README](https://github.com/folke/snacks.nvim/blob/e6fd58c82f2f3fcddd3fe81703d47d6d48fc7b9f/README.md)
  '';

  plugin = sources.snacks-nvim;
  config = luaConfig (
    # lua
    ''
      require("snacks").setup({
        bigfile = {
          notify = true,
          size = 1024 * 1024,
          line_length = 2000,
        },
      })
    ''
  );
}
