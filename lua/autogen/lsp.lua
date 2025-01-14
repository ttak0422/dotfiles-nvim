-- [nfnl] Compiled from fnl/lsp.fnl by https://github.com/Olical/nfnl, do not edit.
local lsp = require("lspconfig")
local climb = require("climbdir")
local marker = require("climbdir.marker")
lsp.lua_ls.setup({settings = {Lua = {runtime = {version = "LuaJIT", special = {reload = "require"}}, diagnostics = {globals = {"vim"}}}, workspace = {library = {vim.fn.expand("$VIMRUNTIME/lua")}}, telemetry = {enable = false}}})
lsp.fennel_ls.setup({settings = {["fennel-ls"] = {["extra-globals"] = "vim"}}})
lsp.nil_ls.setup({autostart = true, settings = {["nil"] = {formatting = {command = {"nixpkgs-fmt"}}}}})
lsp.bashls.setup({})
lsp.csharp_ls.setup({})
lsp.pyright.setup({})
lsp.solargraph.setup({})
lsp.taplo.setup({})
lsp.gopls.setup({})
lsp.dartls.setup({})
lsp.dhall_lsp_server.setup({})
lsp.yamlls.setup({settings = {yaml = {keyOrdering = false}}})
lsp.html.setup({})
lsp.cssls.setup({})
lsp.jsonls.setup({})
local function _1_(path)
  return climb.climb(path, marker.one_of(marker.has_readable_file("package.json"), marker.has_directory("node_modules")), {halt = marker.one_of(marker.has_readable_file("deno.json"))})
end
lsp.vtsls.setup({settings = {separate_diagnostic_server = true, publish_diagnostic_on = "insert_leave", typescript = {suggest = {completeFunctionCalls = true}, preferences = {importModuleSpecifier = "relative"}}}, root_dir = _1_, flags = {debounce_text_changes = 1000}, vtsls = {experimental = {completion = {enableServerSideFuzzyMatch = true}}}, single_file_support = false})
local function _2_(path)
  local found = climb.climb(path, marker.one_of(marker.has_readable_file("deno.json"), marker.has_readable_file("deno.jsonc"), marker.has_directory("denops")), {halt = marker.one_of(marker.has_readable_file("package.json"), marker.has_directory("node_modules"))})
  local buf = vim.b[vim.fn.bufnr()]
  if found then
    buf.deno_deps_candidate = (found .. "/deps.ts")
  else
  end
  return found
end
lsp.denols.setup({root_dir = _2_, init_options = {lint = true, suggest = {completeFunctionCalls = true, names = true, paths = true, autoImports = true, imports = {autoDiscover = true, hosts = vim.empty_dict()}}, unstable = false}, settings = {deno = {enable = true}}, single_file_support = false})
lsp.marksman.setup({})
lsp.ast_grep.setup({})
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
  lsp.efm.setup({single_file_support = true, filetypes = vim.tbl_keys(languages), settings = settings, init_options = init_options})
end
return lsp.kotlin_language_server.setup({})
