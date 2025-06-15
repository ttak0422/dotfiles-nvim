-- [nfnl] v2/fnl/edit-plugins.fnl
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
  return require("foldnav").goto_start()
end
local function _5_()
  return require("foldnav").goto_next()
end
local function _6_()
  return require("foldnav").goto_prev_start()
end
local function _7_()
  return require("foldnav").goto_end()
end
for _, k in ipairs({{"j", "gj"}, {"k", "gk"}, {"<Leader>m", _2_, desc("\239\136\132 join/split")}, {"<Leader>M", _3_, desc("\239\136\132 join/split (recursive)")}, {"<C-h>", _4_}, {"<C-j>", _5_}, {"<C-k>", _6_}, {"<C-l>", _7_}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
for _, k in ipairs({{"<Leader>T", ":Translate JA<CR>"}}) do
  vim.keymap.set("v", k[1], k[2], (k[3] or opts))
end
return nil
