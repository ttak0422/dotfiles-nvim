-- [nfnl] v2/fnl/trace-pr.fnl
local tp = require("trace-pr")
return tp.setup({trace_by_commit_hash_when_pr_not_found = true})
