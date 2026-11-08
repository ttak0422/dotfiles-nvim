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
    # nvim-dd

    ## 概要
    編集中の LSP 診断を遅延し、本文以外の診断表示も落ち着かせるプラグイン。

    ## 主な機能
    - Insert モードや補完ポップアップ中の診断を保留。
    - 編集が止まった後にタイマーで診断を反映。

    ## 使い方
    `require("dd").setup()` で有効化する。README は診断が即時に利用可能であることを前提とする他プラグインとの相性に注意を促している。

    ## 要件
    Neovim 0.6 以上。`vim.diagnostic` API を使用する。

    ## 出典
    [固定リビジョンの README](https://github.com/yorickpeterse/nvim-dd/blob/ebd9398271d3249fe97ffb52365fb6ace7605277/README.md)
  '';
  plugin = sources.nvim-dd;
  config = luaConfig (
    # lua
    ''
      require("dd").setup()
    ''
  );
}
