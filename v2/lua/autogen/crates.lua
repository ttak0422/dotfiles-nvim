-- [nfnl] v2/fnl/crates.fnl
local crates = require("crates")
local lsp = {enabled = true, actions = true, hover = true, completion = false}
return crates.setup({lsp = lsp})
