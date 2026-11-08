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
    # trace-pr.nvim

    ## 概要
    現在行の Git 履歴から関連する GitHub PR をたどる。

    ## 主な機能
    - merge commit・squash merge の PR を探す。
    - PR が見つからない場合は、設定に応じてコミット画面を開く。

    ## 使い方
    `:TracePR` を実行する。`trace_by_commit_hash_when_pr_not_found` でコミットへの代替表示を制御する。

    ## 要件
    PATH 上の git と gh、リモートアクセスを設定した GitHub リポジトリーが必要。

    ## 出典
    [固定バージョンの README](https://github.com/h3pei/trace-pr.nvim/blob/40a7afa3d697d7a5971e92540690ac6f909a9236/README.md)
  '';

  plugin = sources.trace-pr-nvim;
  lazy = true;
  onCommands = [ "TracePR" ];
  onModules = [ "trace-pr" ];
  extraPackages = with pkgs; [ gh ];
  config = luaConfig (
    # lua
    ''
      require("trace-pr").setup({ trace_by_commit_hash_when_pr_not_found = true })
    ''
  );
}
