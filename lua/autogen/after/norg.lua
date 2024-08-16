-- [nfnl] Compiled from fnl/after/norg.fnl by https://github.com/Olical/nfnl, do not edit.
for k, v in pairs({conceallevel = 3, swapfile = false, wrap = false}) do
  vim.opt_local[k] = v
end
local map = vim.keymap.set
local opts
local function _1_(d)
  return {noremap = true, silent = true, buffer = true, desc = d}
end
opts = _1_
local N = {{"<LocalLeader>nn", "<Plug>(neorg.dirman.new-note)", opts("\238\152\179 Create a new note")}}
for _, k in ipairs(N) do
  map("n", k[1], k[2], k[3])
end
return nil
