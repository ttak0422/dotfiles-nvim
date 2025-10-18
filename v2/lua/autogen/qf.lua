-- [nfnl] v2/fnl/qf.fnl
local qf = require("qf")
local opt = {auto_close = true, auto_follow = "prev", auto_follow_limit = 8, follow_slow = true, auto_open = true, auto_resize = true, max_height = 8, min_height = 5, wide = true, focus_open = false, number = false, relativenumber = false, unfocus_close = false}
return qf.setup({l = opt, c = opt, pretty = true, silent = false})
