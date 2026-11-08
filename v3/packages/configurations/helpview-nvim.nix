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
    # Helpview.nvim

    ## 概要
    vimdoc を装飾して読みやすく表示する。

    ## 主な機能
    - 見出し、コード、タグ、オプションリンクなどを描画する。
    - 編集と表示を併用するハイブリッド表示や分割プレビューに対応する。

    ## 使い方
    `:Helpview Toggle` で全体のプレビューを切り替え、`:Helpview toggle` で現在のバッファを切り替える。`:Helpview splitToggle` で分割表示を切り替える。

    ## 要件
    Neovim 0.10.3 と vimdoc パーサー。Tree-sitter 対応配色と Nerd Fonts を推奨。mini.icons / nvim-web-devicons は設定で選ぶ外部アイコン供給元。

    ## 出典
    [固定バージョンの README](https://github.com/OXY2DEV/helpview.nvim/blob/06006b471890f19efeb199ffab5da49a2d624619/README.md)
  '';

  plugin = sources.helpview-nvim;
  dependPlugins = [
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("helpview").setup({ preview = { modes = { "n", "c", "no" } }, vimdoc = {} })
    ''
  );
}
