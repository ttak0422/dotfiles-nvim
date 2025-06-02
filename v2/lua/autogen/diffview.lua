-- [nfnl] v2/fnl/diffview.fnl
local diffview = require("diffview")
return diffview.setup({icons = {folder_closed = "\238\151\191", folder_open = "\238\151\190"}, signs = {fold_closed = "\226\150\184", fold_open = "\226\150\190", done = "\226\156\147"}})
