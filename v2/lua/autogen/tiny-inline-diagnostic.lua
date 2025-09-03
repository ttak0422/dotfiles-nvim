-- [nfnl] v2/fnl/tiny-inline-diagnostic.fnl
local diag = require("tiny-inline-diagnostic")
return diag.setup({preset = "nonerdfont", virt_texts = {priority = 2048}})
