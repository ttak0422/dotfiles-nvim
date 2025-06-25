-- [nfnl] v2/fnl/claudecode.fnl
local claude = require("claudecode")
local terminal = {split_side = "right", split_width_percentage = 0.45, provider = "auto", auto_close = true}
local keys = {}
return claude.setup({terminal = terminal, keys = keys})
