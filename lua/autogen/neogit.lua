-- [nfnl] Compiled from fnl/neogit.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("neogit")
local signs = {hunk = {"", ""}, item = {"\239\145\160", "\239\145\188"}, section = {"\239\145\160", "\239\145\188"}}
local integrations = {telescope = true, diffview = true, fzf_lua = nil}
return M.setup({use_default_keymaps = true, kind = "split", graph_style = "unicode", console_timeout = 10000, signs = signs, integrations = integrations, disable_context_highlighting = false, disable_hint = false, disable_signs = false, process_spinner = false})
