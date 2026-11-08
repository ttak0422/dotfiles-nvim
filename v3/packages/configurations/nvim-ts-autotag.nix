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
  plugin = sources.nvim-ts-autotag;
  doc = ''
    # nvim-ts-autotag

    ## 概要
    Tree-sitter を利用して HTML などのタグを自動で閉じ、対応タグの名前を同期する。

    ## 主な機能
    - HTML・JSX・Vue など複数の filetype に対応。
    - 自動閉じ・名前変更の個別設定と filetype ごとの上書き。

    ## 使い方
    `require("nvim-ts-autotag").setup()` で設定する。例では `<div` に `>` を入力すると閉じタグを追加し、開始タグの変更を対応タグに反映する。

    ## 要件
    Neovim 0.9.5 以降と対象 filetype の Tree-sitter パーサー。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/windwp/nvim-ts-autotag/blob/d7220b55e16ed3c04e88086256def5d282429493/README.md)
  '';
  dependPlugins = [
    definitions.nvim-treesitter
  ];
  config = luaConfig (
    # lua
    ''
      require("nvim-ts-autotag").setup({
        filetypes = { "javascript", "typescript", "jsx", "tsx", "vue", "html" },
      })
    ''
  );
}
