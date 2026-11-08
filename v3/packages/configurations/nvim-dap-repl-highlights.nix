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
    # nvim-dap-repl-highlights

    ## 概要
    nvim-dap の REPL に Tree-sitter の構文ハイライトを追加する。

    ## 主な機能
    - デバッグを開始したファイルタイプから言語を判定する。
    - `repl_lang` や API で使用言語を上書きできる。

    ## 使い方
    `require("nvim-dap-repl-highlights").setup()` で初期化する。言語を明示するには `setup_highlights("python")` を使う。

    ## 要件
    Neovim 0.9 以上、nvim-treesitter、dap_repl パーサーと対象言語のパーサーが必要。nvim-dap の REPL を対象とする。

    ## 出典
    [固定バージョンの README](https://github.com/LiadOz/nvim-dap-repl-highlights/blob/f31deba47fe3ee6ff8d2f13d9dbd06b2d1ae06b5/README.md)
  '';

  plugin = sources.nvim-dap-repl-highlights;
  dependPlugins = [
    definitions.nvim-dap
    definitions.nvim-treesitter
  ];
  config = luaConfig ''
    require("nvim-dap-repl-highlights").setup()
  '';
}
