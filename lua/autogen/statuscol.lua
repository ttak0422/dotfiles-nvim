-- [nfnl] Compiled from fnl/statuscol.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("statuscol")
local builtin = require("statuscol.builtin")
local segments = {{text = {"%s"}, maxwidth = 2, click = "v:lua.ScSa"}, {text = {builtin.lnumfunc}, click = "v:lua.ScLa"}, {text = {" ", builtin.foldfunc, " "}, click = "v:lua.ScFa"}}
M.setup({foldfunc = "builtin", setopt = true, segments = segments, relculright = false})
local function _1_()
  if (vim.o.statuscolumn == "") then
    return M.setup({setopt = true, segments = segments, relculright = false})
  else
    return nil
  end
end
return vim.api.nvim_create_autocmd({"BufReadPost"}, {pattern = {"*"}, callback = _1_})
