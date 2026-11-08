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
  plugin = sources.nvim-jdtls;
  doc = ''
    # nvim-jdtls

    ## 概要
    eclipse.jdt.ls を使う Java 開発向けに、Neovim の組み込み LSP を拡張する。

    ## 主な機能
    - import 整理、変数・定数・メソッド抽出などのリファクタリング。
    - 任意の nvim-dap / Java 拡張によるデバッグ・テスト支援。

    ## 使い方
    JDT LS を構成して起動した後、`require("jdtls").organize_imports()` などの API を使う。サーバー起動後の `:JdtUpdateConfig` でプロジェクト設定を更新できる。

    ## 要件
    README は最新安定版または nightly の Neovim を案内。eclipse.jdt.ls の起動に Java 21、付属 jdtls スクリプトを使う場合は Python 3.9。デバッグには別途 nvim-dap と java-debug などの bundle が必要。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/mfussenegger/nvim-jdtls/blob/6e9d953f0b82bccdb834cfde0e893f3119c22592/README.md)
  '';
  dependPlugins = [
    definitions.nvim-dap
    definitions.nvim-dap-ui
  ];
  config = luaConfig (
    # lua
    ''
      vim.api.nvim_create_user_command("JdtDelteteWorkspaceData", function()
        local root_dir = vim.fs.root(0, { "gradlew", "mvnw", ".git" })
        local workspace_dir = os.getenv("HOME") .. "/.local/share/eclipse/"
          .. vim.fn.fnamemodify(root_dir, ":p:h"):gsub("/", "_")
        vim.notify("Starting to delete JDTLS workspace data.")
        os.execute("rm -rf " .. workspace_dir)
        vim.notify("JDTLS workspace data deleted.")
      end, {})
    ''
  );
}
