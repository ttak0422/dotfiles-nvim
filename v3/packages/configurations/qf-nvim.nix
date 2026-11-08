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
    # qf.nvim

    ## 概要
    Neovim 標準の quickfix / location list の表示と移動を拡張するプラグイン。

    ## 主な機能
    - 一覧の自動開閉・高さ調整とカーソル追従。
    - 一覧の保存・復元と循環する移動。

    ## 使い方
    `require("qf").toggle("c", true)` は quickfix を、`toggle("l", true)` は location list をフォーカスを保って切り替える。`:Qsave` / `:Qload` で一覧を保存・復元する。

    ## 要件
    最低 Neovim バージョン・追加依存は README 未記載。Telescope 連携は任意。

    ## 出典
    [固定リビジョンの README](https://github.com/ten3roberts/qf.nvim/blob/c16efebc2a4967251d34630c7f5beee25ca8a9ba/README.md)
  '';
  plugin = sources.qf-nvim;
  config = luaConfig (
    # lua
    ''
      local options = {
        auto_close = true,
        auto_follow = "prev",
        auto_follow_limit = 8,
        follow_slow = true,
        auto_open = true,
        auto_resize = true,
        max_height = 8,
        min_height = 5,
        wide = true,
        number = false,
        relativenumber = false,
        unfocus_close = false,
        focus_open = false,
      }
      require("qf").setup({ l = options, c = options, pretty = true, silent = false })
    ''
  );
}
