-- [nfnl] Compiled from main/fnl/prelude.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local opts = {langmenu = "none", shortmess = (vim.o.shortmess .. "sWIcCS"), cmdheight = 0, termguicolors = true, signcolumn = "no", showtabline = 0, foldlevel = 99, foldlevelstart = 99, showmode = false, number = false}
  vim.loader.enable()
  for k, v in pairs(opts) do
    vim.o[k] = v
  end
end
vim.g.mapleader = " "
vim.g.maplocalleader = ","
local map = vim.keymap.set
local opts = {noremap = true, silent = true}
local desc
local function _1_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _1_
local N = {{"<leader>", ":lua vim.cmd('doautocmd User TriggerLeader')<CR>"}, {";", ":"}}
local V = {{";", ":"}}
for _, K in ipairs(N) do
  map("n", K[1], K[2], (K[3] or opts))
end
for _, K in ipairs(V) do
  map("v", K[1], K[2], (K[3] or opts))
end
return nil
