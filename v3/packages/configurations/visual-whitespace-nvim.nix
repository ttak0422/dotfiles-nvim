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
    # visual-whitespace.nvim

    ## 概要
    ビジュアル選択範囲の空白文字を可視化する。

    ## 主な機能
    - 文字・行・矩形選択内の空白、タブ、改行などを表示する。
    - 表示文字、ハイライト、除外ファイルタイプを設定できる。

    ## 使い方
    ビジュアルモードで範囲を選択する。`require("visual-whitespace").toggle()` で有効・無効を切り替える。`setup()` の `match_types` や `list_chars` で表示を調整する。

    ## 要件
    README が説明する main ブランチは Neovim 0.12 以上を対象とする。

    ## 出典
    [固定バージョンの README](https://github.com/mcauley-penney/visual-whitespace.nvim/blob/d1f8889dd09ca9b07bc3b7af7cd5d1bfb5a7ea71/readme.md)
  '';

  plugin = sources.visual-whitespace-nvim;
  config = luaConfig (
    # lua
    ''
      -- visual-whitespace uses its defaults.
    ''
  );
}
