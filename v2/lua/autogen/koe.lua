-- [nfnl] v2/fnl/koe.fnl
local koe = require("koe")
koe.setup({locale = "ja-JP"})
return vim.keymap.set({"i", "t"}, "<M-t>", koe.toggle, {silent = true, desc = "koe: dictation toggle"})
