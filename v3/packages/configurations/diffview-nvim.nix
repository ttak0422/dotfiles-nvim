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
    # diffview+

    ## 概要
    変更ファイルの差分・履歴・競合を一つのタブで扱う diffview.nvim の派生版。

    ## 主な機能
    - ファイル一覧から差分やコミット履歴を閲覧。
    - 3-way / 4-way の競合解決と任意ファイル同士の比較。

    ## 使い方
    `:DiffviewOpen` で作業ツリーとインデックスの差分、`:DiffviewFileHistory %` で現在ファイルの履歴を開く。`:DiffviewClose` で閉じ、表示内の `g?` でキー操作を確認する。

    ## 要件
    Neovim 0.10.0 以上と LuaJIT。VCS は Git 2.31.0 以上、Mercurial 5.4.0 以上、Sapling、Jujutsu 0.38.0 以上、Perforce 2019.1 以上のいずれか。アイコン用プラグインは任意。

    ## 出典
    [固定リビジョンの README](https://github.com/dlyongemallo/diffview.nvim/blob/fae72d6c981075dce2e0f946f002382ce0cb44e1/README.md)
  '';
  plugin = sources.diffview-nvim;
  lazy = true;
  # Keep all exported commands available before the first load.
  onCommands = [
    "DiffviewOpen"
    "DiffviewToggleFiles"
    "DiffviewToggle"
    "DiffviewDiffFiles"
    "DiffviewMergeFiles"
    "DiffviewDiffDirs"
    "DiffviewFileHistory"
    "DiffviewClose"
    "DiffviewWorktreeOverview"
    "DiffviewFocusFiles"
    "DiffviewRefresh"
    "DiffviewLog"
  ];
  onModules = [ "diffview" ];
  dependPlugins = [
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("diffview").setup({
        icons = { folder_closed = "", folder_open = "" },
        signs = { fold_closed = "▸", fold_open = "▾", done = "✓" },
      })
    ''
  );
}
