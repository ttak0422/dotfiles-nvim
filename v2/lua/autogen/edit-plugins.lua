-- [nfnl] v2/fnl/edit-plugins.fnl
vim.cmd("\nau FileType * setlocal formatoptions-=ro\nau WinEnter * checktime\nvnoremap ; :\nnnoremap ; :\nnoremap gy \"+y\n")
local opts = {noremap = true, silent = true}
local desc
local function _1_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _1_
local dial
local function _2_(direction, mode)
  local function _3_()
    return require("dial.map").manipulate(direction, mode)
  end
  return _3_
end
dial = _2_
local function _4_()
  return require("treesj").toggle({split = {recursive = false}})
end
local function _5_()
  return require("treesj").toggle({split = {recursive = true}})
end
local function _6_()
  return require("foldnav").goto_start()
end
local function _7_()
  return require("foldnav").goto_next()
end
local function _8_()
  return require("foldnav").goto_prev_start()
end
local function _9_()
  return require("foldnav").goto_end()
end
local function _10_()
  return require("dial.map").manipulate("increment", "normal")
end
local function _11_()
  return require("dial.map").manipulate("decrement", "normal")
end
local function _12_()
  return require("dial.map").manipulate("increment", "gnormal")
end
local function _13_()
  return require("dial.map").manipulate("decrement", "gnormal")
end
for _, k in ipairs({{"<Leader>m", _4_, desc("\239\136\132 join/split")}, {"<Leader>M", _5_, desc("\239\136\132 join/split (recursive)")}, {"<Leader>O", "<Cmd>Other<CR>"}, {"<C-h>", _6_}, {"<C-j>", _7_}, {"<C-k>", _8_}, {"<C-l>", _9_}, {"<C-a>", _10_}, {"<C-x>", _11_}, {"g<C-a>", _12_}, {"g<C-x>", _13_}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
local function _14_()
  return require("dial.map").manipulate("increment", "visual")
end
local function _15_()
  return require("dial.map").manipulate("decrement", "visual")
end
local function _16_()
  return require("dial.map").manipulate("increment", "gvisual")
end
local function _17_()
  return require("dial.map").manipulate("decrement", "gvisual")
end
for _, k in ipairs({{"<Leader>T", ":Translate JA<CR>"}, {"<C-a>", _14_}, {"<C-x>", _15_}, {"g<C-a>", _16_}, {"g<C-x>", _17_}}) do
  vim.keymap.set("x", k[1], k[2], (k[3] or opts))
end
return nil
