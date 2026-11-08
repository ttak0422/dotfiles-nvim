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
  plugin = sources.nvim-fundo;
  doc = ''
    # nvim-fundo

    ## 概要
    Neovim 外で変更されたファイルでも undo 履歴を復元できるよう補助する。

    ## 主な機能
    - 最新ファイルのアーカイブによる undo 履歴復元。
    - アーカイブ保存先と容量上限の設定。

    ## 使い方
    上流の導入例では `require("fundo").install()` を行い、`vim.o.undofile = true` と `require("fundo").setup()` を設定する。利用時は通常の undo 操作を使う。

    ## 要件
    Neovim 0.7.2 以降、promise-async、永続 undo の有効化。アーカイブ保存用のディスク領域を使用する。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/kevinhwang91/nvim-fundo/blob/c2b83cb19e4ac475f2b08aaf775afe3da19bc495/README.md)
  '';
  dependPlugins = [
    definitions.promise-async
  ];
  config = luaConfig (
    # lua
    ''
      require("fundo").setup()
    ''
  );
}
