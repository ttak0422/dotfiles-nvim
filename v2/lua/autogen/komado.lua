-- [nfnl] v2/fnl/komado.fnl
local komado = require("komado")
local utils = require("komado.utils")
local Line = require("komado.dsl").Line
local Spacer = Line({provider = ""})
local Separator = utils.separator("\226\148\128", "Comment")
local Header = {Line({{provider = "\226\150\160 komado "}}), Separator}
local function _1_()
  return komado.close()
end
local function _2_()
  return komado.redraw()
end
komado.setup({window = {position = "left", size = {ratio = 0.3, min = 38, max = 80}}, mappings = {q = _1_, r = _2_}, root = {Header, Spacer}})
local function _3_()
  return komado.toggle()
end
return vim.api.nvim_create_user_command("KomadoToggle", _3_, {})
