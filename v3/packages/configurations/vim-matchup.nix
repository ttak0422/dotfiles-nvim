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
  plugin = pkgs.vimPlugins.vim-matchup;
  doc = ''
    # vim match-up

    ## 概要
    Vim の `%` を言語固有の対応する語句へ拡張し、移動と強調表示を行う。

    ## 主な機能
    - 対応する括弧・語句の強調と画面外の対応箇所の表示。
    - 対応箇所をたどるモーションと textobject。

    ## 使い方
    `%` で対応箇所へ移動し、`g%`・`[%`・`]%` などで方向や範囲を選ぶ。`i%`・`a%` は対応範囲を textobject として操作する。

    ## 要件
    一般機能の最低バージョンは README に未記載。Tree-sitter 連携は Neovim 限定で最新安定版をサポートし、追加プラグインは不要。

    ## 出典
    - [上流 README（nixpkgs 固定リビジョン）](https://github.com/andymass/vim-matchup/blob/0106b1afd4a2f7e1098037b5ceb161bab7471088/README.md)
  '';
  config = luaConfig ''
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
    vim.g.matchup_treesitter_stopline = 500
  '';
}
