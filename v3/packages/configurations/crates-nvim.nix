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
    # crates.nvim

    ## 概要
    crates.io の依存関係管理を支援する Neovim 用プラグイン。

    ## 主な機能
    - Rust の crates.io 依存関係を扱う。

    ## 使い方
    `require("crates").setup()` で初期化する。README の遅延読み込み例は `Cargo.toml` を開くタイミングを指定している。詳細な操作は README からリンクされる Wiki に掲載されている。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/saecki/crates.nvim/blob/7039bc1d130e424232a7aa64ceddb170a154ff5b/README.md)
  '';

  plugin = sources.crates-nvim;
  config = luaConfig (
    # lua
    ''
      require("crates").setup({
        lsp = {
          enabled = true,
          actions = true,
          hover = true,
          completion = false,
        },
      })
    ''
  );
}
