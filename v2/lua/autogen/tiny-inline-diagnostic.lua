-- [nfnl] v2/fnl/tiny-inline-diagnostic.fnl
local diag = require("tiny-inline-diagnostic")
return diag.setup({preset = "classic", transparent_bg = true, virt_texts = {priority = 2048}})
