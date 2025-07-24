-- [nfnl] v2/fnl/auto-save.fnl
local auto_save = require("auto-save")
local data = require("auto-save.utils.data")
local targets = data.set_of({"md", "markdown", "norg", "neorg"})
local function _1_(buf)
  return (((vim.fn.getbufvar(buf, "&modifiable") == 1) and targets[vim.fn.getbufvar(buf, "&filetype")]) or false)
end
return auto_save.setup({events = {"InsertLeave", "TextChanged"}, debounce_delay = 500, condition = _1_})
