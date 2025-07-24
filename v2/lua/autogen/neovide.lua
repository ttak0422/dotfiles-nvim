-- [nfnl] v2/fnl/neovide.fnl
for k, v in pairs({neovide_padding_top = 5, neovide_padding_bottom = 5, neovide_padding_right = 5, neovide_padding_left = 5, neovide_confirm_quit = false, neovide_floating_shadow = false}) do
  vim.g[k] = v
end
local map = vim.keymap.set
local scale = 1.1
local change_scale
local function _1_(delta)
  vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor * delta)
  return nil
end
change_scale = _1_
local toggle_zoom
local function _2_()
  vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  return nil
end
toggle_zoom = _2_
local paste_from_clipboard_insert
local function _3_()
  return vim.api.nvim_put(vim.fn.getreg("+", 1, true), vim.fn.getregtype("+"), true, true)
end
paste_from_clipboard_insert = _3_
vim.o.guifont = "PlemolJP Console NF:h15"
local function _4_()
  return change_scale(scale)
end
map("n", "<C-+>", _4_)
local function _5_()
  return change_scale((1 / scale))
end
map("n", "<C-->", _5_)
map("n", "<A-Enter>", toggle_zoom)
map("i", "<D-v>", paste_from_clipboard_insert)
map("c", "<D-v>", "<C-r>+")
map("t", "<D-v>", "<C-\\><C-n>\"+pi")
return vim.api.nvim_create_user_command("ToggleNeovideFullScreen", toggle_zoom, {})
