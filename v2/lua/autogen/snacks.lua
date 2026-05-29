-- [nfnl] v2/fnl/snacks.fnl
local snacks = require("snacks")
local bigfile = {notify = true, size = (1 * 1024 * 1024), line_length = 2000}
return snacks.setup({bigfile = bigfile})
