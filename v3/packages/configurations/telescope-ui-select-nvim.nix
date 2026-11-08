{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  plugin = sources.telescope-ui-select-nvim;
  doc = ''
    # telescope-ui-select.nvim

    ## 概要
    Neovim の `vim.ui.select` を Telescope の picker で表示する。

    ## 主な機能
    - LSP コードアクションなどの選択 UI を統一。
    - dropdown テーマや項目種別ごとの表示調整。

    ## 使い方
    Telescope の `extensions["ui-select"]` を設定し、setup 後に `require("telescope").load_extension("ui-select")` を呼ぶ。以後 `vim.ui.select` を使う機能に適用される。

    ## 要件
    telescope.nvim。README は Neovim 0.7 またはそれ以降の nightly を要求する。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/nvim-telescope/telescope-ui-select.nvim/blob/6e51d7da30bd139a6950adf2a47fda6df9fa06d2/README.md)
  '';
}
