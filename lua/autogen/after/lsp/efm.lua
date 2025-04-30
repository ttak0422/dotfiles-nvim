-- [nfnl] Compiled from fnl/after/lsp/efm.fnl by https://github.com/Olical/nfnl, do not edit.
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
local init_options = {documentFormatting = true, documentRangeFormatting = true}
return {single_file_support = true, filetypes = vim.tbl_keys(languages), settings = {rootMarkers = {".git/"}, languages = languages}, init_options = init_options, capabilities = capabilities}
