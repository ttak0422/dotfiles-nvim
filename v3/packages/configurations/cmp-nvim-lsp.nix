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
    # cmp-nvim-lsp

    ## 概要
    Neovim 内蔵 LSP クライアントの補完候補を nvim-cmp に提供するソース。

    ## 主な機能
    - LSP 補完向けのクライアント capabilities を生成。
    - 言語サーバーごとの keyword_pattern を設定可能。

    ## 使い方
    nvim-cmp のソースに `nvim_lsp` を追加し、`require("cmp_nvim_lsp").default_capabilities()` の結果を LSP 設定に渡す。README は、この capabilities を使うと内蔵 omnifunc に互換性がなくなると注意している。

    ## 要件
    nvim-cmp と Neovim 内蔵 LSP クライアントを使用する。最低バージョンは README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/hrsh7th/cmp-nvim-lsp/blob/cd4ee08a988deb47ac3726f418fb27fe1a95729d/README.md)
  '';
  plugin = sources.cmp-nvim-lsp;
  dependPlugins = [
    definitions.nvim-cmp
  ];
}
