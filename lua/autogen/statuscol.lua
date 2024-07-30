-- [nfnl] Compiled from fnl/statuscol.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local M = setmetatable({builtin = require("statuscol.builtin")}, {__index = require("statuscol")})
  local segments = {{text = {"%s"}, maxwidth = 2, click = "v:lua.ScSa"}, {text = {M.builtin.lnumfunc}, click = "v:lua.ScLa"}, {text = {" ", M.builtin.foldfunc, " "}, click = "v:lua.ScFa"}}
  local ft_ignore = {}
  M.setup({setopt = true, ft_ignore = ft_ignore, segments = segments, relculright = false})
end
vim.o.number = true
vim.o.signcolumn = "yes"
return nil
