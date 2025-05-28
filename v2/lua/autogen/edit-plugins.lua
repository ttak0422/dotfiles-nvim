-- [nfnl] Compiled from v2/fnl/edit-plugins.fnl by https://github.com/Olical/nfnl, do not edit.
vim.cmd("\nau FileType * setlocal formatoptions-=ro\nau WinEnter * checktime\nvnoremap ; :\nnnoremap ; :\n")
local opts = {noremap = true, silent = true}
local desc
local function _1_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _1_
local function _2_()
  return require("treesj").toggle({split = {recursive = false}})
end
local function _3_()
  return require("treesj").toggle({split = {recursive = true}})
end
local function _4_()
  return require("codewindow").toggle_minimap()
end
for _, k in ipairs({{"j", "gj"}, {"k", "gk"}, {"<Leader>m", _2_, desc("\239\136\132 join/split")}, {"<Leader>M", _3_, desc("\239\136\132 join/split (recursive)")}, {"<Leader>tm", _4_, desc("\239\136\132 minimap")}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
return nil
