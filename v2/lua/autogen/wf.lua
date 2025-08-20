-- [nfnl] v2/fnl/wf.fnl
local wf = require("wf")
local whichkey = require("wf.builtin.which_key")
wf.setup({theme = "default"})
return vim.keymap.set("n", "<Leader>", whichkey({text_insert_in_advance = "<Leader>"}), {noremap = true, silent = true})
