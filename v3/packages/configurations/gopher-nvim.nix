{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  luaCheck,
  inputs',
}:
with sources;
{
  plugin = sources.gopher-nvim;
  config = luaConfig (
    # lua
    ''
      require("gopher").setup()
    '');
  extraPackages =
    with pkgs;
    [
      go
      gomodifytags
      gotests
      iferr
      impl
    ]
    ++ [ (pkgs.callPackage ../tools/json2go.nix { }) ];
  tests.gopher-json2go = luaCheck {
    name = "gopher-json2go";
    script = builtins.readFile ../checks/gopher-json2go.lua;
  };
  doc = ''
    # gopher.nvim

    ## 概要
    Go 開発用の外部ツールを Neovim から操作するプラグイン。LSP の代替ではない。

    ## 主な機能
    - 構造体タグの追加・削除。
    - Go ツールによるコード・テスト生成などの開発支援。

    ## 使い方
    `:GoTagAdd json`・`:GoTagRm yaml` でタグを操作する。`:GoJson {"name":"Alice"}` で JSON を Go の型に変換する。
    必要なツールは Nix で導入済み。json2go は上流の v0.2.2 に固定し、`:GoInstallDeps` による実行時インストールは不要。

    ## 要件
    Neovim 0.10 以降、Go、Go の Tree-sitter パーサー。各操作には gomodifytags・impl・gotests・iferr・json2go など対応するツールが必要。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/olexsmir/gopher.nvim/blob/f397bed1c35f29f4f85d60a210650e677a8c5cb4/README.md)
  '';
}
