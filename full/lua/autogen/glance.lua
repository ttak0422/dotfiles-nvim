-- [nfnl] Compiled from full/fnl/glance.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("glance")
local border = {enable = true, top_char = "\226\148\129", bottom_char = "\226\148\129"}
local folds = {fold_closed = "\226\150\184", fold_open = "\226\150\190", folded = true}
return M.setup({border = border, folds = folds})
