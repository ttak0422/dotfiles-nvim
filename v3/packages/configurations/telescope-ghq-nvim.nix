{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  doc = ''
    # telescope-ghq.nvim

    ## 概要
    ghq 管理下のリポジトリを選ぶ Telescope extension。

    ## 主な機能
    - `ghq list` の結果を picker に表示。
    - 選択先で Git ファイル検索やディレクトリ変更。

    ## 使い方
    ghq extension を読み込んだ後、`:Telescope ghq` を実行する。Enter で `git_files`、`<C-x>` / `<C-v>` / `<C-t>` で全体・ウィンドウ・タブのディレクトリを変更する。

    ## 要件
    telescope.nvim と ghq を使用する。README は `ghq list` のみ対応と記載。最低バージョンは未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/nvim-telescope/telescope-ghq.nvim/blob/2bd2e2d10f1a06fce9cce1e33ffe464c84ceb63b/README.md)
  '';
  plugin = sources.telescope-ghq-nvim;
}
