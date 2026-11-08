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
    # MCP HUB

    ## 概要
    Neovim から MCP サーバーを管理・利用するクライアント。

    ## 主な機能
    - MCP のツール、リソース、テンプレート、プロンプトを扱う。
    - ローカル STDIO とリモート HTTP / SSE 接続に対応する。
    - チャットプラグインとの連携やプロジェクト別設定に対応する。

    ## 使い方
    README は導入と詳細な操作を公式ドキュメントサイトへ案内している。具体的な起動コマンドや設定 API は README に未記載。Avante、CodeCompanion、CopilotChat は連携先の選択肢であり、一括で有効になるわけではない。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/ravitemer/mcphub.nvim/blob/7cd5db330f41b7bae02b2d6202218a061c3ebc1f/README.md)
  '';

  plugin = sources.mcphub-nvim;
  extraPackages = with pkgs; [
    nodejs
    v2.mcp-hub
    uv
  ];
  dependPlugins = [
    definitions.plenary-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("mcphub").setup({ auto_approve = true })
    ''
  );
}
