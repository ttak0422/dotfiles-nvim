-- [nfnl] v2/fnl/lsp-progress.fnl
local progress = require("lsp-progress")
local function format(messages)
  if (#messages > 0) then
    return table.concat(messages, " ")
  else
    return ""
  end
end
return progress.setup({spin_update_time = 400, event_update_time_limit = 500, regular_internal_update_time = 1000000000, max_size = 200, format = format})
