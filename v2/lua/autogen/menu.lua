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
default = {{hl = "Normal", name = "\239\136\132 Toggle NoNeckPain", cmd = "NoNeckPain"}, {hl = "Normal", name = "\239\136\132 Toggle colorize", cmd = "ColorizerToggle"}, {hl = "Normal", name = "\238\154\144 Edit local config", cmd = "ConfigLocalEdit"}, separator, {hl = "Normal", name = "\243\176\132\137 Timer", cmd = _1_}, {hl = "Normal", name = "\239\132\156 Show keys", cmd = _2_}, {hl = "Normal", name = "\239\133\128 Color Picker", cmd = _3_}}
local function _4_()
  return menu.open(default, {border = true})
end
return vim.api.nvim_create_user_command("OpenMenu", _4_, {})
