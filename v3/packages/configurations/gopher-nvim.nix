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
  plugin = sources.gopher-nvim;
  config = luaConfig (
    # lua
    ''
      require("gopher").setup()
    ''
  );
  extraPackages = with pkgs; [
    go
    gomodifytags
    gotests
    iferr
    impl
  ];
  doc = ''
    # gopher.nvim

    ## 概要
    Go 開発用の外部ツールを Neovim から操作するプラグイン。LSP の代替ではない。

    ## 主な機能
    - 構造体タグの追加・削除。
    - Go ツールによるコード・テスト生成などの開発支援。

    ## 使い方
    `:GoTagAdd json`・`:GoTagRm yaml` でタグを操作する。上流は依存ツールの導入用に `:GoInstallDeps` を提供する。

    ## 要件
    Neovim 0.10 以降、Go、Go の Tree-sitter パーサー。各操作には gomodifytags・impl・gotests・iferr・json2go など対応するツールが必要。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/olexsmir/gopher.nvim/blob/f397bed1c35f29f4f85d60a210650e677a8c5cb4/README.md)
  '';
}
