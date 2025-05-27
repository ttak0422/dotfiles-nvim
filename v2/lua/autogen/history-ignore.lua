-- [nfnl] v2/fnl/history-ignore.fnl
local history = require("history-ignore")
local ignore_words = {"^buf$", "^history$", "^h$", "^q$", "^qa$", "^w$", "^wq$", "^wa$", "^wqa$", "^q!$", "^qa!$", "^w!$", "^wq!$", "^wa!$", "^wqa!$"}
return history.setup({ignore_words = ignore_words})
