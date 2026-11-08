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
    # lookup.nvim

    ## 概要
    LSP を優先し、ripgrep による正規表現検索へフォールバックする定義検索。

    ## 主な機能
    - dumb-jump 由来のパターンによる複数言語の検索。
    - Telescope / fzf-lua / snacks / builtin の候補表示。

    ## 使い方
    `require("lookup").lookup_definition()` を呼ぶ。この定義は `use_lsp = true` と Telescope picker を選んでいる。README の `gd` はマッピング例。

    ## 要件
    正規表現検索は ripgrep を使用する。外部 picker を選ぶ場合は該当プラグインが必要。最低 Neovim バージョンは README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/srcrip/lookup.nvim/blob/671af22ca582c3cc74a6e6e18426b407e85e6958/README.md)
  '';
  # Preserve the v2 module entry point without eagerly loading Telescope.
  lazy = true;
  onModules = [ "lookup" ];
  plugin = sources.lookup-nvim;
  dependPlugins = [
    definitions.telescope-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("lookup").setup({ use_lsp = true, picker = "telescope" })
    ''
  );
}
