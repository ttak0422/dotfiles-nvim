-- [nfnl] v2/fnl/gitsigns.fnl
local signs = require("gitsigns")
local current_line_blame_opts = {virt_text = true, virt_text_pos = "eol", delay = 1000, virt_text_priority = 300, use_focus = true, ignore_whitespace = false}
return signs.setup({signcolumn = true, numhl = true, current_line_blame_formatter = "<author> <author_time:%Y-%m-%d> - <summary>", sign_priority = 6, update_debounce = 1000, max_file_length = 40000, current_line_blame = true, current_line_blame_opts = current_line_blame_opts, linehl = false, word_diff = false})
