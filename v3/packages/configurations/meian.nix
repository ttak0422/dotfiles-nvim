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
    # meian.nvim

    ## 概要
    macOS のライト・ダークモード変更を実行中の Neovim に反映する。

    ## 主な機能
    - 共有の Swift 監視プロセスから各 Neovim に外観変更を通知する。
    - `background` の更新後に `on_change` コールバックを実行する。

    ## 使い方
    `require("meian").setup()` で開始する。`:MeianApply` で再検出し、`:MeianApply light` / `:MeianApply dark` で明示的に適用する。

    ## 要件
    macOS と Neovim 0.10 以上。macOS 以外では自動的に無効になる。

    ## 出典
    [固定バージョンの README](https://github.com/ttak0422/meian.nvim/blob/000a25009be81247c191e2b0ac5ce93ff67560fe/README.md)
  '';

  plugin = sources.meian;
  config = luaConfig (
    # lua
    ''
      require("meian").setup()
    ''
  );
}
