-- [nfnl] Compiled from v2/fnl/helpview.fnl by https://github.com/Olical/nfnl, do not edit.
local helpview = require("helpview")
local preview = {modes = {"n", "c", "no"}}
local vimdoc = {}
return helpview.setup({preview = preview, vimdoc = vimdoc})
