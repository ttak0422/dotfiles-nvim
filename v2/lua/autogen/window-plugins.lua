-- [nfnl] v2/fnl/window-plugins.fnl
local opts = {noremap = true, silent = true}
local desc
local function _1_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _1_
for _, k in ipairs({{"<C-w>H", "<Cmd>WinShift left<CR>"}, {"<C-w>J", "<Cmd>WinShift down<CR>"}, {"<C-w>K", "<Cmd>WinShift up<CR>"}, {"<C-w>L", "<Cmd>WinShift right<CR>"}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
return nil
