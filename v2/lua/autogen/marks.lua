-- [nfnl] v2/fnl/marks.fnl
local marks = require("marks")
local sign_priority = {lower = 10, upper = 15, builtin = 8, bookmark = 20}
return marks.setup({default_mappings = true, refresh_interval = 500, sign_priority = sign_priority})
