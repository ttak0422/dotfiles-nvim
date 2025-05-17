-- [nfnl] Compiled from v2/fnl/crates.fnl by https://github.com/Olical/nfnl, do not edit.
local crates = require("crates")
local lsp = {enabled = true, actions = true, hover = true, completion = false}
local null_ls = {enabled = true, name = "crates.nvim"}
return crates.setup({lsp = lsp, null_ls = null_ls})
