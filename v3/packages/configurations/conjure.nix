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
  plugin = sources.conjure;
  doc = ''
    # Conjure

    ## 概要
    編集中のコードを実行中のプログラムや REPL に送り、結果を確認する対話的開発環境。

    ## 主な機能
    - Clojure・Fennel・Lua など複数の言語クライアント。
    - 式・選択範囲・バッファの評価と結果ログ。

    ## 使い方
    `:ConjureSchool` で対話チュートリアルを開始する。上流の既定操作は `<localleader>ee` でカーソル位置の式を評価し、詳細は `:help conjure` を参照する。

    ## 要件
    Neovim。使用する言語に応じて nREPL・stdio REPL などの実行環境が必要。最低バージョンは README に未記載。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/Olical/conjure/blob/b23c76a8c874fe7ac5ad95255efc66173b049088/README.adoc)
  '';
  preConfig = luaConfig (
    # lua
    ''
      vim.g["conjure#mapping#doc_word"] = "K"
    ''
  );
}
