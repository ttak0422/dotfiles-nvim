-- [nfnl] v2/fnl/lensline.fnl
local ll = require("lensline")
return ll.setup({debounce_ms = 1000, focused_debounce_ms = 200, style = {placement = "inline", prefix = "", render = "focused"}})
