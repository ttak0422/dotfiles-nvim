-- [nfnl] v2/fnl/none-ls.fnl
local null_ls = require("null-ls")
local diagnostics = null_ls.builtins.diagnostics
local formatting = null_ls.builtins.formatting
local utils = require("null-ls.utils")
local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")
local FORMATTING = methods.internal.FORMATTING
vim.g.idea_path = args.idea
local sources
local function _1_()
  return (vim.g.checkstyle ~= nil)
end
local function _2_(ps)
  return (ps.bufname ~= "")
end
local function _3_()
  return require("null-ls.utils").root_has_file({"tsconfig.json", "package.json", "jsconfig.json", ".node_project"})
end
local function _4_()
  return (vim.g.idea_format ~= nil)
end
local function _5_()
  return {"format", "-s", vim.g.idea_format, "$FILENAME"}
end
local function _6_()
  return (vim.g.idea_format == nil)
end
sources = {diagnostics.actionlint, diagnostics.checkmake, diagnostics.checkstyle.with({runtime_condition = _1_, extra_args = {"-c", (vim.g.checkstyle or "/google_checks.xml")}}), diagnostics.deadnix, diagnostics.dotenv_linter, diagnostics.editorconfig_checker.with, {runtime_condition = _2_}, diagnostics.gitlint, diagnostics.ktlint, diagnostics.selene, diagnostics.staticcheck, diagnostics.statix, diagnostics.stylelint, diagnostics.vint, diagnostics.yamllint, formatting.prettier.with({prefer_local = "node_modules/.bin", runtime_condition = _3_, filetypes = {"javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "css", "scss", "less", "json", "jsonc", "markdown", "markdown.mdx", "graphql", "handlebars", "svelte", "astro", "htmlangular"}}), require("none-ls.diagnostics.eslint"), formatting.biome, formatting.fantomas, formatting.fnlfmt, formatting.gofumpt, formatting.goimports, helpers.make_builtin({name = "idea", method = FORMATTING, filetypes = {"java", "groovy", "kotlin"}, runtime_condition = _4_, generator_opts = {command = args.idea, args = _5_, timeout = 20000, from_temp_file = true, to_temp_file = true, to_stdin = false}, factory = helpers.formatter_factory}), formatting.google_java_format.with({runtime_condition = _6_, timeout = 20000}), formatting.ktlint, formatting.nixfmt, formatting.shfmt, formatting.stylelint, formatting.stylua, formatting.tidy, formatting.yamlfmt, formatting.yapf}
null_ls.setup({border = "none", cmd = {"nvim"}, debounce = 300, default_timeout = 10000, diagnostic_config = {}, diagnostics_format = "#{m} (#{s})", fallback_severity = vim.diagnostic.severity.ERROR, log_level = "warn", notify_format = "[null-ls] %s", on_attach = nil, on_init = nil, on_exit = nil, root_dir = utils.root_pattern({".null-ls-root", ".git"}), root_dir_async = nil, should_attach = nil, temp_dir = nil, sources = sources, debug = false, update_in_insert = false})
local function _7_()
  return vim.cmd("NullLsInfo")
end
vim.api.nvim_create_user_command("NoneLsInfo", _7_, {})
local function _8_()
  return vim.cmd("NullLsLog")
end
return vim.api.nvim_create_user_command("NoneLsLog", _8_, {})
