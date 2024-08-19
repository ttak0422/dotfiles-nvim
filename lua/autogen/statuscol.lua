-- [nfnl] Compiled from fnl/statuscol.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local opts = {foldcolumn = "1", signcolumn = "yes", number = true, foldenable = true}
  for k, v in pairs(opts) do
    vim.o[k] = v
  end
end
local M = setmetatable({builtin = require("statuscol.builtin")}, {__index = require("statuscol")})
local segments = {{text = {"%s"}, maxwidth = 2, click = "v:lua.ScSa"}, {text = {M.builtin.lnumfunc}, click = "v:lua.ScLa"}, {text = {" ", M.builtin.foldfunc, " "}, click = "v:lua.ScFa"}}
return M.setup({setopt = true, segments = segments, relculright = false})
