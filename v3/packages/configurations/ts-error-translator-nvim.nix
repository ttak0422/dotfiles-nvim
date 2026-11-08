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
    # ts-error-translator.nvim

    ## 概要
    TypeScript のエラーを平易な英語の説明へ変換する。

    ## 主な機能
    - 67 種類のエラーメッセージを変換する。
    - `vim.diagnostic` と連携し、指定サーバーの診断を自動変換する。

    ## 使い方
    `require("ts-error-translator").setup({ auto_attach = true, servers = {...} })` で設定する。単独の文字列には `parse_errors(message)` を使い、`TS2339` のようなエラーコードを含める。

    ## 要件
    実行時の外部依存はなく、標準の `vim.regex` を使用する。最低 Neovim バージョンは README に未記載。plenary.nvim は上流のテストスイート用。

    ## 出典
    [固定バージョンの README](https://github.com/dmmulroy/ts-error-translator.nvim/blob/558abff11b9e8f4cefc0de09df780c56841c7a4b/README.md)
  '';

  plugin = sources.ts-error-translator-nvim;
  config = luaConfig (
    # lua
    ''
      require("ts-error-translator").setup({
        auto_attach = true,
        servers = { "astro", "svelte", "ts_ls", "typescript-tools", "volar", "vtsls" },
      })
    ''
  );
}
