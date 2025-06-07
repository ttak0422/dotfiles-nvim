-- [nfnl] v2/fnl/glance.fnl
local glance = require("glance")
local border = {enable = true, top_char = "\226\148\129", bottom_char = "\226\148\129"}
local folds = {fold_closed = "\226\150\184", fold_open = "\226\150\190", folded = true}
return glance.setup({border = border, folds = folds, use_trouble_qf = true})
