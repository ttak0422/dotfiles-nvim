-- [nfnl] v2/fnl/trim.fnl
local trim = require("trim")
return trim.setup({ft_blocklist = {"markdown", "neorg", "norg"}})
