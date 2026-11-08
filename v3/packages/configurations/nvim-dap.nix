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
    # DAP (Debug Adapter Protocol)

    ## 概要
    Neovim 用の Debug Adapter Protocol クライアント。

    ## 主な機能
    - アプリケーションの起動・アタッチ、ブレークポイント、ステップ実行を行う。
    - REPL やウィジェットで実行中の状態を調べる。

    ## 使い方
    `:DapToggleBreakpoint` で停止点を設定し、`:DapContinue` で開始・再開する。`:DapStepOver` / `:DapStepInto` でステップ実行し、`require("dap").repl.open()` で REPL を開く。

    ## 要件
    README の対応版は最新 nightly、0.12.x（推奨）、0.11.7。言語ごとのデバッグアダプターを別途インストール・設定する。UI 拡張は任意。

    ## 出典
    [固定バージョンの README](https://github.com/mfussenegger/nvim-dap/blob/cfa2d58f4537aca6ca83e2de1a0d9f1491121264/README.md)
  '';

  plugin = sources.nvim-dap;
  config = luaConfig ''
    local dap = require("dap")
    -- Keep the UI open after the debug session ends.
    dap.listeners.before.event_terminated.dapui_config = function() end
    dap.listeners.before.event_exited.dapui_config = function() end
  '';
}
