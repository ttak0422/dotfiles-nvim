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
    # nvim-hlslens

    ## 概要
    検索の一致情報を仮想テキストなどで表示し、検索位置を見つけやすくするプラグイン。

    ## 主な機能
    - 移動やインクリメンタル検索に応じて一致情報を更新。
    - 表示スタイルとハイライトの調整。

    ## 使い方
    `require("hlslens").setup()` で設定し、`:HlSearchLensToggle` / `:HlSearchLensEnable` / `:HlSearchLensDisable` で切り替える。README の検索キー連携例では検索後に `require("hlslens").start()` を呼ぶ。

    ## 要件
    Neovim 0.7.2 以上。一部の組込みコマンドの incsearch 対応には 0.8.0 が必要。nvim-ufo は任意。

    ## 出典
    [固定リビジョンの README](https://github.com/kevinhwang91/nvim-hlslens/blob/be2d7b2be01860b5445a007ff2bc72b29896db6b/README.md)
  '';
  plugin = sources.nvim-hlslens;
  config = luaConfig (
    # lua
    ''
      require("hlslens").setup()
    ''
  );
}
