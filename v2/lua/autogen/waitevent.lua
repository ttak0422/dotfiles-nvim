-- [nfnl] v2/fnl/waitevent.fnl
local editor
local function _1_(ctx, _path)
  ctx.lcd()
  vim.bo.bufhidden = "wipe"
  return nil
end
editor = require("waitevent").editor({open = _1_})
vim.env.EDITOR = editor
vim.env.GIT_EDITOR = editor
return nil
