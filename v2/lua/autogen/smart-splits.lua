-- [nfnl] v2/fnl/smart-splits.fnl
local ss = require("smart-splits")
local ignored_filetypes = {"nofile", "quickfix", "prompt"}
local ignored_buftypes = {"NvimTree"}
local ignored_events = {"BufEnter", "WinEnter"}
return ss.setup({ignored_filetypes = ignored_filetypes, ignored_buftypes = ignored_buftypes, ignored_events = ignored_events})
