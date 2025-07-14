-- [nfnl] v2/fnl/garbage-day.fnl
local gc = require("garbage-day")
return gc.setup({excluded_lsp_clients = {"jdtls"}, grace_period = (60 * 30), wakeup_delay = 500})
