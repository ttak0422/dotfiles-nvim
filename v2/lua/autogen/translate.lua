-- [nfnl] v2/fnl/translate.fnl
local translate = require("translate")
local preset = {output = {floating = {zindex = 150}}}
return translate.setup({preset = preset})
