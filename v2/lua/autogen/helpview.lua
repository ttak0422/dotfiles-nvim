-- [nfnl] v2/fnl/helpview.fnl
local helpview = require("helpview")
local preview = {modes = {"n", "c", "no"}}
local vimdoc = {}
return helpview.setup({preview = preview, vimdoc = vimdoc})
