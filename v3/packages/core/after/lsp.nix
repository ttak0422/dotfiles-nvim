{ pkgs }:
with pkgs;
{
  "after/lsp/denols.lua" = # lua
    ''
      return {
        single_file_support = false,
        workspace_required = true,
        root_markers = { "deno.json", "deno.jsonc", ".deno_project" },
        init_options = {
          lint = true,
          unstable = false,
          suggest = {
            completeFunctionCalls = true,
            names = true,
            paths = true,
            autoImports = true,
            imports = { autoDiscover = true, hosts = vim.empty_dict() },
          },
        },
        settings = { deno = { enable = true } },
      }
    '';
  "after/lsp/efm.lua" = # lua
    ''
      local languages = {}
      return {
        single_file_support = true,
        filetypes = vim.tbl_keys(languages),
        settings = { rootMarkers = { ".git/" }, languages = languages },
        init_options = { documentFormatting = true, documentRangeFormatting = true },
      }
    '';
  "after/lsp/fennel_ls.lua" = # lua
    ''
      return { settings = { ["fennel-ls"] = { ["extra-globals"] = "vim" } } }
    '';
  "after/lsp/eslint.lua" = # lua
    ''
      local args = ${lib.generators.toLua { } { node_path = "${eslint}/lib/node_modules"; }}
      return {
        cmd = { "vscode-eslint-language-server", "--stdio" },
        -- Project-local ESLint wins over this packaged fallback.
        cmd_env = { NODE_PATH = args.node_path },
        -- Keep formatting with Prettier/Biome, while retaining code actions.
        settings = { nodePath = vim.NIL, format = false },
      }
    '';
  "after/lsp/jdtls.lua" = # lua
    ''
      -- Java's ftplugin starts JDT LS with its per-project workspace.
      return { filetypes = {} }
    '';
  "after/lsp/lua_ls.lua" = # lua
    ''
      return {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT", special = { reload = "require" } },
            diagnostics = { globals = { "vim" } },
          },
          workspace = { library = { vim.fn.expand("$VIMRUNTIME/lua"), "''${3rd}/luv/library" } },
          telemetry = { enable = false },
        },
      }
    '';
  "after/lsp/nil_ls.lua" = # lua
    ''
      return {
        settings = {
          ["nil"] = {
            formatting = { command = { "nixpkgs-fmt" } },
            nix = { flake = { autoArchive = false } },
          },
        },
      }
    '';
  "after/lsp/pyright.lua" = # lua
    ''
      return {
        settings = {
          python = {
            pythonPath = ".venv/bin/python",
            analysis = { diagnosticSeverityOverrides = { reportUnusedExpression = "none" } },
          },
        },
      }
    '';
  "after/lsp/typos_lsp.lua" = # lua
    ''
      return { init_options = { diagnosticSeverity = "Warning" } }
    '';
  "after/lsp/vtsls.lua" = # lua
    ''
      local function publish_diagnostics(err, result, ctx, config)
        -- Hide only the CommonJS-to-ES-module suggestion, without mutating the payload.
        if not err and result and result.diagnostics then
          result = vim.tbl_extend("force", {}, result, {
            diagnostics = vim.tbl_filter(function(diagnostic)
              return diagnostic.code ~= 80001 and diagnostic.code ~= "80001"
            end, result.diagnostics),
          })
        end
        -- Resolve at notification time so later global wrappers still run.
        return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
      end

      return {
        single_file_support = false,
        workspace_required = true,
        root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".node_project" },
        handlers = { ["textDocument/publishDiagnostics"] = publish_diagnostics },
        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = "insert_leave",
          typescript = {
            suggest = { completeFunctionCalls = true },
            preferences = { importModuleSpecifier = "relative" },
          },
        },
        flags = { debounce_text_changes = 1000 },
        vtsls = { experimental = { completion = { enableServerSideFuzzyMatch = true } } },
      }
    '';
  "after/lsp/yamlls.lua" = # lua
    ''
      return {
        settings = {
          yaml = {
            keyOrdering = false,
            customTags = {
              "!And", "!Base64", "!Cidr", "!Equals", "!FindInMap sequence",
              "!GetAZs", "!GetAtt", "!If", "!ImportValue", "!Join sequence",
              "!Not", "!Or", "!Ref Scalar", "!Ref", "!Select", "!Split", "!Sub", "!fn",
            },
          },
        },
      }
    '';
}
