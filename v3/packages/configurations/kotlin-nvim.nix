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
    # kotlin.nvim

    ## 概要
    JetBrains の Kotlin LSP と Neovim の間を補完するクライアント機能。

    ## 主な機能
    - 補完、インレイヒント、リファクタリング、ライブラリーソースの表示を扱う。
    - プロジェクトごとの状態分離と、実行・nvim-dap 連携を提供する。

    ## 使い方
    `require("kotlin").setup()` 後に Kotlin ファイルを開く。`:KotlinRunMain` で実行し、デバッグ連携には `:KotlinDebugMain` / `:KotlinDebug` を使う。サーバーは Mason または `KOTLIN_LSP_DIR` から探索する。

    ## 要件
    Neovim 0.11 以上と kotlin-lsp v262.4739.0 以上。README 推奨は v263.7084.0。サーバーは Java ランタイムを同梱する。

    ## 出典
    [固定バージョンの README](https://github.com/AlexandrosAlexiou/kotlin.nvim/blob/bc8ed5523db7e0ec2c00e26a17858e4c54d86072/README.md)
  '';

  plugin = sources.kotlin-nvim;
  config = luaConfig ({
    code = # lua
      ''
        vim.env.KOTLIN_LSP_DIR = args.kotlin_lsp_dir
        local kotlin = require("kotlin")
        local options = {
          inlay_hints = { enabled = true },
          java_files = false,
        }
        kotlin.setup(options)
        if vim.bo.filetype == "kotlin" then
          kotlin.setup_kotlin_lsp(options)
        end
      '';
    args.kotlin_lsp_dir = "${pkgs.kotlin-lsp}/libexec/kotlin-lsp";
  });
}
