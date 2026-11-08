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
    # colorful-winsep.nvim

    ## 概要
    アクティブなウィンドウの境界に色を付け、位置を見分けやすくするプラグイン。

    ## 主な機能
    - 境界線の種類・色・除外 filetype を設定。
    - 任意のアニメーションと、2 ウィンドウ時の位置表示。

    ## 使い方
    `require("colorful-winsep").setup(...)` で設定し、`:Winsep enable` / `disable` / `toggle` で操作する。この定義はアニメーションを無効にしている。

    ## 要件
    Neovim 0.11.3 以上、Nerd Fonts。

    ## 出典
    [固定リビジョンの README](https://github.com/nvim-zh/colorful-winsep.nvim/blob/7a8664fb8e91bd3435b3128c18dc814b3ddb11f5/README.md)
  '';
  plugin = sources.colorful-winsep-nvim;
  config = luaConfig (
    # lua
    ''
      require("colorful-winsep").setup({
        animate = { enabled = false },
        excluded_ft = { "TelescopePrompt" },
        indicator_for_2wins = {
          position = "center",
          symbols = {
            start_left = "", end_left = "",
            start_down = "", end_down = "",
            start_up = "", end_up = "",
            start_right = "", end_right = "",
          },
        },
      })
    ''
  );
}
