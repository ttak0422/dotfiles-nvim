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
    # git-conflict.nvim

    ## 概要
    マージ競合をハイライトし、採用する変更を選べるプラグイン。

    ## 主な機能
    - ours / theirs / 両方 / どちらも採用しない、を選択。
    - 競合間の移動と quickfix 一覧。

    ## 使い方
    `:GitConflictChooseOurs` / `GitConflictChooseTheirs` などで競合を解消する。`:GitConflictNextConflict` / `GitConflictPrevConflict` で移動し、`:GitConflictListQf` で一覧を開く。

    ## 要件
    Git、Neovim 0.7 以上。

    ## 出典
    [固定リビジョンの README](https://github.com/akinsho/git-conflict.nvim/blob/a1badcd070d176172940eb55d9d59029dad1c5a6/README.md)
  '';
  plugin = sources.git-conflict-nvim;
  config = luaConfig (
    # lua
    ''
      require("git-conflict").setup()
    ''
  );
}
