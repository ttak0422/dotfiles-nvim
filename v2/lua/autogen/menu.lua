-- [nfnl] v2/fnl/menu.fnl
local menu = require("menu")
local separator = {name = "separator"}
local default
local function _1_()
  vim.o.list = not vim.o.list
  return nil
end
local function _2_()
  return require("smear_cursor").toggle()
end
local function _3_()
  return vim.cmd("TimerlyToggle")
end
local function _4_()
  return vim.cmd("ShowkeysToggle")
end
local function _5_()
  return vim.cmd("Huefy")
end
default = {{hl = "Normal", name = "\239\136\132 Toggle NoNeckPain", cmd = "NoNeckPain"}, {hl = "Normal", name = "\239\136\132 Toggle List", cmd = _1_}, {hl = "Normal", name = "\239\136\132 Toggle colorize", cmd = "ColorizerToggle"}, {hl = "Normal", name = "\238\154\144 Edit local config", cmd = "ConfigLocalEdit"}, {hl = "Normal", name = "\243\176\158\183 Open scratch buffer", cmd = "RepluaOpen"}, {hl = "Normal", name = "\239\136\132 Toggle cursor animation", cmd = _2_}, separator, {hl = "Normal", name = "\243\176\132\137 Timer", cmd = _3_}, {hl = "Normal", name = "\239\132\156 Show keys", cmd = _4_}, {hl = "Normal", name = "\239\133\128 Color Picker", cmd = _5_}}
local function _6_()
  return menu.open(default, {border = true})
end
return vim.api.nvim_create_user_command("OpenMenu", _6_, {})
