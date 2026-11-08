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
    # logrotate-nvim

    ## 概要
    指定したログファイルのローテーションを行う。

    ## 主な機能
    - 対象パスと日次・週次・月次の間隔を設定する。

    ## 使い方
    `require("logrotate").setup({ targets = {...}, interval = "daily" })` のように設定する。`config_path` で設定保存先を指定できる。

    ## 要件
    Neovim 0.10 以上。README はシステムの logrotate コマンドの忠実な再現を目的にしないと明記している。

    ## 出典
    [固定バージョンの README](https://github.com/ttak0422/logrotate-nvim/blob/4e4eacec18ce42cd863644914570edf9263a1150/README.md)
  '';

  plugin = sources.logrotate-nvim;
  config = luaConfig (
    # lua
    ''
      require("logrotate").setup({
        targets = { vim.fn.stdpath("state") .. "/lsp.log" },
        interval = "daily",
      })
    ''
  );
}
