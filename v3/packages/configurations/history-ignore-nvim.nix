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
    # history-ignore.vim

    ## 概要
    コマンドライン履歴へ登録しないコマンドを設定するプラグイン。

    ## 主な機能
    - 履歴への登録対象を制御する。

    ## 使い方
    固定リビジョンの README にはコマンド・API・設定手順の記載がない。

    ## 要件
    README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/yutkat/history-ignore.nvim/blob/fa873a546e739361c1b9dd6019e7504eb57d61f3/README.md)
  '';
  plugin = sources.history-ignore-nvim;
  config = luaConfig (
    # lua
    ''
      require("history-ignore").setup({
        ignore_words = {
          "^buf$", "^history$", "^h$",
          "^q$", "^qa$", "^w$", "^wq$", "^wa$", "^wqa$",
          "^q!$", "^qa!$", "^w!$", "^wq!$", "^wa!$", "^wqa!$",
        },
      })
    ''
  );
}
