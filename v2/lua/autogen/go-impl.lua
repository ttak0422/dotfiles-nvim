-- [nfnl] v2/fnl/go-impl.fnl
local impl = require("go-impl")
local icons = {interface = {text = "\239\131\168 ", hl = "GoImplInterfaceIcon"}, go = {text = "\238\152\167 ", hl = "GoImplGoBlue"}}
local prompt = {receiver = "\243\176\134\188 \239\145\160 ", interface = "\239\131\168 \239\145\160 ", generic = "\243\176\152\187  {name}\239\145\160 "}
return impl.setup({picker = "snacks", icons = icons, prompt = prompt})
