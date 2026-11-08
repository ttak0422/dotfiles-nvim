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
        vim.lsp.enable({
          "bashls", "cssls", "dartls", "denols", "dhall_lsp_server", "eslint",
          "fennel_ls", "gopls", "html", "jsonls", "lua_ls", "marksman", "nil_ls",
          "pyright", "rubocop", "ruff", "solargraph", "taplo", "teal_ls",
          "terraformls", "vtsls", "yamlls",
        })
      '';
    args.attach_path = ../core/lsp-attach.lua;
  });
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
    marksman
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
