-- [nfnl] Compiled from fnl/lsp.fnl by https://github.com/Olical/nfnl, do not edit.
local on_attach = dofile(args.on_attach_path)
vim.lsp.set_log_level("ERROR")
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "none"})
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {update_in_insert = false})
vim.diagnostic.config({severity_sort = true, signs = {text = {[vim.diagnostic.severity.ERROR] = "\239\145\132", [vim.diagnostic.severity.WARN] = "\239\145\132", [vim.diagnostic.severity.INFO] = "\239\145\132", [vim.diagnostic.severity.HINT] = "\239\145\132"}, numhl = {[vim.diagnostic.severity.ERROR] = "", [vim.diagnostic.severity.WARN] = "", [vim.diagnostic.severity.INFO] = "", [vim.diagnostic.severity.HINT] = ""}}, virtual_text = false})
local lspconfig = require("lspconfig")
local windows = require("lspconfig.ui.windows")
local climb = require("climbdir")
local marker = require("climbdir.marker")
windows.default_options.border = "none"
lspconfig.lua_ls.setup({on_attach = on_attach, settings = {Lua = {runtime = {version = "LuaJIT"}, diagnostics = {globals = {"vim"}}}, workspace = {}, telemetry = {enable = false}}})
lspconfig.fennel_ls.setup({on_attach = on_attach, settings = {["fennel-ls"] = {["extra-globals"] = "vim"}}})
lspconfig.nil_ls.setup({on_attach = on_attach, autostart = true, settings = {["nil"] = {formatting = {command = {"nixpkgs-fmt"}}}}})
lspconfig.bashls.setup({on_attach = on_attach})
lspconfig.csharp_ls.setup({on_attach = on_attach})
lspconfig.pyright.setup({on_attach = on_attach})
lspconfig.solargraph.setup({on_attach = on_attach})
lspconfig.taplo.setup({on_attach = on_attach})
lspconfig.gopls.setup({on_attach = on_attach, settings = {gopls = {analyses = {unusedparams = true, unusedvariable = true, useany = true}, staticcheck = false}}})
lspconfig.dartls.setup({on_attach = on_attach})
lspconfig.dhall_lsp_server.setup({on_attach = on_attach})
lspconfig.yamlls.setup({on_attach = on_attach, settings = {yaml = {keyOrdering = false}}})
lspconfig.html.setup({on_attach = on_attach})
lspconfig.cssls.setup({on_attach = on_attach})
lspconfig.jsonls.setup({on_attach = on_attach})
local function _1_(path)
  return climb.climb(path, marker.one_of(marker.has_readable_file("package.json"), marker.has_directory("node_modules")), {halt = marker.one_of(marker.has_readable_file("deno.json"))})
end
lspconfig.vtsls.setup({on_attach = on_attach, settings = {separate_diagnostic_server = true, publish_diagnostic_on = "insert_leave", typescript = {suggest = {completeFunctionCalls = true}, preferences = {importModuleSpecifier = "relative"}}}, root_dir = _1_, vtsls = {experimental = {completion = {enableServerSideFuzzyMatch = true}}}, single_file_support = false})
local function _2_(path)
  local found = climb.climb(path, marker.one_of(marker.has_readable_file("deno.json"), marker.has_readable_file("deno.jsonc"), marker.has_directory("denops")), {halt = marker.one_of(marker.has_readable_file("package.json"), marker.has_directory("node_modules"))})
  local buf = vim.b[vim.fn.bufnr()]
  if found then
    buf.deno_deps_candidate = (found .. "/deps.ts")
  else
  end
  return found
end
lspconfig.denols.setup({on_attach = on_attach, root_dir = _2_, init_options = {lint = true, suggest = {completeFunctionCalls = true, names = true, paths = true, autoImports = true, imports = {autoDiscover = true, hosts = vim.empty_dict()}}, unstable = false}, settings = {deno = {enable = true}}, single_file_support = false})
lspconfig.marksman.setup({on_attach = on_attach})
lspconfig.ast_grep.setup({on_attach = on_attach})
do
  local luacheck = require("efmls-configs.linters.luacheck")
  local eslint = require("efmls-configs.linters.eslint")
  local yamllint = require("efmls-configs.linters.yamllint")
  local statix = require("efmls-configs.linters.statix")
  local stylelint = require("efmls-configs.linters.stylelint")
  local vint = require("efmls-configs.linters.vint")
  local shellcheck = require("efmls-configs.linters.shellcheck")
  local pylint = require("efmls-configs.linters.pylint")
  local gitlint = require("efmls-configs.linters.gitlint")
  local hadolint = require("efmls-configs.linters.hadolint")
  local languages = {lua = {luacheck}, typescript = {eslint}, javascript = {eslint}, sh = {shellcheck}, yaml = {yamllint}, nix = {statix}, css = {stylelint}, scss = {stylelint}, less = {stylelint}, saas = {stylelint}, vim = {vint}, python = {pylint}, gitcommit = {gitlint}, docker = {hadolint}}
  local settings = {rootMarkers = {".git/"}, languages = languages}
  local init_options = {documentFormatting = true, documentRangeFormatting = true}
  local make_settings
  local function _4_()
    return {single_file_support = true, filetypes = vim.tbl_keys(languages), settings = settings, init_options = init_options, on_attach = on_attach}
  end
  make_settings = _4_
  lspconfig.efm.setup(make_settings())
end
return lspconfig.kotlin_language_server.setup({on_attach = on_attach})
