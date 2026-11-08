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
    # vim-nix

    ## 概要
    Vim で Nix 式を編集するための支援機能。

    ## 主な機能
    - Nix の構文ハイライト、.nix ファイルの判定、自動インデントを提供する。
    - NixEdit で属性名から nixpkgs 内を移動する。

    ## 使い方
    `.nix` ファイルを開いて編集する。nixpkgs を属性名で探す機能として `:NixEdit` が紹介されている。

    ## 要件
    README は Vim 8.0 の標準パッケージ機構など複数の導入方法を示す。プラグイン自体の最低版や追加依存の詳細は未記載。

    ## 出典
    [固定バージョンの README](https://github.com/LnL7/vim-nix/blob/7235c7ce2cea530cb6b59bc3e46d4bfe917d15c8/README.md)
  '';

  plugin = sources.vim-nix;
}
