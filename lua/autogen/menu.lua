-- [nfnl] Compiled from fnl/menu.fnl by https://github.com/Olical/nfnl, do not edit.
local menu = require("menu")
local opts = {}
local separator = {name = "separator"}
local default = {{name = "Copy all content", cmd = "%y+"}, separator, {name = "\238\154\144 Edit local config", cmd = "ConfigLocalEdit"}}
local function _1_()
  return menu.open(default, opts)
end
return vim.api.nvim_create_user_command("OpenMenu", _1_, {})
