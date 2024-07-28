-- [nfnl] Compiled from fnl/statuscol.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local M = setmetatable({builtin = require("statuscol.builtin")}, {__index = require("statuscol")})
  local segments = {{text = {"%s"}, maxwidth = 2, click = "v:lua.ScSa"}, {text = {M.builtin.lnumfunc}, click = "v:lua.ScLa"}, {text = {" ", M.builtin.foldfunc, " "}, click = "v:lua.ScFa"}}
  local statuses = {"NeotestPassed", "NeotestFailed", "NeotestRunning", "NeotestSkipped"}
  M.setup({setopt = true, segments = segments, relculright = false})
  for _, s in ipairs(statuses) do
    vim.api.nvim_set_hl(0, s, {bg = "#2a2a37"})
  end
end
vim.o.number = true
vim.o.signcolumn = "yes"
return nil
