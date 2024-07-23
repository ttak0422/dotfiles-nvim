-- [nfnl] Compiled from fnl/neogit.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("neogit")
local integrations = {telescope = true, diffview = true, fzf_lua = nil}
return M.setup({use_default_keymaps = true, graph_style = "unicode", console_timeout = 10000, integrations = integrations, disable_signs = false, disable_hint = false, disable_context_highlighting = false})
