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
  plugin = sources.nvim-config-local;
  doc = ''
    # nvim-config-local

    ## 概要
    プロジェクト固有の設定を、ファイルのハッシュに基づく信頼確認を経て読み込む。

    ## 主な機能
    - 未知の設定を表示・無視・許可・拒否。
    - 内容やパスが変わったファイルの再確認。

    ## 使い方
    `require("config-local").setup()` で対象ファイルを設定する。`:ConfigLocalEdit` で編集し、`:ConfigLocalSource` で読み込む。許可する前に内容を確認する。

    ## 要件
    README に最低 Neovim バージョンや必須外部依存の明記なし。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/klen/nvim-config-local/blob/990f3e35e0fba8fb83012d7e85f9a6a77de7f87f/README.md)
  '';
}
