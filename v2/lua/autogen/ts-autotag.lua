-- [nfnl] v2/fnl/ts-autotag.fnl
local autotag = require("nvim-ts-autotag")
local filetypes = {"javascript", "typescript", "jsx", "tsx", "vue", "html"}
return autotag.setup({filetypes = filetypes})
