-- [nfnl] v2/fnl/notify.fnl
local notify = require("notify")
notify.setup({timeout = 2500, render = "default", stages = "static", background_colour = "#000000", top_down = false})
vim.notify = notify
return nil
