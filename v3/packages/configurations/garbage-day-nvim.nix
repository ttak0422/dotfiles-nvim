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
    # garbage-day.nvim

    ## 概要
    非アクティブな LSP クライアントを停止してメモリを解放する。

    ## 主な機能
    - フォーカスを失ってから一定時間後に LSP を停止し、復帰時に再開する。
    - 除外クライアント、待機時間、積極的な停止モードを設定できる。

    ## 使い方
    `grace_period`、`wakeup_delay`、`excluded_lsp_clients` を設定する。手動操作は `require("garbage-day.utils").stop_lsp()` / `start_lsp()`。

    ## 要件
    README の動作確認対象は Neovim 0.10〜0.13。`grace_period` は `timeout / 1000` より大きくする必要がある。

    ## 出典
    [固定バージョンの README](https://github.com/Zeioth/garbage-day.nvim/blob/225b715cf7e502977e5e040219cf5009eed70ee1/README.md)
  '';

  plugin = sources.garbage-day-nvim;
  config = luaConfig (
    # lua
    ''
      require("garbage-day").setup({
        excluded_lsp_clients = { "jdtls" },
        grace_period = 60 * 30,
        wakeup_delay = 500,
      })
    ''
  );
}
