-- [nfnl] Compiled from main/fnl/hook-leader.fnl by https://github.com/Olical/nfnl, do not edit.
vim.api.nvim_del_keymap("n", "<Leader>")
vim.cmd("nmap <Leader>ff <CMD>Telescope<CR>")
local function _1_()
  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Leader>", true, false, true), "m", true)
end
return vim.schedule(_1_)
