-- [nfnl] Compiled from fnl/lsp-progress.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("lsp-progress")
local format
local function _1_(messages)
  if (#messages > 0) then
    return table.concat(messages, " ")
  else
    return ""
  end
end
format = _1_
return M.setup({spin_update_time = 200, event_update_time_limit = 400, regular_internal_update_time = 1000000000, max_size = 200, format = format})
