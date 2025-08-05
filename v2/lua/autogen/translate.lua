-- [nfnl] v2/fnl/translate.fnl
local translate = require("translate")
local preset = {output = {floating = {zindex = 150}, split = {position = "bottom", min_size = 5, max_size = 0.5, name = "translate://output", filetype = "translate", append = false}}}
local default = {output = "split"}
return translate.setup({preset = preset, default = default})
