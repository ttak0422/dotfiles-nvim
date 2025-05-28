-- [nfnl] v2/fnl/autoclose.fnl
local autoclose = require("autoclose")
local keys = {["("] = {close = true, pair = "()", escape = false}, ["["] = {close = true, pair = "[]", escape = false}, ["{"] = {close = true, pair = "{}", escape = false}, [">"] = {escape = true, pair = "<>", close = false}, [")"] = {escape = true, pair = "()", close = false}, ["]"] = {escape = true, pair = "[]", close = false}, ["}"] = {escape = true, pair = "{}", close = false}, ["\""] = {escape = true, close = true, pair = "\"\""}, ["'"] = {escape = true, close = true, pair = "''"}, ["`"] = {escape = true, close = true, pair = "``"}}
local options = {disabled_filetypes = {"text", "spectre_panel", "norg", "TelescopePrompt"}, touch_regex = "[%w(%[{]", auto_indent = true, disable_command_mode = true, disable_when_touch = false, pair_spaces = false}
return autoclose.setup({keys = keys, options = options})
