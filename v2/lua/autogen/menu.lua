-- [nfnl] v2/fnl/menu.fnl
local menu = require("menu")
local separator = {name = "separator"}
local default
local function _1_()
  return vim.cmd("TimerlyToggle")
end
local function _2_()
  return vim.cmd("ShowkeysToggle")
end
local function _3_()
  return vim.cmd("Huefy")
end
default = {{name = "Copy all content", cmd = "%y+"}, {name = "\238\154\144 Edit local config", cmd = "ConfigLocalEdit"}, {name = "\239\136\132 Toggle colorize", cmd = "ColorizerToggle"}, separator, {name = "\243\176\132\137 Timer", cmd = _1_}, {name = "\239\132\156 Show keys", cmd = _2_}, {name = "\239\133\128 Color Picker", cmd = _3_}}
local function _4_()
  return menu.open(default, {})
end
return vim.api.nvim_create_user_command("OpenMenu", _4_, {})
