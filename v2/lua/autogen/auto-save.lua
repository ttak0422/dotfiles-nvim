-- [nfnl] Compiled from v2/fnl/auto-save.fnl by https://github.com/Olical/nfnl, do not edit.
local auto_save = require("auto-save")
local data = require("auto-save.utils.data")
local targets = data.set_of({"md", "markdown", "norg", "neorg"})
local function _1_(buf)
  return ((vim.fn.getbufvar(buf, "&modifiable") == 1) and targets[vim.fn.getbufvar(buf, "&filetype")])
end
return auto_save.setup({events = {"InsertLeave", "TextChanged"}, condition = _1_})
