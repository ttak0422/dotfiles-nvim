-- [nfnl] v2/fnl/bqf.fnl
local bqf = require("bqf")
local func_map = {open = "<CR>", openc = "o", drop = "O", split = "<C-s>", vsplit = "<C-v>", tab = "<C-t>", tabb = "", tabc = "", tabdrop = "", ptogglemode = "zp", ptoggleitem = "p", ptoggleauto = "P", pscrollup = "<C-b>", pscrolldown = "<C-f>", pscrollorig = "zo", prevfile = "", nextfile = "", prevhist = "", nexthist = "", lastleave = "'\"", stoggleup = "<S-Tab>", stoggledown = "<Tab>", stogglevm = "<Tab>", stogglebuf = "'<Tab>", sclear = "z<Tab>", filter = "zn", filterr = "zN", fzffilter = ""}
return bqf.setup({func_map = func_map})
