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
    # nvim-ts-context-commentstring

    ## 概要
    カーソル位置の言語に合わせて `commentstring` を切り替える。

    ## 主な機能
    - Tree-sitter クエリーで埋め込み言語のコメント形式を判断する。
    - コメント用プラグインとの連携、または `CursorHold` で更新する。

    ## 使い方
    必要に応じて `require("ts_context_commentstring").setup()` で設定する。本体はコメント用キーを追加しない。連携を設定しない場合は `CursorHold` で判定するため、README は `updatetime` の短縮を勧めている。

    ## 要件
    Neovim 0.9.4 と対象言語の Tree-sitter パーサー。Comment.nvim などのコメント機能との連携を推奨する。

    ## 出典
    [固定バージョンの README](https://github.com/JoosepAlviste/nvim-ts-context-commentstring/blob/6141a40173c6efa98242dc951ed4b6f892c97027/README.md)
  '';

  plugin = sources.nvim-ts-context-commentstring;
  dependPlugins = [
    definitions.nvim-treesitter
  ];
}
