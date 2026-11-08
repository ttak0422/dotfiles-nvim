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
    # nvim-scrollbar

    ## 概要
    診断や Git 変更などの位置を示す拡張可能なスクロールバー。

    ## 主な機能
    - スクロール位置、診断、任意の検索・Git マークを表示する。
    - ハンドルやマークの見た目と更新頻度を設定できる。

    ## 使い方
    `require("scrollbar").setup()` で初期化する。この定義は Git ハンドラーを有効、カーソルマークを無効にしている。README の検索連携は別途設定する任意機能。

    ## 要件
    固定 README の v1 要件は Neovim 0.5.1 以上。Git 連携には gitsigns.nvim、検索連携には nvim-hlslens が必要。README の v2 移行案内は別バージョン向け。

    ## 出典
    [固定バージョンの README](https://github.com/petertriho/nvim-scrollbar/blob/00fe857e7cd97ee5e556de643ee920b003a96b03/README.md)
  '';

  plugin = sources.nvim-scrollbar;
  dependPlugins = [
    definitions.gitsigns-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("scrollbar").setup({
        throttle_ms = 250,
        handle = { blend = 0 },
        handlers = { gitsigns = true, cursor = false },
      })
    ''
  );
}
