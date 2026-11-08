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
  plugin = sources.nui-nvim;
  doc = ''
    # nui.nvim

    ## 概要
    Neovim プラグイン向けの UI コンポーネントライブラリ。

    ## 主な機能
    - テキスト・行・テーブル・ツリーの描画。
    - Popup・Layout などによる UI の構築。

    ## 使い方
    `require("nui.popup")` や `require("nui.layout")` で部品を生成し、レイアウトに組み合わせる。利用側のプラグインや Lua コードから呼び出す。

    ## 要件
    Neovim 0.5.0 以降。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/MunifTanjim/nui.nvim/blob/10fc361835c856ba4233ef5ea135b919bf3dce97/README.md)
  '';
}
