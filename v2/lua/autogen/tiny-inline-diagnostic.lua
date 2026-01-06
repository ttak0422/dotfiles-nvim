-- [nfnl] v2/fnl/tiny-inline-diagnostic.fnl
local diag = require("tiny-inline-diagnostic")
return diag.setup({preset = "classic", transparent_bg = true, hi = {error = "DiagnosticError", warn = "DiagnosticWarn", info = "DiagnosticInfo", hint = "DiagnosticHint", arrow = "NonText", background = "CursorLine", mixing_color = "None"}, virt_texts = {priority = 2048}})
