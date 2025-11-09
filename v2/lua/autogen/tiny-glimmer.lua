-- [nfnl] v2/fnl/tiny-glimmer.fnl
local glimmer = require("tiny-glimmer")
local overwrite = {search = {enabled = false}, paste = {enabled = true}, yank = {enabled = true}, undo = {enabled = true}, redo = {enabled = true}}
return glimmer.setup({enabled = true, overwrite = overwrite})
