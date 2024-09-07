-- [nfnl] Compiled from fnl/statuscol.fnl by https://github.com/Olical/nfnl, do not edit.
for k, v in pairs({foldcolumn = "1", signcolumn = "yes", number = true, foldenable = true}) do
  vim.opt[k] = v
end
local M = require("statuscol")
local builtin = require("statuscol.builtin")
local segments = {{text = {"%s"}, maxwidth = 2, click = "v:lua.ScSa"}, {text = {builtin.lnumfunc}, click = "v:lua.ScLa"}, {text = {" ", builtin.foldfunc, " "}, click = "v:lua.ScFa"}}
return M.setup({setopt = true, segments = segments, relculright = false})
