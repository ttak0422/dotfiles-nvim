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
    # vim-lastplace

    ## 概要
    ファイルを開き直した際、前回の編集位置へカーソルを復元するプラグイン。

    ## 主な機能
    - コミットメッセージなどを除外可能。
    - 復元位置を見やすく配置し、閉じた fold を開く。

    ## 使い方
    導入後はファイルを開くと自動動作する。`g:lastplace_ignore` と `g:lastplace_ignore_buftype` で除外を設定し、`g:lastplace_open_folds = 0` で fold を開く動作を無効にできる。

    ## 要件
    Vim / Neovim に対応。README の追加ツールなしの Vim 導入手順は Vim 8 以上向け。最低 Neovim バージョンは未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/farmergreg/vim-lastplace/blob/e58cb0df716d3c88605ae49db5c4741db8b48aa9/README.md)
  '';
  plugin = sources.vim-lastplace;
  config = luaConfig ({
    language = "vim";
    code = # vim
      ''
        let g:lastplace_ignore = "gitcommit,gitrebase,undotree,gitsigns-blame"
        let g:lastplace_ignore_buftype = "help,nofile,quickfix"
      '';
  });
}
