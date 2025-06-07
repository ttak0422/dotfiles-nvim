-- [nfnl] v2/fnl/logrotate.fnl
local logrotate = require("logrotate")
return logrotate.setup({targets = {(vim.fn.stdpath("state") .. "/lsp.log")}, interval = "daily"})
