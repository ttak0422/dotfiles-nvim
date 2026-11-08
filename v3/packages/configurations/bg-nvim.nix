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
    # bg.nvim

    ## 概要
    Neovim の配色に端末の背景色とカーソル色を同期する。

    ## 主な機能
    - 配色変更時にエスケープシーケンスで端末色を変更する。
    - Neovim 終了時に元の端末色へ戻す。

    ## 使い方
    プラグインを起動時に読み込む。配色を変更すると自動的に同期される。README に専用の操作コマンドは記載されていない。

    ## 要件
    対応するモダンな端末が必要。README は Alacritty、foot、GNOME Terminal、kitty、WezTerm などを挙げる。st で色を戻すにはパッチが必要。

    ## 出典
    [固定バージョンの README](https://github.com/typicode/bg.nvim/blob/85da2c68409820466753b50c2e6f699517778a17/README.md)
  '';

  plugin = sources.bg-nvim;
}
