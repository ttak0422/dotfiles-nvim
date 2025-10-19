-- [nfnl] v2/fnl/blame.fnl
local blame = require("blame")
local mappings = {commit_info = "i", stack_push = "<TAB>", stack_pop = "<BS>", show_commit = "<CR>", close = {"<esc>", "q"}}
return blame.setup({date_format = "%Y-%m-%d", virtual_style = "right_align", focus_blame = true, max_summary_width = 30, colors = nil, blame_options = nil, commit_detail_view = "vsplit", mappings = mappings, merge_consecutive = false, relative_date_if_recent = false})
