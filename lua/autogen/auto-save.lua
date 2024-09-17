-- [nfnl] Compiled from fnl/auto-save.fnl by https://github.com/Olical/nfnl, do not edit.
local auto_save = require("auto-save")
local utils = require("auto-save.utils.data")
local events = {"InsertLeave", "TextChanged"}
local condition
local function _1_(buf)
  if ((vim.fn.getbufvar(buf, "&modifiable") == 1) and utils.set_of({"md", "markdown", "norg", "neorg"})[vim.fn.getbufvar(buf, "&filetype")]) then
    return true
  else
    return false
  end
end
condition = _1_
return auto_save.setup({events = events, condition = condition})
