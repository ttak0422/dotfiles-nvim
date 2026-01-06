-- [nfnl] v2/fnl/neovide.fnl
for k, v in pairs({neovide_padding_top = 5, neovide_padding_bottom = 5, neovide_padding_right = 5, neovide_padding_left = 5, neovide_cursor_animation_length = 0.1, neovide_cursor_animate_in_insert_mode = true, neovide_opacity = 0.85, neovide_window_blurred = true, neovide_macos_simple_fullscreen = true, neovide_confirm_quit = false, neovide_cursor_antialiasing = false, neovide_floating_shadow = false}) do
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
local toggle_blur
local function _3_()
  vim.g.neovide_window_blurred = not vim.g.neovide_window_blurred
  return nil
end
toggle_blur = _3_
local paste_from_clipboard_insert
local function _4_()
  local lines = vim.fn.getreg("+", 1, true)
  if (#lines == 1) then
    return vim.api.nvim_paste(lines[1], true, -1)
  else
    return vim.api.nvim_put(lines, vim.fn.getregtype("+"), true, true)
  end
end
paste_from_clipboard_insert = _4_
vim.o.guifont = "PlemolJP Console NF:h15"
local function _6_()
  return change_scale(scale)
end
map("n", "<C-+>", _6_)
local function _7_()
  return change_scale((1 / scale))
end
map("n", "<C-->", _7_)
map("n", "<A-Enter>", toggle_zoom)
map("n", "<A-Tab>", toggle_blur)
map("i", "<D-v>", paste_from_clipboard_insert)
map("c", "<D-v>", "<C-r>+")
map("t", "<D-v>", "<C-\\><C-n>\"+pi")
vim.api.nvim_create_user_command("ToggleNeovideFullScreen", toggle_zoom, {})
return vim.api.nvim_create_user_command("ToggleNeovideBlur", toggle_blur, {})
