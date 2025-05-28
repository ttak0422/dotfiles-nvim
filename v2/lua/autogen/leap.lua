-- [nfnl] v2/fnl/leap.fnl
local leap = require("leap")
local spooky = require("leap-spooky")
leap.set_default_mappings()
return spooky.setup({})
