-- [nfnl] v2/fnl/spectre.fnl
local spectre = require("spectre")
return spectre.setup({default = {find = {cmd = "rg", options = {}}, replace = {cmd = "sd"}}, color_devicons = false, is_block_ui_break = false, live_update = false})
