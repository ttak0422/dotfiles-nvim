-- [nfnl] v2/fnl/better-escape.fnl
local be = require("better_escape")
return be.setup({mappings = {i = {j = {k = "<Esc>"}}, c = {}, t = {}, v = {}, s = {}}, default_mappings = false})
