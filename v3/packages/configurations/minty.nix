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
  plugin = sources.minty;
  lazy = true;
  onCommands = [
    "Shades"
    "Huefy"
  ];
  onModules = [ "minty" ];
  doc = ''
    # Minty

    ## 概要
    Neovim 内で色を扱うためのツール。

    ## 主な機能
    - Shades と Huefy の色操作 UI。

    ## 使い方
    `:Shades`・`:Huefy` で開く。詳細は `:help minty` を参照する。

    ## 要件
    README の導入例は nvzone/volt を併用する。最低 Neovim バージョンは未記載。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/nvzone/minty/blob/aafc9e8e0afe6bf57580858a2849578d8d8db9e0/README.md)
  '';
  dependPlugins = [
    definitions.volt
  ];
}
