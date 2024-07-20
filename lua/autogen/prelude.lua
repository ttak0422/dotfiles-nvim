-- [nfnl] Compiled from fnl/prelude.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local opts = {langmenu = "none", shortmess = (vim.o.shortmess .. "sWIcCS"), cmdheight = 0, termguicolors = true, signcolumn = "no", showtabline = 0, laststatus = 0, foldlevel = 99, foldlevelstart = 99, number = false, showmode = false}
  vim.loader.enable()
  for k, v in pairs(opts) do
    vim.o[k] = v
  end
end
vim.g.mapleader = " "
vim.g.maplocalleader = ","
do
  local map = vim.keymap.set
  local cmd
  local function _1_(c)
    return ("<cmd>" .. c .. "<cr>")
  end
  cmd = _1_
  local opts = {noremap = true, silent = true}
  local N = {{"<leader>", ":lua vim.cmd('doautocmd User TriggerLeader')<CR>"}, {";", ":"}}
  local V = {{";", ":"}}
  for _, K in ipairs(N) do
    map("n", K[1], K[2], (K[3] or opts))
  end
  for _, K in ipairs(V) do
    map("v", K[1], K[2], (K[3] or opts))
  end
  for i = 0, 9 do
    map({"n", "t", "i"}, ("<C-" .. i .. ">"), cmd(("TermToggle " .. i)), opts)
  end
end
local specificFileEnterAutoCmd = nil
local A = vim.api
local gen = A.nvim_create_autocmd
local exec = A.nvim_exec_autocmds
local del = A.nvim_del_autocmd
local function _2_()
  if (vim.bo.filetype ~= "") then
    exec("User", {pattern = "SpecificFileEnter"})
    return del(specificFileEnterAutoCmd)
  else
    return nil
  end
end
specificFileEnterAutoCmd = gen("FileType", {callback = _2_})
return nil
