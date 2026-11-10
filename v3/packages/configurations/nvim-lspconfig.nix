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
  doc = ''
    # nvim-lspconfig

    ## 概要
    Neovim 標準 LSP クライアント向けのサーバー設定集。

    ## 主な機能
    - 言語サーバーごとの起動・ルート検出設定を提供する。
    - `vim.lsp.config()` による設定拡張に対応する。

    ## 使い方
    `vim.lsp.enable("pyright")` のように設定を有効にする。`:LspInfo` または `:checkhealth vim.lsp` で状態を確認する。旧 `require("lspconfig").….setup()` は非推奨。

    Markdown は markdown-oxide を使用する。`.git`・`.obsidian`・`.moxide.toml` をルートとして、
    ノート・見出し・ブロックへのリンク補完、`gd` による移動、`gr` による参照元検索を提供する。
    ファイル監視の動的登録を有効にし、外部で追加したノートも索引に反映する。
    補完はノート名で検索する（例: `[[Target Note#He`）。v0.25.12 ではハイフンを含むブロック ID は解決できないため、`^blockid` のような ID を使う。

    ## 要件
    Neovim 0.11.3 以上。各言語サーバーを別途導入し、必要なルートマーカーや実行パスを設定する。

    ## 出典
    - [固定バージョンの README](https://github.com/neovim/nvim-lspconfig/blob/4d363f93c3581b9212a24f7a830d7590b3f050af/README.md)
    - [markdown-oxide の Neovim 設定](https://github.com/Feel-ix-343/markdown-oxide/blob/v0.25.12/README.md#neovim)
  '';

  plugin = sources.nvim-lspconfig.overrideAttrs {
    dependencies = [ ];
  };
  dependPlugins = [
    definitions.cmp-nvim-lsp
  ];
  config = luaConfig ({
    code = # lua
      ''
        vim.lsp.log.set_level(vim.log.levels.ERROR)
        local severity = vim.diagnostic.severity
        local diagnostic_min_severity = { kotlin_lsp = severity.INFO }
        local publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
        vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
          local client = vim.lsp.get_client_by_id(ctx.client_id)
          local threshold = client and diagnostic_min_severity[client.name]
          if threshold and result and result.diagnostics then
            result.diagnostics = vim.tbl_filter(function(diagnostic)
              return not diagnostic.severity or diagnostic.severity <= threshold
            end, result.diagnostics)
          end
          return publish_diagnostics(err, result, ctx, config)
        end
        vim.diagnostic.config({
          severity_sort = true,
          signs = {
            text = {
              [severity.ERROR] = "",
              [severity.WARN] = "",
              [severity.INFO] = "",
              [severity.HINT] = "",
            },
            numhl = {
              [severity.ERROR] = "",
              [severity.WARN] = "",
              [severity.INFO] = "",
              [severity.HINT] = "",
            },
          },
          update_in_insert = false,
          virtual_text = false,
        })
        vim.api.nvim_create_autocmd("LspAttach", {
          desc = "register lsp keymaps",
          callback = function(event)
            dofile(args.attach_path)({
              buf = event.buf,
              client = vim.lsp.get_client_by_id(event.data.client_id),
            })
          end,
        })
        -- Merge with nvim-lspconfig's command, filetypes and root markers.
        vim.lsp.config("markdown_oxide", {
          capabilities = vim.tbl_deep_extend("force",
            require("cmp_nvim_lsp").default_capabilities(), {
              workspace = {
                didChangeWatchedFiles = { dynamicRegistration = true },
              },
            }),
        })
        vim.lsp.enable({
          "bashls", "cssls", "dartls", "denols", "dhall_lsp_server", "eslint",
          "fennel_ls", "gopls", "html", "jsonls", "lua_ls", "markdown_oxide", "nil_ls",
          "pyright", "rubocop", "ruff", "solargraph", "taplo", "teal_ls",
          "terraformls", "vtsls", "yamlls",
        })
      '';
    args.attach_path = ../core/lsp-attach.lua;
  });
  tests.markdown-oxide = luaCheck {
    name = "markdown-oxide";
    script = builtins.readFile ../checks/markdown-oxide.lua;
  };
  extraPackages = with pkgs; [
    bash-language-server
    dart
    deno
    dhall-lsp-server
    fennel-ls
    flutter
    go
    go-tools
    google-java-format
    gopls
    lua-language-server
    luajitPackages.teal-language-server
    markdown-oxide
    nil
    nixd
    pyright
    rubyPackages.solargraph
    rubyPackages.rubocop
    ruff
    rust-analyzer
    taplo
    terraform-ls
    typescript
    v2.kotlin-lsp
    vscode-langservers-extracted
    vtsls
    yaml-language-server
  ];
}
