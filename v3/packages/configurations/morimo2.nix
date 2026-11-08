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
    # morimo2

    ## 概要
    色覚の多様性に配慮した、Lua 製の Neovim カラースキーム。

    ## 主な機能
    - 設定なしで適用可能で、枠なしウィンドウにも対応。
    - 背景の透過と適用前のハイライト上書き。

    ## 使い方
    `:colorscheme morimo2` で適用する。変更する場合は先に `require("morimo2").setup({ transparent = ..., overrides = ... })` を呼ぶ。この定義はスキームを提供するだけで選択は行わない。

    ## 要件
    Neovim 0.10 以上。

    ## 出典
    [固定リビジョンの README](https://github.com/ttak0422/morimo2/blob/1d8db7b1844e0f418c06b4e21ba07618121401aa/README.md)
  '';
  plugin = sources.morimo2;
}
