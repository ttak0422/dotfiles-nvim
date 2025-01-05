-- [nfnl] Compiled from fnl/menu.fnl by https://github.com/Olical/nfnl, do not edit.
local menu = require("menu")
local opts = {}
local separator = {name = "separator"}
local default
local function _1_()
  return vim.cmd("TimerlyToggle")
end
local function _2_()
  return vim.cmd("Huefy")
end
default = {{name = "Copy all content", cmd = "%y+"}, {name = "\238\154\144 Edit local config", cmd = "ConfigLocalEdit"}, separator, {name = "\243\176\132\137 Timer", cmd = _1_}, {name = "\239\133\128 Color Picker", cmd = _2_}}
local function _3_()
  return menu.open(default, opts)
end
return vim.api.nvim_create_user_command("OpenMenu", _3_, {})
